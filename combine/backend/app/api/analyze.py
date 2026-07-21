"""POST /api/analyze — the core endpoint (§10.1)."""
from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.core.config import get_settings
from app.core.errors import ApiError
from app.core.rate_limit import enforce_rate_limit
from app.core.security import optional_uid
from app.nlp import pipeline
from app.schemas.analyze import AnalyzeResponse
from app.schemas.common import ErrorResponse

router = APIRouter(tags=["analysis"])

_VALID_TYPES = {"text", "url", "image"}


@router.post(
    "/analyze",
    response_model=AnalyzeResponse,
    responses={
        413: {"model": ErrorResponse},
        422: {"model": ErrorResponse},
        429: {"model": ErrorResponse},
    },
)
async def analyze(
    type: str = Form(...),
    content: str | None = Form(default=None),
    language_hint: str | None = Form(default=None),
    image: UploadFile | None = File(default=None),
    uid: str | None = Depends(optional_uid),
    _rate_limited: None = Depends(enforce_rate_limit),
) -> AnalyzeResponse:
    settings = get_settings()

    if type not in _VALID_TYPES:
        raise ApiError(422, "invalid_request", "type must be one of text, url, or image.")

    image_bytes: bytes | None = None
    filename: str | None = None

    if type == "image":
        if image is None:
            raise ApiError(422, "invalid_request", "An image file is required for image analysis.")
        image_bytes = await image.read()
        if len(image_bytes) > settings.max_image_bytes:
            raise ApiError(413, "file_too_large", "That image is larger than 10 MB.")
        filename = image.filename
    else:
        if not content or not content.strip():
            raise ApiError(422, "invalid_request", "There's nothing to check yet.")
        if len(content) > settings.max_content_chars * 4:
            # Hard cap well above the truncation limit to reject abuse outright.
            raise ApiError(422, "invalid_request", "That submission is too long to process.")

    result = pipeline.analyze(
        content_type=type,
        content=content,
        image_bytes=image_bytes,
        filename=filename,
        language_hint=language_hint,
        uid=uid,
    )
    return AnalyzeResponse.model_validate(result)
