"""Content intake (§14.1): text / URL / image → raw text.

  • text  → used as-is (truncated to the content limit with a notice).
  • url   → fetched and stripped of nav/ads/boilerplate via BeautifulSoup.
  • image → OCR via pytesseract; < 10 recognisable chars is an OCR failure (§15).
"""
from __future__ import annotations

import logging
from dataclasses import dataclass

from app.core.errors import ApiError

logger = logging.getLogger("oracle.nlp.intake")

_MIN_OCR_CHARS = 10
_STRIP_TAGS = ("script", "style", "nav", "footer", "aside", "header", "noscript", "form")


@dataclass
class IntakeResult:
    text: str
    source_type: str
    truncated: bool = False


def extract(
    *,
    content_type: str,
    content: str | None,
    image_bytes: bytes | None,
    filename: str | None,
    max_chars: int,
) -> IntakeResult:
    if content_type == "text":
        return _from_text(content or "", max_chars)
    if content_type == "url":
        return _from_url(content or "", max_chars)
    if content_type == "image":
        return _from_image(image_bytes, max_chars)
    raise ApiError(422, "invalid_type", "Unknown content type.")


def _truncate(text: str, max_chars: int) -> tuple[str, bool]:
    if len(text) > max_chars:
        return text[:max_chars], True
    return text, False


def _from_text(content: str, max_chars: int) -> IntakeResult:
    cleaned = content.strip()
    if not cleaned:
        raise ApiError(422, "empty_content", "There's nothing to check yet.")
    text, truncated = _truncate(cleaned, max_chars)
    return IntakeResult(text=text, source_type="text", truncated=truncated)


def _from_url(url: str, max_chars: int) -> IntakeResult:
    if not url.strip():
        raise ApiError(422, "empty_content", "There's nothing to check yet.")
    try:
        import requests
        from bs4 import BeautifulSoup

        response = requests.get(
            url,
            timeout=10,
            headers={"User-Agent": "ORACLE/0.1 (+https://oracle-app.example)"},
        )
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "lxml")
        for tag in soup(list(_STRIP_TAGS)):
            tag.decompose()
        text = " ".join(soup.get_text(separator=" ").split())
    except ApiError:
        raise
    except Exception as exc:
        logger.info("URL fetch failed for %s: %s", url, exc)
        raise ApiError(
            422, "url_unreadable", "We couldn't read that link — try pasting the text instead."
        ) from exc

    if not text.strip():
        raise ApiError(
            422, "url_unreadable", "That link didn't have any readable text to check."
        )
    truncated_text, truncated = _truncate(text, max_chars)
    return IntakeResult(text=truncated_text, source_type="url", truncated=truncated)


def _from_image(image_bytes: bytes | None, max_chars: int) -> IntakeResult:
    if not image_bytes:
        raise ApiError(422, "empty_content", "No image was received.")
    try:
        import io

        import pytesseract
        from PIL import Image

        image = Image.open(io.BytesIO(image_bytes))
        text = pytesseract.image_to_string(image).strip()
    except ImportError as exc:
        logger.warning("OCR dependencies unavailable: %s", exc)
        raise ApiError(
            503,
            "ocr_unavailable",
            "Image reading isn't available right now — paste the text instead.",
        ) from exc
    except Exception as exc:
        logger.info("OCR failed: %s", exc)
        raise ApiError(
            422, "ocr_failed", "We couldn't read any text in this image."
        ) from exc

    if len(text) < _MIN_OCR_CHARS:
        raise ApiError(422, "ocr_failed", "We couldn't read any text in this image.")
    truncated_text, truncated = _truncate(text, max_chars)
    return IntakeResult(text=truncated_text, source_type="image", truncated=truncated)
