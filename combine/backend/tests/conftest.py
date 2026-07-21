"""Shared test fixtures. Forces the zero-infra lite backend so the whole suite
runs with no Postgres/Redis/Firebase/API keys."""
from __future__ import annotations

import base64
import json
import os
import sys
from pathlib import Path

# Ensure the `app` package is importable regardless of how pytest is invoked.
BACKEND_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_ROOT))

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("REPOSITORY_BACKEND", "memory")
os.environ.setdefault("CACHE_BACKEND", "memory")
os.environ.setdefault("NLP_EMBEDDER", "hashing")
os.environ.setdefault("RATE_LIMIT_MAX_REQUESTS", "1000")
os.environ.setdefault("LOCAL_STORAGE_DIR", ".local_storage_test")

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402


def _clear_singletons() -> None:
    from app.cache import reset_cache
    from app.core.config import get_settings
    from app.db import reset_repository
    from app.integrations.firestore_client import get_firestore_client
    from app.nlp.embedder import get_embedder

    get_settings.cache_clear()
    reset_cache()
    reset_repository()
    get_embedder.cache_clear()
    get_firestore_client.cache_clear()


@pytest.fixture(autouse=True)
def reset_singletons():
    _clear_singletons()
    yield
    _clear_singletons()


@pytest.fixture
def client():
    from app.main import create_app

    with TestClient(create_app()) as test_client:
        yield test_client


def make_bearer_token(uid: str = "tester") -> str:
    """A fake unsigned JWT — accepted only in non-production when Firebase Admin
    isn't configured (see security._decode_unverified_uid)."""
    payload = base64.urlsafe_b64encode(json.dumps({"user_id": uid}).encode()).decode().rstrip("=")
    return f"eyJhbGciOiJub25lIn0.{payload}.signature"


@pytest.fixture
def auth_headers() -> dict[str, str]:
    return {"Authorization": f"Bearer {make_bearer_token()}"}


# A claim that exists verbatim in the seed KB — guarantees a strong match.
KNOWN_CLAIM = "5G mobile networks cause or spread the coronavirus."
