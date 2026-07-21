"""GET /api/stats/global — powers the dashboard live counter (§10.5)."""
from __future__ import annotations

from fastapi import APIRouter

from app.db import get_repository
from app.schemas.stats import GlobalStatsResponse

router = APIRouter(tags=["stats"])


@router.get("/stats/global", response_model=GlobalStatsResponse)
async def global_stats() -> GlobalStatsResponse:
    stats = get_repository().global_stats()
    return GlobalStatsResponse(
        chains_broken_today=stats.chains_broken_today,
        chains_broken_total=stats.chains_broken_total,
        countries_covered=stats.countries_covered,
    )
