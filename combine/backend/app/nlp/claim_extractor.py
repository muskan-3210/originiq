"""Claim extraction & check-worthiness (§14.2).

1. Detect language (langdetect; falls back to the hint, then English).
2. Strip forward-chain noise, greetings, emoji and emotional trigger words to
   reduce embedding noise.
3. Score check-worthiness via ClaimBuster (or the heuristic fallback).
"""
from __future__ import annotations

import logging
import re
from dataclasses import dataclass

from app.integrations import claimbuster

logger = logging.getLogger("oracle.nlp.extract")

# Emotional/viral trigger words removed before embedding (curated, conservative).
_TRIGGER_WORDS = {
    "urgent", "shocking", "breaking", "warning", "alert", "please", "forward",
    "share", "must", "read", "immediately", "attention", "beware", "viral",
    "exclusive", "confirmed", "exposed", "banned", "secret",
}
_FORWARD_MARKERS = re.compile(
    r"(forwarded (?:as received|many times)|>{2,}|^fw:|^fwd:)", re.IGNORECASE | re.MULTILINE
)
_EMOJI_RE = re.compile(
    "[\U0001F000-\U0001FAFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF]", flags=re.UNICODE
)
_WHITESPACE = re.compile(r"\s+")


@dataclass
class ExtractedClaim:
    text: str
    language: str
    checkworthy_score: float


def extract(raw_text: str, language_hint: str | None = None) -> ExtractedClaim:
    language = _detect_language(raw_text, language_hint)
    cleaned = _clean(raw_text)
    return ExtractedClaim(
        text=cleaned,
        language=language,
        checkworthy_score=claimbuster.score(cleaned),
    )


def _detect_language(text: str, hint: str | None) -> str:
    try:
        from langdetect import DetectorFactory, detect

        DetectorFactory.seed = 0  # deterministic
        return detect(text)
    except Exception:
        return hint or "en"


def _clean(text: str) -> str:
    text = _FORWARD_MARKERS.sub(" ", text)
    text = _EMOJI_RE.sub(" ", text)
    tokens = _WHITESPACE.sub(" ", text).strip().split(" ")
    kept = [tok for tok in tokens if tok.lower().strip(".,!?:;\"'") not in _TRIGGER_WORDS]
    cleaned = " ".join(kept).strip()
    return cleaned or text.strip()
