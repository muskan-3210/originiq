"""Origin tracing & similarity matching (§14.3).

Encode the extracted claim, run cosine similarity against the knowledge base,
and apply the 0.75 threshold. On a near-miss, consult Google Fact Check as a
secondary source. Never fabricates an origin — a miss returns no trace.
"""
from __future__ import annotations

from dataclasses import dataclass

from app.core.config import get_settings
from app.db import get_repository
from app.domain import Trace
from app.integrations import google_factcheck
from app.integrations.google_factcheck import FactCheckResult
from app.nlp.claim_extractor import ExtractedClaim
from app.nlp.embedder import get_embedder


@dataclass
class TraceOutcome:
    trace: Trace | None
    fact_check: FactCheckResult | None


def trace(extracted: ExtractedClaim) -> TraceOutcome:
    settings = get_settings()
    embedding = get_embedder().encode(extracted.text)
    matches = get_repository().search_similar(embedding, limit=5)

    best = matches[0] if matches else None
    if best is not None and best.similarity >= settings.similarity_threshold:
        full = get_repository().get_trace(best.claim.id, similarity=best.similarity)
        if full is not None:
            return TraceOutcome(trace=full, fact_check=None)

    # Near-miss: secondary external check (§14.3).
    return TraceOutcome(trace=None, fact_check=google_factcheck.lookup(extracted.text))
