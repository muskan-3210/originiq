"""Cache factory — selects Redis or the in-memory client from settings."""
from __future__ import annotations

import logging
from functools import lru_cache

from app.cache.base import CacheClient
from app.cache.memory_client import InMemoryCacheClient
from app.core.config import get_settings

logger = logging.getLogger("oracle.cache")


@lru_cache
def get_cache() -> CacheClient:
    settings = get_settings()
    if settings.cache_backend == "redis":
        try:
            from app.cache.redis_client import RedisCacheClient

            client = RedisCacheClient(settings.redis_url)
            if client.ping():
                logger.info("Using Redis cache.")
                return client
            logger.warning("Redis unreachable; falling back to in-memory cache.")
        except Exception as exc:
            logger.warning("Redis init failed (%s); using in-memory cache.", exc)
    return InMemoryCacheClient()


def reset_cache() -> None:
    """Test helper — clears the cached singleton."""
    get_cache.cache_clear()


__all__ = ["CacheClient", "get_cache", "reset_cache"]
