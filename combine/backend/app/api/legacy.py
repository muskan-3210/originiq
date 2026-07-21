"""POST /api/legacy — record a catch on the user's Legacy Wall (§10.3)."""
from __future__ import annotations

from fastapi import APIRouter, Depends

from app.core.errors import ApiError
from app.core.security import required_uid
from app.integrations.firestore_client import DuplicateLegacyEntry, get_firestore_client
from app.nlp import pipeline
from app.schemas.common import ErrorResponse
from app.schemas.legacy import LegacyRequest, LegacyResponse

router = APIRouter(tags=["legacy"])

_CATCHABLE = {"false", "misleading"}


@router.post(
    "/legacy",
    response_model=LegacyResponse,
    responses={
        401: {"model": ErrorResponse},
        404: {"model": ErrorResponse},
        409: {"model": ErrorResponse},
        422: {"model": ErrorResponse},
    },
)
async def add_legacy_entry(
    body: LegacyRequest,
    uid: str = Depends(required_uid),
) -> LegacyResponse:
    analysis = pipeline.get_analysis(body.analysis_id)
    if analysis is None:
        raise ApiError(404, "not_found", "We couldn't find that analysis.")

    verdict = analysis.get("verdict")
    if verdict not in _CATCHABLE:
        # Only false/misleading claims count as a catch (§14.8).
        raise ApiError(
            422, "not_a_catch", "Only false or misleading claims are added to your Legacy Wall."
        )

    try:
        entry_id, count = get_firestore_client().add_legacy_entry(
            uid=uid,
            analysis_id=body.analysis_id,
            verdict=verdict,
            truth_card_url=body.truth_card_url,
        )
    except DuplicateLegacyEntry as exc:
        raise ApiError(409, "duplicate", "This one's already on your Legacy Wall.") from exc

    return LegacyResponse(entry_id=entry_id, legacy_count=count)
