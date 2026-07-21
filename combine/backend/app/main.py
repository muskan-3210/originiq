"""ORACLE API application factory."""
from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app import __version__
from app.api import analyze, health, leaderboard, legacy, stats, truthcard
from app.core.config import get_settings
from app.core.errors import (
    ApiError,
    api_error_handler,
    unhandled_error_handler,
    validation_error_handler,
)
from app.core.logging import configure_logging

logger = logging.getLogger("oracle")

_DESCRIPTION = (
    "ORACLE traces where a piece of misinformation was born, how it mutated as it "
    "spread, and the real-world damage it caused. This API powers the mobile app and "
    "the public web dashboard."
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    configure_logging(settings.log_level)
    logger.info(
        "Starting ORACLE API (env=%s, repo=%s, cache=%s, embedder=%s)",
        settings.environment,
        settings.repository_backend,
        settings.cache_backend,
        settings.nlp_embedder,
    )
    # Warm the knowledge base (loads the seed KB in memory mode).
    from app.db import get_repository

    get_repository()
    yield
    logger.info("ORACLE API shutting down.")


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title="ORACLE API",
        version=__version__,
        description=_DESCRIPTION,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.add_exception_handler(ApiError, api_error_handler)
    app.add_exception_handler(RequestValidationError, validation_error_handler)
    app.add_exception_handler(Exception, unhandled_error_handler)

    # /health at the root (§10.6); everything else under the API base path.
    app.include_router(health.router)
    base = settings.api_base_path
    for module in (analyze, truthcard, legacy, leaderboard, stats):
        app.include_router(module.router, prefix=base)

    # Serve locally generated truth cards when Firebase Storage isn't configured.
    storage_dir = Path(settings.local_storage_dir)
    storage_dir.mkdir(parents=True, exist_ok=True)
    app.mount("/static", StaticFiles(directory=str(storage_dir)), name="static")

    @app.get("/", include_in_schema=False)
    async def root() -> dict[str, str]:
        return {"name": "ORACLE API", "version": __version__, "docs": "/docs"}

    return app


app = create_app()
