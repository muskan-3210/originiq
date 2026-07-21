"""ORM models — mirror the PostgreSQL schema in PRD §9.1.

Deviation (documented): `claims.tags` (JSONB) is added because the API
contract (§10.1) and the Origin wireframe (§5) both require a *list* of tag
pills, which the single `category` enum cannot represent. Everything else
matches §9.1 column-for-column.

This module is imported only in Postgres mode (and by Alembic); lite mode never
touches it, so pgvector need not be installed for local demos.
"""
from __future__ import annotations

import uuid
from datetime import date, datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    DATE,
    TIMESTAMP,
    Float,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.config import get_settings
from app.db.base import Base

_EMBEDDING_DIM = get_settings().embedding_dim


class Claim(Base):
    __tablename__ = "claims"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    text: Mapped[str] = mapped_column(Text, nullable=False)
    normalized_text: Mapped[str] = mapped_column(Text, nullable=False)
    embedding: Mapped[list[float]] = mapped_column(Vector(_EMBEDDING_DIM), nullable=False)
    language: Mapped[str] = mapped_column(String(8), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)
    tags: Mapped[list[str]] = mapped_column(
        JSONB, nullable=False, server_default=text("'[]'::jsonb")
    )
    checkworthy_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    verdict: Mapped[str] = mapped_column(String(20), nullable=False, server_default=text("'false'"))
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    origins: Mapped[list[Origin]] = relationship(
        back_populates="claim", cascade="all, delete-orphan"
    )
    mutations: Mapped[list[Mutation]] = relationship(
        back_populates="claim", cascade="all, delete-orphan"
    )
    damage_records: Mapped[list[DamageRecord]] = relationship(
        back_populates="claim", cascade="all, delete-orphan"
    )

    __table_args__ = (
        Index("idx_claims_language", "language"),
        Index("idx_claims_category", "category"),
    )


class Origin(Base):
    __tablename__ = "origins"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    claim_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("claims.id", ondelete="CASCADE"), nullable=False
    )
    origin_date: Mapped[date] = mapped_column(DATE, nullable=False)
    platform: Mapped[str] = mapped_column(String(50), nullable=False)
    country: Mapped[str] = mapped_column(String(2), nullable=False)
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    claim: Mapped[Claim] = relationship(back_populates="origins")

    __table_args__ = (Index("idx_origins_claim", "claim_id"),)


class Mutation(Base):
    __tablename__ = "mutations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    claim_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("claims.id", ondelete="CASCADE"), nullable=False
    )
    version_num: Mapped[int] = mapped_column(Integer, nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    mutation_date: Mapped[date] = mapped_column(DATE, nullable=False)
    country: Mapped[str] = mapped_column(String(2), nullable=False)
    language: Mapped[str] = mapped_column(String(8), nullable=False)
    similarity_to_origin: Mapped[float] = mapped_column(Float, nullable=False)

    claim: Mapped[Claim] = relationship(back_populates="mutations")

    __table_args__ = (
        UniqueConstraint("claim_id", "version_num", name="uq_mutations_claim_version"),
        Index("idx_mutations_claim", "claim_id"),
    )


class DamageRecord(Base):
    __tablename__ = "damage_records"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    claim_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("claims.id", ondelete="CASCADE"), nullable=False
    )
    stat_label: Mapped[str] = mapped_column(String(100), nullable=False)
    stat_value: Mapped[float] = mapped_column(Numeric, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    source_name: Mapped[str] = mapped_column(String(100), nullable=False)

    claim: Mapped[Claim] = relationship(back_populates="damage_records")

    __table_args__ = (Index("idx_damage_claim", "claim_id"),)


class AnalysisLog(Base):
    __tablename__ = "analysis_log"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()")
    )
    input_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    matched_claim_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("claims.id"), nullable=True
    )
    similarity_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    firebase_uid: Mapped[str | None] = mapped_column(String(128), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), nullable=False, server_default=text("now()")
    )

    __table_args__ = (Index("idx_analysis_log_hash", "input_hash"),)
