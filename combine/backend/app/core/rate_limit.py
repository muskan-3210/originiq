"""Rate limiting (§14.5): 30 requests / 10 minutes, per uid (authenticated)
or per client IP (anonymous). Returns 429 with a Retry-After header."""
from __future__ import annotations

from fastapi import Depends, Request

from app.cache import get_cache
from app.core.config import get_settings
from app.core.errors import ApiError
from app.core.security import optional_uid


def _client_ip(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


async def enforce_rate_limit(
    request: Request, uid: str | None = Depends(optional_uid)
) -> None:
    settings = get_settings()
    identity = f"uid:{uid}" if uid else f"ip:{_client_ip(request)}"
    count, reset_in = get_cache().incr_with_window(
        f"ratelimit:{identity}", settings.rate_limit_window_seconds
    )
    if count > settings.rate_limit_max_requests:
        raise ApiError(
            status_code=429,
            code="rate_limited",
            message="You're checking things quickly — give it a minute and try again.",
            headers={"Retry-After": str(reset_in)},
        )
