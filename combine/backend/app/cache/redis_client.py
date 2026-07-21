"""Redis-backed cache & rate-limit counters (§9.3, §14.5).

Key scheme for analysis responses: `analysis:{md5(normalized_content)}`,
TTL 24h — set by the analyze handler (see nlp/pipeline.py). This module only
provides the primitive get/set/incr operations.
"""
from __future__ import annotations

import json
import logging
from typing import Any

logger = logging.getLogger("oracle.cache.redis")


class RedisCacheClient:
    def __init__(self, url: str) -> None:
        import redis  # lazy: only needed when CACHE_BACKEND=redis

        self._redis = redis.Redis.from_url(url, decode_responses=True)

    def get_json(self, key: str) -> dict[str, Any] | None:
        raw = self._redis.get(key)
        if raw is None:
            return None
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            logger.warning("Corrupt cache entry at %s; ignoring.", key)
            return None

    def set_json(self, key: str, value: dict[str, Any], ttl: int) -> None:
        self._redis.set(key, json.dumps(value), ex=ttl if ttl else None)

    def incr_with_window(self, key: str, window_seconds: int) -> tuple[int, int]:
        pipe = self._redis.pipeline()
        pipe.incr(key)
        pipe.ttl(key)
        count, ttl = pipe.execute()
        if ttl is None or ttl < 0:
            # First hit in this window — start the expiry clock.
            self._redis.expire(key, window_seconds)
            ttl = window_seconds
        return int(count), int(ttl)

    def ping(self) -> bool:
        try:
            return bool(self._redis.ping())
        except Exception as exc:  # pragma: no cover - env dependent
            logger.warning("Redis ping failed: %s", exc)
            return False
