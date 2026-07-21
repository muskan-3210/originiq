"""Knowledge-base repository interface.

The NLP pipeline depends only on this Protocol, never on SQLAlchemy or the
in-memory loader — so origin tracing, mutation assembly and damage lookup are
identical regardless of backend, and trivially testable with a fake.
"""
from __future__ import annotations

from collections.abc import Sequence
from typing import Protocol

from app.domain import ClaimMatch, GlobalStatsData, Trace


class KnowledgeRepository(Protocol):
    def search_similar(
        self, embedding: Sequence[float], limit: int = 5
    ) -> list[ClaimMatch]:
        """Return the closest claims by cosine similarity, best first."""
        ...

    def get_trace(self, claim_id: str, similarity: float = 1.0) -> Trace | None:
        """Assemble origin + mutations + damage for a matched claim (§14.4, §14.6)."""
        ...

    def log_analysis(
        self,
        input_hash: str,
        matched_claim_id: str | None,
        similarity_score: float | None,
        firebase_uid: str | None,
    ) -> None:
        """Record the analysis for auditing / stats (analysis_log, §9.1)."""
        ...

    def global_stats(self) -> GlobalStatsData:
        """Aggregate counters for the dashboard live counter (§10.5)."""
        ...
