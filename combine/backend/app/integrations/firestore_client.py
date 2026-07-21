"""Firestore access for the Legacy Wall and leaderboard (§9.2, §14.8).

Uses firebase-admin Firestore when configured; otherwise an in-process store so
the endpoints work in local/lite mode. Legacy entries are keyed by analysis_id
per user, giving idempotent writes and natural duplicate detection (§10.3, 409).
"""
from __future__ import annotations

import logging
import uuid
from functools import lru_cache

from app.domain import LeaderboardEntryData
from app.integrations.firebase_admin_client import get_firebase_client

logger = logging.getLogger("oracle.integrations.firestore")

_NS = uuid.UUID("9a8b7c6d-5e4f-4a3b-2c1d-0e9f8a7b6c5d")


class DuplicateLegacyEntry(Exception):
    """Raised when the same analysis is added to a user's wall twice."""


class FirestoreClient:
    def __init__(self) -> None:
        # In-memory fallback: uid -> {analysis_id: entry}
        self._mem: dict[str, dict[str, dict]] = {}

    def _db(self):
        client = get_firebase_client()
        app = client._ensure_app()  # noqa: SLF001 - internal reuse of the shared app
        if app is None:
            return None
        try:
            from firebase_admin import firestore

            return firestore.client(app)
        except Exception as exc:  # pragma: no cover - env dependent
            logger.warning("Firestore unavailable: %s", exc)
            return None

    # ── Legacy Wall ───────────────────────────────────────────────────────
    def add_legacy_entry(
        self, uid: str, analysis_id: str, verdict: str, truth_card_url: str
    ) -> tuple[str, int]:
        entry_id = str(uuid.uuid5(_NS, f"{uid}:{analysis_id}"))
        db = self._db()
        if db is not None:
            entries_ref = db.collection("legacyWall").document(uid).collection("entries")
            doc = entries_ref.document(analysis_id)
            if doc.get().exists:
                raise DuplicateLegacyEntry(analysis_id)
            doc.set(
                {
                    "claimId": analysis_id,
                    "verdict": verdict,
                    "truthCardUrl": truth_card_url,
                    "caughtAt": _server_timestamp(),
                }
            )
            count = self._count_entries_firestore(db, uid)
            db.collection("users").document(uid).set({"legacyCount": count}, merge=True)
            return entry_id, count

        # In-memory fallback
        wall = self._mem.setdefault(uid, {})
        if analysis_id in wall:
            raise DuplicateLegacyEntry(analysis_id)
        wall[analysis_id] = {
            "entryId": entry_id,
            "claimId": analysis_id,
            "verdict": verdict,
            "truthCardUrl": truth_card_url,
        }
        return entry_id, len(wall)

    @staticmethod
    def _count_entries_firestore(db, uid: str) -> int:
        entries = db.collection("legacyWall").document(uid).collection("entries").stream()
        return sum(1 for _ in entries)

    # ── Leaderboard ───────────────────────────────────────────────────────
    def read_leaderboard(self, scope: str, limit: int) -> list[LeaderboardEntryData]:
        db = self._db()
        if db is not None:
            try:
                from google.cloud.firestore_v1 import Query

                docs = (
                    db.collection("leaderboardCache")
                    .order_by("catchCount", direction=Query.DESCENDING)
                    .limit(limit)
                    .stream()
                )
                entries = []
                for rank, doc in enumerate(docs, start=1):
                    data = doc.to_dict()
                    entries.append(
                        LeaderboardEntryData(
                            rank=rank,
                            display_name=data.get("displayName", "anonymous"),
                            catch_count=int(data.get("catchCount", 0)),
                            country=data.get("country"),
                        )
                    )
                return entries
            except Exception as exc:  # pragma: no cover - env dependent
                logger.warning("Leaderboard read failed: %s", exc)
                return []

        # In-memory fallback: rank users by their catch count.
        ranked = sorted(
            ((uid, len(wall)) for uid, wall in self._mem.items()),
            key=lambda pair: pair[1],
            reverse=True,
        )[:limit]
        return [
            LeaderboardEntryData(rank=i, display_name="anonymous", catch_count=count)
            for i, (uid, count) in enumerate(ranked, start=1)
        ]


def _server_timestamp():
    from firebase_admin import firestore

    return firestore.SERVER_TIMESTAMP


@lru_cache
def get_firestore_client() -> FirestoreClient:
    return FirestoreClient()
