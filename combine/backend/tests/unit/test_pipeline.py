"""Analysis pipeline: matching, unverified path, non-fabrication, caching."""
from app.nlp import pipeline

KNOWN = "5G mobile networks cause or spread the coronavirus."


def test_known_claim_returns_full_story():
    result = pipeline.analyze(content_type="text", content=KNOWN)
    assert result["verdict"] == "false"
    assert result["origin"] is not None
    assert result["origin"]["platform"] == "facebook"
    assert result["damage"], "matched claims must carry documented damage"
    assert result["truth_card_ready"] is True
    assert result["cached"] is False


def test_nonfactual_text_is_unverified():
    result = pipeline.analyze(content_type="text", content="lol ok haha")
    assert result["verdict"] == "unverified"
    assert result["origin"] is None
    assert result["mutations"] == []
    assert result["truth_card_ready"] is False


def test_identical_content_is_served_from_cache():
    first = pipeline.analyze(content_type="text", content=KNOWN)
    second = pipeline.analyze(content_type="text", content=KNOWN)
    assert first["cached"] is False
    assert second["cached"] is True
    assert first["id"] == second["id"]  # deterministic id from content hash


def test_damage_is_never_fabricated_for_unverified():
    result = pipeline.analyze(content_type="text", content="wibble wobble zorp")
    assert result["damage"] == []
