"""Request/response models for POST /api/analyze (§10.1)."""
from __future__ import annotations

from pydantic import BaseModel, Field

from app.schemas.common import Verdict


class OriginOut(BaseModel):
    platform: str
    country: str
    date: str  # ISO-8601 date
    tags: list[str] = Field(default_factory=list)
    hops_traced: int


class MutationOut(BaseModel):
    version: int
    country: str
    date: str
    text_excerpt: str
    similarity_to_origin: float


class DamageOut(BaseModel):
    label: str
    value: float
    description: str
    source_name: str
    source_url: str


class SourceOut(BaseModel):
    """Populated only on the Google Fact Check fallback path (§14.3)."""

    name: str
    url: str
    title: str = ""


class AnalyzeResponse(BaseModel):
    id: str
    verdict: Verdict
    cached: bool
    origin: OriginOut | None = None
    mutations: list[MutationOut] = Field(default_factory=list)
    damage: list[DamageOut] = Field(default_factory=list)
    truth_card_ready: bool
    # Optional, additive extension fields — safe for older clients to ignore.
    notices: list[str] | None = None
    sources: list[SourceOut] | None = None

    model_config = {
        "json_schema_extra": {
            "example": {
                "id": "b3f1e0a2-1c3d-5a5e-8b7c-1d2e3f4a5b6c",
                "verdict": "false",
                "cached": False,
                "origin": {
                    "platform": "whatsapp",
                    "country": "IN",
                    "date": "2020-03-14",
                    "tags": ["health-misinformation", "covid-era"],
                    "hops_traced": 6,
                },
                "mutations": [
                    {
                        "version": 2,
                        "country": "BR",
                        "date": "2020-04-02",
                        "text_excerpt": "Drinking warm water flushes out the virus...",
                        "similarity_to_origin": 0.81,
                    }
                ],
                "damage": [
                    {
                        "label": "People misled",
                        "value": 47000,
                        "description": "Shares tracked across public groups.",
                        "source_name": "Reuters",
                        "source_url": "https://www.reuters.com/fact-check",
                    }
                ],
                "truth_card_ready": True,
            }
        }
    }
