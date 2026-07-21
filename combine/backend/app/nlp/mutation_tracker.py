"""Mutation assembly (§14.4).

All recorded mutations for the matched claim, ordered by date. `similarity_to_origin`
is precomputed at seed time and drives the "how much did the wording drift"
comparison on the Mutation screen. Direct lookup — never fabricated.
"""
from __future__ import annotations

from app.domain import MutationData, Trace


def ordered_mutations(trace: Trace) -> list[MutationData]:
    return sorted(trace.mutations, key=lambda m: (m.date, m.version))
