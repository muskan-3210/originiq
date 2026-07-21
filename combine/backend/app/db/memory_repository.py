"""In-memory knowledge base — the zero-infra default (§9, lite mode).

Loads `app/data/seed_claims.json`, embeds each claim with the configured
embedder at startup, and answers similarity search with NumPy cosine. Identical
behaviour to the Postgres repository from the pipeline's point of view, so the
whole app — analyze → origin → mutation → damage → truth card — works with no
database, no Redis, and no API keys.
"""
from __future__ import annotations

import json
import logging
import uuid
from collections.abc import Sequence
from datetime import UTC, date, datetime
from pathlib import Path
from typing import Any

import numpy as np

from app.core.config import get_settings
from app.domain import (
    ClaimData,
    ClaimMatch,
    DamageData,
    GlobalStatsData,
    MutationData,
    OriginData,
    Trace,
)
from app.nlp.embedder import get_embedder
from app.nlp.text_utils import normalize_text

logger = logging.getLogger("oracle.db.memory")

# Stable namespace → deterministic claim ids from normalized text (no randomness).
_NAMESPACE = uuid.UUID("6f4e2b1a-0c3d-4a5e-9b7c-1d2e3f4a5b6c")
_SEED_PATH = Path(__file__).resolve().parent.parent / "data" / "seed_claims.json"
_CAUGHT_VERDICTS = {"false", "misleading"}


class InMemoryKnowledgeRepository:
    def __init__(self, entries: dict[str, dict[str, Any]]) -> None:
        self._entries = entries
        self._ids = list(entries.keys())
        dim = get_settings().embedding_dim
        self._matrix = (
            np.array([entries[i]["embedding"] for i in self._ids], dtype=float)
            if entries
            else np.zeros((0, dim), dtype=float)
        )
        self._log: list[dict[str, Any]] = []

    # ── construction ──────────────────────────────────────────────────────
    @classmethod
    def from_seed_file(cls, path: Path = _SEED_PATH) -> InMemoryKnowledgeRepository:
        if not path.exists():
            logger.warning("Seed file %s not found; knowledge base is empty.", path)
            return cls({})
        raw = json.loads(path.read_text(encoding="utf-8"))
        records = raw["claims"] if isinstance(raw, dict) and "claims" in raw else raw
        embedder = get_embedder()
        entries: dict[str, dict[str, Any]] = {}
        for record in records:
            entry = cls._build_entry(record, embedder)
            if entry is not None:
                entries[entry["claim"].id] = entry
        logger.info("Loaded %d claims into the in-memory knowledge base.", len(entries))
        return cls(entries)

    @staticmethod
    def _build_entry(record: dict[str, Any], embedder: Any) -> dict[str, Any] | None:
        text = (record.get("text") or "").strip()
        if not text:
            return None

        origins_raw = record.get("origins") or (
            [record["origin"]] if record.get("origin") else []
        )
        damage_raw = record.get("damage") or []
        # Same minimum-viable rule the seed script enforces (§9.4): drop, never fabricate.
        if not origins_raw or not damage_raw:
            logger.warning("Skipping incomplete claim (no origin/damage): %.60s", text)
            return None

        normalized = record.get("normalized_text") or normalize_text(text)
        claim_id = str(uuid.uuid5(_NAMESPACE, normalized))
        category = record.get("category", "other")
        claim = ClaimData(
            id=claim_id,
            text=text,
            normalized_text=normalized,
            language=record.get("language", "en"),
            category=category,
            verdict=record.get("verdict", "false"),
            tags=record.get("tags") or [category],
            checkworthy_score=record.get("checkworthy_score"),
        )

        first_origin = sorted(origins_raw, key=lambda o: o["origin_date"])[0]
        origin = OriginData(
            platform=first_origin["platform"],
            country=first_origin["country"],
            date=date.fromisoformat(first_origin["origin_date"]),
            source_url=first_origin["source_url"],
        )
        mutations = [
            MutationData(
                version=m["version_num"],
                country=m["country"],
                date=date.fromisoformat(m["mutation_date"]),
                text_excerpt=m["text"],
                similarity_to_origin=m["similarity_to_origin"],
                language=m.get("language", "en"),
            )
            for m in sorted(record.get("mutations", []), key=lambda m: m["mutation_date"])
        ]
        damage = [
            DamageData(
                label=d["stat_label"],
                value=float(d["stat_value"]),
                description=d["description"],
                source_name=d["source_name"],
                source_url=d["source_url"],
            )
            for d in damage_raw
        ]
        return {
            "claim": claim,
            "origin": origin,
            "mutations": mutations,
            "damage": damage,
            "embedding": embedder.encode(normalized),
        }

    # ── repository interface ──────────────────────────────────────────────
    def search_similar(
        self, embedding: Sequence[float], limit: int = 5
    ) -> list[ClaimMatch]:
        if self._matrix.shape[0] == 0:
            return []
        query = np.asarray(embedding, dtype=float)
        q_norm = np.linalg.norm(query)
        if q_norm > 0:
            query = query / q_norm
        row_norms = np.linalg.norm(self._matrix, axis=1)
        row_norms[row_norms == 0] = 1.0
        sims = (self._matrix @ query) / row_norms
        top = np.argsort(-sims)[:limit]
        return [
            ClaimMatch(
                claim=self._entries[self._ids[i]]["claim"], similarity=float(sims[i])
            )
            for i in top
        ]

    def get_trace(self, claim_id: str, similarity: float = 1.0) -> Trace | None:
        entry = self._entries.get(claim_id)
        if entry is None:
            return None
        return Trace(
            claim=entry["claim"],
            origin=entry["origin"],
            mutations=list(entry["mutations"]),
            damage=list(entry["damage"]),
            similarity=similarity,
        )

    def log_analysis(
        self,
        input_hash: str,
        matched_claim_id: str | None,
        similarity_score: float | None,
        firebase_uid: str | None,
    ) -> None:
        verdict = None
        if matched_claim_id and matched_claim_id in self._entries:
            verdict = self._entries[matched_claim_id]["claim"].verdict
        self._log.append(
            {
                "created_at": datetime.now(UTC),
                "matched_claim_id": matched_claim_id,
                "verdict": verdict,
            }
        )

    def global_stats(self) -> GlobalStatsData:
        today = datetime.now(UTC).date()
        caught = [row for row in self._log if row["verdict"] in _CAUGHT_VERDICTS]
        countries: set[str] = set()
        for entry in self._entries.values():
            if entry["origin"]:
                countries.add(entry["origin"].country)
            for mutation in entry["mutations"]:
                countries.add(mutation.country)
        return GlobalStatsData(
            chains_broken_today=sum(1 for r in caught if r["created_at"].date() == today),
            chains_broken_total=len(caught),
            countries_covered=len(countries),
        )
