"""Text normalization & content hashing (§14.5).

The cache key is `md5` of the normalized (lowercased, whitespace-collapsed)
content, so the same viral message pasted with trivial formatting differences
hits the same cache entry.
"""
from __future__ import annotations

import hashlib
import re

_WHITESPACE = re.compile(r"\s+")


def normalize_text(text: str) -> str:
    return _WHITESPACE.sub(" ", text.strip().lower())


def content_hash(text: str) -> str:
    return hashlib.md5(normalize_text(text).encode("utf-8")).hexdigest()
