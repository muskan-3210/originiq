"""In-process TTL cache — the zero-infra fallback for local dev / demos.

Thread-safe, good enough for a single-process uvicorn. Production uses Redis
so the cache (and rate-limit counters) are shared across workers.
"""
from __future__ import annotations

import threading
import time
from typing import Any


class InMemoryCacheClient:
    def __init__(self) -> None:
        self._store: dict[str, tuple[float | None, dict[str, Any]]] = {}
        self._counters: dict[str, tuple[float, int]] = {}
        self._lock = threading.Lock()

    def get_json(self, key: str) -> dict[str, Any] | None:
        with self._lock:
            item = self._store.get(key)
            if item is None:
                return None
            expires_at, value = item
            if expires_at is not None and expires_at < time.time():
                self._store.pop(key, None)
                return None
            return value

    def set_json(self, key: str, value: dict[str, Any], ttl: int) -> None:
        with self._lock:
            self._store[key] = (time.time() + ttl if ttl else None, value)

    def incr_with_window(self, key: str, window_seconds: int) -> tuple[int, int]:
        now = time.time()
        with self._lock:
            window_start, count = self._counters.get(key, (now, 0))
            if now - window_start >= window_seconds:
                window_start, count = now, 0
            count += 1
            self._counters[key] = (window_start, count)
            reset_in = int(window_seconds - (now - window_start))
            return count, max(reset_in, 1)

    def ping(self) -> bool:
        return True
