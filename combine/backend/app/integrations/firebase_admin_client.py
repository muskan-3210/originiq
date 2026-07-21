"""Thin wrapper over firebase-admin (§13.3).

Lazy-initialised and fully optional: if credentials aren't configured (local
dev) or the package isn't installed (lite mode), every method degrades to a
safe no-op / `None` rather than raising. Token verification and Storage upload
callers handle the `None` path explicitly.
"""
from __future__ import annotations

import json
import logging
import threading
from functools import lru_cache

from app.core.config import get_settings

logger = logging.getLogger("oracle.firebase")


class FirebaseClient:
    def __init__(self) -> None:
        self._app: object | None = None
        self._init_attempted = False
        self._lock = threading.Lock()

    @property
    def configured(self) -> bool:
        s = get_settings()
        return bool(s.firebase_admin_credentials_json or s.firebase_admin_credentials_file)

    def _ensure_app(self) -> object | None:
        if self._init_attempted:
            return self._app
        with self._lock:
            if self._init_attempted:
                return self._app
            self._init_attempted = True
            s = get_settings()
            try:
                import firebase_admin
                from firebase_admin import credentials

                if s.firebase_admin_credentials_json:
                    cred = credentials.Certificate(
                        json.loads(s.firebase_admin_credentials_json)
                    )
                elif s.firebase_admin_credentials_file:
                    cred = credentials.Certificate(s.firebase_admin_credentials_file)
                else:
                    return None

                options = (
                    {"storageBucket": s.firebase_storage_bucket}
                    if s.firebase_storage_bucket
                    else None
                )
                self._app = firebase_admin.initialize_app(cred, options)
                logger.info("Firebase Admin initialised.")
            except Exception as exc:  # pragma: no cover - env dependent
                logger.warning("Firebase Admin not initialised: %s", exc)
                self._app = None
            return self._app

    def verify_token(self, token: str) -> dict | None:
        """Return decoded claims for a valid Firebase ID token, else None."""
        app = self._ensure_app()
        if app is None:
            return None
        try:
            from firebase_admin import auth

            return auth.verify_id_token(token, app=app)
        except Exception as exc:  # invalid/expired/malformed token
            logger.info("Token verification failed: %s", exc)
            return None

    def upload_bytes(
        self, path: str, data: bytes, content_type: str = "image/png"
    ) -> str | None:
        """Upload to Firebase Storage and return a public URL, or None if unavailable."""
        app = self._ensure_app()
        if app is None:
            return None
        try:
            from firebase_admin import storage

            blob = storage.bucket(app=app).blob(path)
            blob.upload_from_string(data, content_type=content_type)
            blob.make_public()
            return blob.public_url
        except Exception as exc:  # pragma: no cover - env dependent
            logger.warning("Storage upload failed: %s", exc)
            return None


@lru_cache
def get_firebase_client() -> FirebaseClient:
    return FirebaseClient()
