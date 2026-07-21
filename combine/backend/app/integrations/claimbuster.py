"""ClaimBuster check-worthiness scoring (§14.2).

Returns a 0–1 score; the pipeline treats < 0.5 as "not a factual claim" and
short-circuits to `unverified` without a wasted KB search. When no API key is
configured, a transparent lexical heuristic is used instead so the pipeline
still functions locally.
"""
from __future__ import annotations

import logging
import re
from urllib.parse import quote

from app.core.config import get_settings

logger = logging.getLogger("oracle.integrations.claimbuster")

_API_URL = "https://idir.uta.edu/claimbuster/api/v2/score/text/"
_CLAIM_VERB_RE = re.compile(
    r"\b(is|are|was|were|causes?|cured?|cures?|kills?|prevents?|will|can|"
    r"has|have|contains?|linked|proven?|found|shows?)\b"
)


def score(text: str) -> float:
    settings = get_settings()
    if settings.claimbuster_api_key:
        api_score = _score_via_api(text, settings.claimbuster_api_key)
        if api_score is not None:
            return api_score
    return heuristic_score(text)


def _score_via_api(text: str, api_key: str) -> float | None:
    try:
        import httpx

        response = httpx.get(
            f"{_API_URL}{quote(text[:1500])}",
            headers={"x-api-key": api_key},
            timeout=8.0,
        )
        response.raise_for_status()
        results = response.json().get("results", [])
        if results:
            return float(results[0]["score"])
    except Exception as exc:  # network / parse / quota
        logger.info("ClaimBuster API unavailable (%s); using heuristic.", exc)
    return None


def heuristic_score(text: str) -> float:
    """Lexical proxy for check-worthiness. Short/empty/non-assertive text scores low."""
    stripped = text.strip()
    if len(stripped) < 8:
        return 0.1
    words = stripped.split()
    score_value = 0.0
    if any(char.isdigit() for char in stripped):
        score_value += 0.35
    if _CLAIM_VERB_RE.search(stripped.lower()):
        score_value += 0.25
    if any(word[:1].isupper() for word in words[1:]):  # a proper-noun-ish token
        score_value += 0.20
    if 6 <= len(words) <= 60:
        score_value += 0.20
    return min(score_value, 0.99)
