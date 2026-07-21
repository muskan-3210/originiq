"""Rate limiter triggers 429 at the configured threshold (§16.2, §14.5)."""
from fastapi.testclient import TestClient


def test_rate_limit_returns_429(monkeypatch):
    monkeypatch.setenv("RATE_LIMIT_MAX_REQUESTS", "3")
    monkeypatch.setenv("RATE_LIMIT_WINDOW_SECONDS", "600")

    from app.cache import reset_cache
    from app.core.config import get_settings

    get_settings.cache_clear()
    reset_cache()

    from app.main import create_app

    client = TestClient(create_app())
    payload = {"type": "text", "content": "lol"}

    statuses = [client.post("/api/analyze", data=payload).status_code for _ in range(4)]
    assert statuses[:3] == [200, 200, 200]
    assert statuses[3] == 429

    blocked = client.post("/api/analyze", data=payload)
    assert blocked.status_code == 429
    assert "retry-after" in {key.lower() for key in blocked.headers}
    assert blocked.json()["error"]["code"] == "rate_limited"
