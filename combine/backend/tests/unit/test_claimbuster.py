"""Check-worthiness heuristic boundary cases (§16.1)."""
from app.integrations.claimbuster import heuristic_score


def test_trivial_text_scores_below_threshold():
    assert heuristic_score("lol") < 0.5
    assert heuristic_score("ok") < 0.5


def test_factual_claim_scores_at_or_above_threshold():
    score = heuristic_score(
        "The COVID-19 vaccine contains 5000 microchips that track your location."
    )
    assert score >= 0.5
