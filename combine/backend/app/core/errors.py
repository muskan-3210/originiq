"""Uniform error envelope.

Every error response shares the PRD shape (§10):
    { "error": { "code": "string", "message": "human-readable message" } }
Stack traces are never exposed to clients (§10.1, §15).
"""
from __future__ import annotations

import logging
from typing import Any

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

logger = logging.getLogger("oracle.errors")


class ApiError(Exception):
    """Raise anywhere to return a shaped error response."""

    def __init__(
        self,
        status_code: int,
        code: str,
        message: str,
        headers: dict[str, str] | None = None,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.message = message
        self.headers = headers


def _envelope(code: str, message: str) -> dict[str, Any]:
    return {"error": {"code": code, "message": message}}


async def api_error_handler(request: Request, exc: ApiError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content=_envelope(exc.code, exc.message),
        headers=exc.headers,
    )


async def validation_error_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    errors = exc.errors()
    first = errors[0] if errors else {}
    loc = ".".join(str(p) for p in first.get("loc", []) if p not in ("body", "query"))
    msg = first.get("msg", "Invalid request.")
    message = f"{loc}: {msg}" if loc else msg
    return JSONResponse(status_code=422, content=_envelope("invalid_request", message))


async def unhandled_error_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.exception("Unhandled error on %s %s", request.method, request.url.path)
    return JSONResponse(
        status_code=500,
        content=_envelope("internal_error", "Something went wrong on our end."),
    )
