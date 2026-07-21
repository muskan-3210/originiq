"""Analysis orchestrator — wires intake → extraction → tracing → response (§19 step 13).

Order of operations (§14.5): the cache is checked first, before any embedding /
search / external API work. The assembled response matches the §10.1 contract
exactly, plus two optional, additive extension fields (`notices`, `sources`)
that older clients can safely ignore.
"""
from __future__ import annotations

import copy
import logging
import uuid
from datetime import date

from app.cache import get_cache
from app.core.config import get_settings
from app.db import get_repository
from app.domain import Trace
from app.integrations.google_factcheck import FactCheckResult
from app.nlp import (
    claim_extractor,
    content_intake,
    damage_estimator,
    mutation_tracker,
    origin_tracer,
)
from app.nlp.text_utils import content_hash

logger = logging.getLogger("oracle.pipeline")

# Deterministic analysis ids from the content hash → identical content, identical id.
_ANALYSIS_NS = uuid.UUID("2b1a6f4e-9c3d-4a5e-8b7c-1d2e3f4a5b6c")


def _iso(value: date) -> str:
    return value.isoformat()


def _origin_dict(trace: Trace) -> dict | None:
    if trace.origin is None:
        return None
    return {
        "platform": trace.origin.platform,
        "country": trace.origin.country,
        "date": _iso(trace.origin.date),
        "tags": list(trace.claim.tags),
        "hops_traced": trace.hops_traced,
    }


def _build_matched(trace: Trace, analysis_id: str) -> dict:
    return {
        "id": analysis_id,
        "verdict": trace.claim.verdict,
        "cached": False,
        "origin": _origin_dict(trace),
        "mutations": [
            {
                "version": m.version,
                "country": m.country,
                "date": _iso(m.date),
                "text_excerpt": m.text_excerpt,
                "similarity_to_origin": round(m.similarity_to_origin, 4),
            }
            for m in mutation_tracker.ordered_mutations(trace)
        ],
        "damage": [
            {
                "label": d.label,
                "value": d.value,
                "description": d.description,
                "source_name": d.source_name,
                "source_url": d.source_url,
            }
            for d in damage_estimator.documented_damage(trace)
        ],
        "truth_card_ready": trace.claim.verdict != "unverified",
    }


def _build_factcheck(fact_check: FactCheckResult, analysis_id: str) -> dict:
    return {
        "id": analysis_id,
        "verdict": fact_check.verdict,
        "cached": False,
        "origin": None,
        "mutations": [],
        "damage": [],
        "truth_card_ready": True,
        "sources": [
            {"name": fact_check.publisher, "url": fact_check.url, "title": fact_check.title}
        ],
    }


def _build_unverified(analysis_id: str) -> dict:
    return {
        "id": analysis_id,
        "verdict": "unverified",
        "cached": False,
        "origin": None,
        "mutations": [],
        "damage": [],
        "truth_card_ready": False,
    }


def analyze(
    *,
    content_type: str,
    content: str | None = None,
    image_bytes: bytes | None = None,
    filename: str | None = None,
    language_hint: str | None = None,
    uid: str | None = None,
) -> dict:
    settings = get_settings()
    cache = get_cache()
    repo = get_repository()

    intake = content_intake.extract(
        content_type=content_type,
        content=content,
        image_bytes=image_bytes,
        filename=filename,
        max_chars=settings.max_content_chars,
    )

    input_hash = content_hash(intake.text)
    cache_key = f"analysis:{input_hash}"

    # §14.5 — cache check before any NLP/API work.
    cached = cache.get_json(cache_key)
    if cached is not None:
        result = copy.deepcopy(cached)
        result["cached"] = True
        return result

    analysis_id = str(uuid.uuid5(_ANALYSIS_NS, input_hash))
    notices: list[str] = []
    if intake.truncated:
        notices.append(f"We checked the first {settings.max_content_chars:,} characters.")

    extracted = claim_extractor.extract(intake.text, language_hint)
    matched_claim_id: str | None = None
    similarity: float | None = None

    if not extracted.text or extracted.checkworthy_score < settings.checkworthiness_threshold:
        # Not a factual claim (§14.2) — skip the KB search entirely.
        response = _build_unverified(analysis_id)
    else:
        outcome = origin_tracer.trace(extracted)
        if outcome.trace is not None:
            response = _build_matched(outcome.trace, analysis_id)
            matched_claim_id = outcome.trace.claim.id
            similarity = outcome.trace.similarity
        elif outcome.fact_check is not None:
            response = _build_factcheck(outcome.fact_check, analysis_id)
        else:
            response = _build_unverified(analysis_id)

    if notices:
        response["notices"] = notices

    cache.set_json(cache_key, response, settings.cache_ttl_seconds)
    cache.set_json(f"analysis:id:{analysis_id}", response, settings.cache_ttl_seconds)

    try:
        repo.log_analysis(input_hash, matched_claim_id, similarity, uid)
    except Exception as exc:  # logging must never fail the request
        logger.warning("analysis_log write failed: %s", exc)

    return response


def get_analysis(analysis_id: str) -> dict | None:
    """Fetch a previously computed analysis by id (for /truthcard, /legacy)."""
    cached = get_cache().get_json(f"analysis:id:{analysis_id}")
    if cached is None:
        return None
    result = copy.deepcopy(cached)
    result["cached"] = True
    return result
