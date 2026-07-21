"""POST /api/truthcard — generate the shareable verdict card (§10.2)."""
from __future__ import annotations

from fastapi import APIRouter, Depends

from app.core.errors import ApiError
from app.core.security import optional_uid
from app.media import truth_card
from app.nlp import pipeline
from app.schemas.common import ErrorResponse
from app.schemas.truthcard import TruthCardRequest, TruthCardResponse

router = APIRouter(tags=["analysis"])


@router.post(
    "/truthcard",
    response_model=TruthCardResponse,
    responses={404: {"model": ErrorResponse}, 422: {"model": ErrorResponse}},
)
async def create_truth_card(
    body: TruthCardRequest,
    uid: str | None = Depends(optional_uid),
) -> TruthCardResponse:
    analysis = pipeline.get_analysis(body.analysis_id)
    if analysis is None:
        raise ApiError(404, "not_found", "We couldn't find that analysis.")
    if not analysis.get("truth_card_ready"):
        raise ApiError(422, "not_ready", "There's no truth card available for this result.")

    png_bytes = truth_card.render_png(analysis)
    image_url = truth_card.store_truth_card(body.analysis_id, png_bytes)
    return TruthCardResponse(image_url=image_url)
