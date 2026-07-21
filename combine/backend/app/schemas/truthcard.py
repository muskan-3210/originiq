"""Models for POST /api/truthcard (§10.2)."""
from __future__ import annotations

from pydantic import BaseModel


class TruthCardRequest(BaseModel):
    analysis_id: str


class TruthCardResponse(BaseModel):
    image_url: str
