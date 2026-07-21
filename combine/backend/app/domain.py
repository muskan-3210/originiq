"""Storage-agnostic domain types.

Both the Postgres and in-memory knowledge repositories return these, so the
NLP pipeline and API layer never depend on how the data is stored.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date


@dataclass(frozen=True)
class OriginData:
    platform: str
    country: str
    date: date
    source_url: str


@dataclass(frozen=True)
class MutationData:
    version: int
    country: str
    date: date
    text_excerpt: str
    similarity_to_origin: float
    language: str = "en"


@dataclass(frozen=True)
class DamageData:
    label: str
    value: float
    description: str
    source_name: str
    source_url: str


@dataclass(frozen=True)
class ClaimData:
    id: str
    text: str
    normalized_text: str
    language: str
    category: str
    verdict: str
    tags: list[str] = field(default_factory=list)
    checkworthy_score: float | None = None


@dataclass(frozen=True)
class ClaimMatch:
    claim: ClaimData
    similarity: float


@dataclass(frozen=True)
class Trace:
    """A fully assembled forensic story for one matched claim."""

    claim: ClaimData
    origin: OriginData | None
    mutations: list[MutationData]
    damage: list[DamageData]
    similarity: float

    @property
    def hops_traced(self) -> int:
        # Structural count of recorded hops: the origin plus each recorded
        # mutation. Derived from real rows — never a fabricated figure.
        return (1 if self.origin else 0) + len(self.mutations)

    @property
    def countries(self) -> list[str]:
        seen: list[str] = []
        if self.origin:
            seen.append(self.origin.country)
        for mutation in self.mutations:
            if mutation.country not in seen:
                seen.append(mutation.country)
        return seen


@dataclass(frozen=True)
class GlobalStatsData:
    chains_broken_today: int
    chains_broken_total: int
    countries_covered: int


@dataclass(frozen=True)
class LeaderboardEntryData:
    rank: int
    display_name: str
    catch_count: int
    country: str | None = None
