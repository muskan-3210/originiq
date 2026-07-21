"""Model for GET /api/stats/global (§10.5)."""
from __future__ import annotations

from pydantic import BaseModel


class GlobalStatsResponse(BaseModel):
    chains_broken_today: int
    chains_broken_total: int
    countries_covered: int
