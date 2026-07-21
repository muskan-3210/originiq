"""Google Fact Check Tools API — secondary check for KB near-misses (§14.3).

If the KB similarity is below threshold, the pipeline consults this API. A hit
lifts the result out of the "New territory" state (§4.2) with a real verdict and
publisher attribution — but never a fabricated origin/mutation/damage story.
Returns None when no key is configured or nothing is found.
"""
from __future__ import annotations

import logging
from dataclasses import dataclass

from app.core.config import get_settings

logger = logging.getLogger("oracle.integrations.factcheck")

_API_URL = "https://factchecktools.googleapis.com/v1alpha1/claims:search"


@dataclass(frozen=True)
class FactCheckResult:
    verdict: str
    publisher: str
    url: str
    title: str


def lookup(text: str) -> FactCheckResult | None:
    settings = get_settings()
    if not settings.google_factcheck_api_key:
        return None
    try:
        import httpx

        response = httpx.get(
            _API_URL,
            params={
                "query": text[:200],
                "key": settings.google_factcheck_api_key,
                "languageCode": "en",
            },
            timeout=8.0,
        )
        response.raise_for_status()
        for claim in response.json().get("claims", []):
            for review in claim.get("claimReview", []):
                verdict = _map_rating(review.get("textualRating", ""))
                if verdict:
                    return FactCheckResult(
                        verdict=verdict,
                        publisher=review.get("publisher", {}).get("name", "a fact-checker"),
                        url=review.get("url", ""),
                        title=review.get("title", ""),
                    )
    except Exception as exc:
        logger.info("Google Fact Check unavailable: %s", exc)
    return None


def _map_rating(rating: str) -> str | None:
    text = rating.lower()
    if any(k in text for k in ("false", "pants on fire", "incorrect", "no evidence")):
        return "false"
    if any(k in text for k in ("misleading", "mixture", "partly", "half")):
        return "misleading"
    if any(k in text for k in ("true", "correct", "accurate")):
        return "true"
    return None
