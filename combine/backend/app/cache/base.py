"""Cache interface shared by the Redis and in-memory implementations."""
from __future__ import annotations

from typing import Any, Protocol, runtime_checkable


@runtime_checkable
class CacheClient(Protocol):
    def get_json(self, key: str) -> dict[str, Any] | None: ...

    def set_json(self, key: str, value: dict[str, Any], ttl: int) -> None: ...

    def incr_with_window(self, key: str, window_seconds: int) -> tuple[int, int]:
        """Increment a counter, returning (count, seconds_until_reset)."""
        ...

    def ping(self) -> bool: ...
