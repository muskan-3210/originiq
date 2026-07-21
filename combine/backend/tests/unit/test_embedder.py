"""Hashing embedder: correct dimensionality and sensible similarity ordering."""
import numpy as np

from app.nlp.embedder import HashingEmbedder


def _cosine(a, b):
    return float(np.dot(a, b))  # vectors are L2-normalised


def test_dimensionality():
    assert len(HashingEmbedder().encode("anything at all")) == 384


def test_similar_texts_score_higher_than_unrelated():
    embedder = HashingEmbedder()
    base = embedder.encode("the quick brown fox")
    near = embedder.encode("the quick brown fox jumps over")
    far = embedder.encode("completely unrelated sentence about taxes")
    assert _cosine(base, near) > _cosine(base, far)


def test_empty_text_is_zero_vector():
    assert not any(HashingEmbedder().encode("   "))
