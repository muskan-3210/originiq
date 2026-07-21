"""Firebase token verification & auth dependencies (§13).

Auth is never a barrier to the core experience:
  • /api/analyze, /api/truthcard  → optional (uid may be None → anonymous)
  • /api/legacy                    → required (any valid token, incl. anonymous)

The backend is fully stateless — every request is verified independently.
"""
from __future__ import annotations

import base64
import binascii
import json
import logging

from fastapi import Header, Request

from app.core.config import get_settings
from app.core.errors import ApiError
from app.integrations.firebase_admin_client import get_firebase_client

logger = logging.getLogger("oracle.security")


def _extract_bearer(authorization: str | None) -> str | None:
    if not authorization:
        return None
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() == "bearer" and token.strip():
        return token.strip()
    return None


def _decode_unverified_uid(token: str) -> str | None:
    """DEV ONLY — read a JWT payload without signature verification to attribute
    a uid when Firebase Admin isn't configured locally. Never reached in production
    (guarded by the caller)."""
    try:
        payload_segment = token.split(".")[1]
        payload_segment += "=" * (-len(payload_segment) % 4)
        payload = json.loads(base64.urlsafe_b64decode(payload_segment))
    except (IndexError, binascii.Error, json.JSONDecodeError, ValueError):
        return None
    return payload.get("user_id") or payload.get("sub") or payload.get("uid")


def resolve_uid(token: str | None) -> str | None:
    if not token:
        return None
    client = get_firebase_client()
    if client.configured:
        claims = client.verify_token(token)
        return claims.get("uid") if claims else None
    # Firebase Admin unconfigured: verify is impossible.
    if get_settings().is_production:
        return None
    return _decode_unverified_uid(token)


async def optional_uid(
    request: Request, authorization: str | None = Header(default=None)
) -> str | None:
    uid = resolve_uid(_extract_bearer(authorization))
    request.state.uid = uid
    return uid


async def required_uid(
    request: Request, authorization: str | None = Header(default=None)
) -> str:
    uid = resolve_uid(_extract_bearer(authorization))
    if not uid:
        raise ApiError(
            status_code=401,
            code="unauthorized",
            message="A valid sign-in token is required to save to your Legacy Wall.",
        )
    request.state.uid = uid
    return uid
