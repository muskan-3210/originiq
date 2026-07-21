"""Cache-key generation (§16.1): identical content hashes to the same key."""
from app.nlp.text_utils import content_hash, normalize_text


def test_normalize_collapses_whitespace_and_case():
    assert normalize_text("  Hello   WORLD  ") == "hello world"


def test_content_hash_is_stable_across_formatting():
    assert content_hash("Hello   World") == content_hash("hello world")
    assert content_hash("A\nB") == content_hash("a b")


def test_content_hash_differs_for_different_content():
    assert content_hash("the earth is round") != content_hash("the earth is flat")
