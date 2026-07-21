"""In-memory knowledge base: search, trace assembly, and non-fabrication."""
from app.db.memory_repository import InMemoryKnowledgeRepository
from app.nlp.embedder import get_embedder

KNOWN = "5G mobile networks cause or spread the coronavirus."


def _repo():
    return InMemoryKnowledgeRepository.from_seed_file()


def test_seed_loads_claims():
    repo = _repo()
    assert repo.search_similar(get_embedder().encode(KNOWN), limit=1)


def test_search_matches_known_claim():
    repo = _repo()
    matches = repo.search_similar(get_embedder().encode(KNOWN), limit=3)
    assert matches[0].similarity > 0.75


def test_trace_assembles_origin_and_damage():
    repo = _repo()
    best = repo.search_similar(get_embedder().encode(KNOWN), limit=1)[0]
    trace = repo.get_trace(best.claim.id, similarity=best.similarity)
    assert trace is not None
    assert trace.origin is not None
    assert trace.damage  # at least one documented record
    assert trace.hops_traced == 1 + len(trace.mutations)


def test_global_stats_counts_kb_countries():
    stats = _repo().global_stats()
    assert stats.countries_covered > 0
    assert stats.chains_broken_total == 0  # nothing logged yet
