"""Knowledge-base repository factory (§9).

Selects the Postgres/pgvector repository or the in-memory one based on
`REPOSITORY_BACKEND`. Imports are lazy so lite mode never needs SQLAlchemy /
pgvector, and full mode never loads the in-memory seed loader.
"""
from __future__ import annotations

import logging
from functools import lru_cache

from app.core.config import get_settings
from app.db.repository import KnowledgeRepository

logger = logging.getLogger("oracle.db")


@lru_cache
def get_repository() -> KnowledgeRepository:
    settings = get_settings()
    if settings.repository_backend == "postgres":
        from app.db.postgres_repository import PostgresKnowledgeRepository

        logger.info("Using Postgres/pgvector knowledge base.")
        return PostgresKnowledgeRepository()

    from app.db.memory_repository import InMemoryKnowledgeRepository

    logger.info("Using in-memory knowledge base (lite mode).")
    return InMemoryKnowledgeRepository.from_seed_file()


def reset_repository() -> None:
    """Test helper — clears the cached singleton."""
    get_repository.cache_clear()


__all__ = ["KnowledgeRepository", "get_repository", "reset_repository"]
