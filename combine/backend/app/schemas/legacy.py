"""Models for POST /api/legacy (§10.3)."""
from __future__ import annotations

from pydantic import BaseModel


class LegacyRequest(BaseModel):
    analysis_id: str
    truth_card_url: str


class LegacyResponse(BaseModel):
    entry_id: str
    legacy_count: int
