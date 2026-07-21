"""Claim embedding (§14.3).

Two interchangeable implementations behind one interface:
  • SentenceTransformerEmbedder — all-MiniLM-L6-v2, 384-dim (production).
  • HashingEmbedder — deterministic signed feature hashing, 384-dim, zero deps
    beyond the stdlib (local/demo). Similar texts share tokens → high cosine.

Both are L2-normalised so cosine similarity is a plain dot product.
"""
from __future__ import annotations

import hashlib
import math
import re
from functools import lru_cache
from typing import Protocol

from app.core.config import get_settings

_TOKEN_RE = re.compile(r"[a-z0-9]+")


class Embedder(Protocol):
    dim: int

    def encode(self, text: str) -> list[float]: ...

    def encode_batch(self, texts: list[str]) -> list[list[float]]: ...


class HashingEmbedder:
    """Signed feature hashing — a lightweight stand-in for a real sentence model."""

    def __init__(self, dim: int = 384) -> None:
        self.dim = dim

    def encode(self, text: str) -> list[float]:
        vec = [0.0] * self.dim
        tokens = _TOKEN_RE.findall(text.lower())
        if not tokens:
            return vec
        for token in tokens:
            digest = int(hashlib.md5(token.encode("utf-8")).hexdigest(), 16)
            index = digest % self.dim
            sign = 1.0 if (digest >> 7) & 1 else -1.0
            vec[index] += sign
        norm = math.sqrt(sum(component * component for component in vec))
        if norm > 0:
            vec = [component / norm for component in vec]
        return vec

    def encode_batch(self, texts: list[str]) -> list[list[float]]:
        return [self.encode(text) for text in texts]


class SentenceTransformerEmbedder:
    """Production embedder — sentence-transformers all-MiniLM-L6-v2."""

    def __init__(self, model_name: str = "all-MiniLM-L6-v2") -> None:
        from sentence_transformers import SentenceTransformer  # lazy / heavy

        self._model = SentenceTransformer(model_name)
        self.dim = self._model.get_sentence_embedding_dimension()

    def encode(self, text: str) -> list[float]:
        return self._model.encode(
            text, normalize_embeddings=True, convert_to_numpy=True
        ).tolist()

    def encode_batch(self, texts: list[str]) -> list[list[float]]:
        return self._model.encode(
            texts, normalize_embeddings=True, convert_to_numpy=True
        ).tolist()


@lru_cache
def get_embedder() -> Embedder:
    settings = get_settings()
    if settings.nlp_embedder == "sentence-transformers":
        try:
            return SentenceTransformerEmbedder()
        except Exception as exc:  # pragma: no cover - env dependent
            import logging

            logging.getLogger("oracle.nlp").warning(
                "sentence-transformers unavailable (%s); using hashing embedder.", exc
            )
    return HashingEmbedder(dim=settings.embedding_dim)
