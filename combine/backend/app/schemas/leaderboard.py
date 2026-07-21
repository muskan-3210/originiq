"""Models for GET /api/leaderboard (§10.4)."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel

LeaderboardScope = Literal["global", "country", "school"]


class LeaderboardEntryOut(BaseModel):
    rank: int
    display_name: str
    catch_count: int
    country: str | None = None


class LeaderboardResponse(BaseModel):
    scope: LeaderboardScope
    entries: list[LeaderboardEntryOut]
