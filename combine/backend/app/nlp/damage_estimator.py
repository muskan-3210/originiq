"""Damage lookup (§14.6).

Curated data only — returns exactly the `damage_records` linked to the matched
claim, so the app never shows a fabricated statistic. "Estimator" is a misnomer
inherited from the PRD module name: nothing is estimated at request time.
"""
from __future__ import annotations

from app.domain import DamageData, Trace


def documented_damage(trace: Trace) -> list[DamageData]:
    # Largest impact first for display; the set is exactly what's recorded.
    return sorted(trace.damage, key=lambda d: d.value, reverse=True)


def top_stat(trace: Trace) -> DamageData | None:
    return max(trace.damage, key=lambda d: d.value, default=None)
