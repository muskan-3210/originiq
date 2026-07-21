"""Postgres + pgvector implementation of the knowledge repository (§14.3–§14.6)."""
from __future__ import annotations

from collections.abc import Sequence
from datetime import date

from sqlalchemy import func, select

from app.db.models import AnalysisLog, Claim, Mutation, Origin
from app.db.session import session_scope
from app.domain import (
    ClaimData,
    ClaimMatch,
    DamageData,
    GlobalStatsData,
    MutationData,
    OriginData,
    Trace,
)

_CAUGHT_VERDICTS = ("false", "misleading")


def _to_claim_data(claim: Claim) -> ClaimData:
    return ClaimData(
        id=str(claim.id),
        text=claim.text,
        normalized_text=claim.normalized_text,
        language=claim.language,
        category=claim.category,
        verdict=claim.verdict,
        tags=list(claim.tags or []),
        checkworthy_score=claim.checkworthy_score,
    )


class PostgresKnowledgeRepository:
    def search_similar(
        self, embedding: Sequence[float], limit: int = 5
    ) -> list[ClaimMatch]:
        query = list(embedding)
        with session_scope() as session:
            distance = Claim.embedding.cosine_distance(query).label("distance")
            rows = session.execute(
                select(Claim, distance).order_by(distance).limit(limit)
            ).all()
            # cosine similarity = 1 - cosine distance
            return [
                ClaimMatch(claim=_to_claim_data(claim), similarity=1.0 - float(dist))
                for claim, dist in rows
            ]

    def get_trace(self, claim_id: str, similarity: float = 1.0) -> Trace | None:
        with session_scope() as session:
            claim = session.get(Claim, claim_id)
            if claim is None:
                return None

            origins = sorted(claim.origins, key=lambda o: o.origin_date)
            origin = origins[0] if origins else None
            origin_data = (
                OriginData(
                    platform=origin.platform,
                    country=origin.country,
                    date=origin.origin_date,
                    source_url=origin.source_url,
                )
                if origin
                else None
            )

            mutations = [
                MutationData(
                    version=m.version_num,
                    country=m.country,
                    date=m.mutation_date,
                    text_excerpt=m.text,
                    similarity_to_origin=m.similarity_to_origin,
                    language=m.language,
                )
                for m in sorted(claim.mutations, key=lambda m: m.mutation_date)
            ]

            damage = [
                DamageData(
                    label=d.stat_label,
                    value=float(d.stat_value),
                    description=d.description,
                    source_name=d.source_name,
                    source_url=d.source_url,
                )
                for d in claim.damage_records
            ]

            return Trace(
                claim=_to_claim_data(claim),
                origin=origin_data,
                mutations=mutations,
                damage=damage,
                similarity=similarity,
            )

    def log_analysis(
        self,
        input_hash: str,
        matched_claim_id: str | None,
        similarity_score: float | None,
        firebase_uid: str | None,
    ) -> None:
        with session_scope() as session:
            session.add(
                AnalysisLog(
                    input_hash=input_hash,
                    matched_claim_id=matched_claim_id,
                    similarity_score=similarity_score,
                    firebase_uid=firebase_uid,
                )
            )

    def global_stats(self) -> GlobalStatsData:
        with session_scope() as session:
            caught = (
                select(func.count())
                .select_from(AnalysisLog)
                .join(Claim, Claim.id == AnalysisLog.matched_claim_id)
                .where(Claim.verdict.in_(_CAUGHT_VERDICTS))
            )
            total = session.execute(caught).scalar_one()
            today = session.execute(
                caught.where(func.date(AnalysisLog.created_at) == date.today())
            ).scalar_one()

            origin_countries = select(Origin.country).distinct()
            mutation_countries = select(Mutation.country).distinct()
            countries = session.execute(
                origin_countries.union(mutation_countries)
            ).all()

            return GlobalStatsData(
                chains_broken_today=int(today),
                chains_broken_total=int(total),
                countries_covered=len({row[0] for row in countries}),
            )
