#!/usr/bin/env python
"""Seed the ORACLE knowledge base (§9.4).

Validates the four-field minimum per claim (origin date, origin platform,
>=1 source URL, >=1 damage record) and skips — never partially inserts —
incomplete records. Run after migrations (§17.1 step 4):

    python scripts/seed_database.py                 # seed Postgres
    python scripts/seed_database.py --validate-only  # validate JSON, no DB needed
"""
from __future__ import annotations

import argparse
import json
import logging
import sys
from datetime import date
from pathlib import Path

# Make the `app` package importable when run as a script.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.logging import configure_logging  # noqa: E402
from app.nlp.text_utils import normalize_text  # noqa: E402

logger = logging.getLogger("oracle.seed")

SEED_PATH = Path(__file__).resolve().parent.parent / "app" / "data" / "seed_claims.json"
_REQUIRED_ORIGIN_FIELDS = ("origin_date", "platform", "country", "source_url")


def load_records(path: Path) -> list[dict]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    return raw["claims"] if isinstance(raw, dict) and "claims" in raw else raw


def validate_record(record: dict) -> tuple[bool, str]:
    if not (record.get("text") or "").strip():
        return False, "missing text"

    origins = record.get("origins") or ([record["origin"]] if record.get("origin") else [])
    if not origins:
        return False, "no origin"
    for origin in origins:
        for field in _REQUIRED_ORIGIN_FIELDS:
            if not origin.get(field):
                return False, f"origin missing '{field}'"

    damage = record.get("damage") or []
    if not damage:
        return False, "no damage record"
    for entry in damage:
        if entry.get("stat_value") is None:
            return False, "damage missing stat_value"
        if not entry.get("source_url") or not entry.get("source_name"):
            return False, "damage missing source"

    return True, "ok"


def seed(validate_only: bool = False) -> tuple[int, int]:
    configure_logging("INFO")
    records = load_records(SEED_PATH)

    valid: list[dict] = []
    skipped = 0
    for record in records:
        ok, reason = validate_record(record)
        if not ok:
            logger.warning("Skipping claim (%s): %.60s", reason, record.get("text", ""))
            skipped += 1
            continue
        valid.append(record)

    logger.info("Validated %d claims, skipped %d.", len(valid), skipped)
    if validate_only:
        return len(valid), skipped

    from sqlalchemy import select

    from app.db.models import Claim, DamageRecord, Mutation, Origin
    from app.db.session import session_scope
    from app.nlp.embedder import get_embedder

    embedder = get_embedder()
    inserted = 0
    with session_scope() as session:
        for record in valid:
            normalized = record.get("normalized_text") or normalize_text(record["text"])
            if session.execute(
                select(Claim.id).where(Claim.normalized_text == normalized)
            ).first():
                logger.info("Already present, skipping: %.50s", record["text"])
                continue

            category = record.get("category", "other")
            claim = Claim(
                text=record["text"],
                normalized_text=normalized,
                embedding=embedder.encode(normalized),
                language=record.get("language", "en"),
                category=category,
                tags=record.get("tags") or [category],
                checkworthy_score=record.get("checkworthy_score"),
                verdict=record.get("verdict", "false"),
            )
            origins = record.get("origins") or [record["origin"]]
            for origin in origins:
                claim.origins.append(
                    Origin(
                        origin_date=date.fromisoformat(origin["origin_date"]),
                        platform=origin["platform"],
                        country=origin["country"],
                        source_url=origin["source_url"],
                    )
                )
            for mutation in record.get("mutations", []):
                claim.mutations.append(
                    Mutation(
                        version_num=mutation["version_num"],
                        text=mutation["text"],
                        mutation_date=date.fromisoformat(mutation["mutation_date"]),
                        country=mutation["country"],
                        language=mutation.get("language", "en"),
                        similarity_to_origin=mutation["similarity_to_origin"],
                    )
                )
            for damage in record["damage"]:
                claim.damage_records.append(
                    DamageRecord(
                        stat_label=damage["stat_label"],
                        stat_value=damage["stat_value"],
                        description=damage["description"],
                        source_url=damage["source_url"],
                        source_name=damage["source_name"],
                    )
                )
            session.add(claim)
            inserted += 1

    logger.info("Seed complete: %d inserted, %d skipped.", inserted, skipped)
    return inserted, skipped


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed the ORACLE knowledge base.")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate the seed file without connecting to a database.",
    )
    args = parser.parse_args()
    inserted_or_valid, skipped_count = seed(validate_only=args.validate_only)
    # Non-zero exit if nothing usable was found, so CI/deploy fails loudly.
    sys.exit(1 if inserted_or_valid == 0 else 0)
