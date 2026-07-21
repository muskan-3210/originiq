"""Application settings, loaded from environment / `.env` (§17.1 env vars).

All external dependencies are optional so the API can boot in a zero-infra
"lite" mode (in-memory KB + cache + hashing embedder) for local demos.
"""
from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Annotated, Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict

# Resolved relative to this file (backend/app/core/config.py -> backend/.env), not the
# process's working directory — uvicorn may be launched from any cwd (repo root, an IDE
# run config, a monorepo task runner), and a plain ".env" would silently go unfound.
_ENV_FILE = Path(__file__).resolve().parent.parent.parent / ".env"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=_ENV_FILE,
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    # ── App ──
    environment: str = "development"
    log_level: str = "INFO"
    api_base_path: str = "/api"
    # NoDecode: env values are a plain comma-separated string (e.g. Render's env var
    # editor), not JSON — without this, pydantic-settings tries json.loads() on the raw
    # value before the validator below ever runs, and raises on any non-JSON input.
    cors_origins: Annotated[list[str], NoDecode] = Field(
        default_factory=lambda: ["http://localhost:5173"]
    )

    # ── Knowledge base repository ──
    repository_backend: Literal["memory", "postgres"] = "memory"
    database_url: str = "postgresql+psycopg2://oracle:oracle@localhost:5432/oracle"

    # ── Cache ──
    cache_backend: Literal["memory", "redis"] = "memory"
    redis_url: str = "redis://localhost:6379/0"
    cache_ttl_seconds: int = 86400

    # ── NLP ──
    nlp_embedder: Literal["hashing", "sentence-transformers"] = "hashing"
    similarity_threshold: float = 0.75
    checkworthiness_threshold: float = 0.5

    # ── External fact-check APIs (optional) ──
    claimbuster_api_key: str | None = None
    google_factcheck_api_key: str | None = None

    # ── Firebase Admin (optional locally) ──
    firebase_admin_credentials_json: str | None = None
    firebase_admin_credentials_file: str | None = None
    firebase_storage_bucket: str | None = None
    local_storage_dir: str = ".local_storage"
    public_base_url: str = "http://localhost:8000"

    # ── Rate limiting (§14.5) ──
    rate_limit_max_requests: int = 30
    rate_limit_window_seconds: int = 600

    # ── Content limits ──
    max_content_chars: int = 5000
    max_image_bytes: int = 10 * 1024 * 1024

    @field_validator("cors_origins", mode="before")
    @classmethod
    def _split_csv(cls, value: object) -> object:
        if isinstance(value, str):
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value

    @property
    def is_production(self) -> bool:
        return self.environment.lower() == "production"

    @property
    def embedding_dim(self) -> int:
        # all-MiniLM-L6-v2 and the hashing fallback both produce 384-dim vectors.
        return 384


@lru_cache
def get_settings() -> Settings:
    """Cached singleton. `get_settings.cache_clear()` resets it in tests."""
    return Settings()
