"""GET /api/leaderboard (§10.4)."""
from __future__ import annotations

from fastapi import APIRouter, Query

from app.core.errors import ApiError
from app.integrations.firestore_client import get_firestore_client
from app.schemas.leaderboard import LeaderboardEntryOut, LeaderboardResponse

router = APIRouter(tags=["leaderboard"])

_VALID_SCOPES = {"global", "country", "school"}


@router.get("/leaderboard", response_model=LeaderboardResponse)
async def leaderboard(
    scope: str = Query(default="global"),
    limit: int = Query(default=50, ge=1, le=100),
) -> LeaderboardResponse:
    if scope not in _VALID_SCOPES:
        raise ApiError(422, "invalid_request", "scope must be global, country, or school.")

    entries = get_firestore_client().read_leaderboard(scope, limit)
    return LeaderboardResponse(
        scope=scope,
        entries=[
            LeaderboardEntryOut(
                rank=e.rank,
                display_name=e.display_name,
                catch_count=e.catch_count,
                country=e.country,
            )
            for e in entries
        ],
    )
