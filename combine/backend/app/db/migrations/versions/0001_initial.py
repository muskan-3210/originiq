"""initial schema — knowledge base (§9.1)

Revision ID: 0001_initial
Revises:
Create Date: 2026-07-21
"""
from __future__ import annotations

from alembic import op

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";')
    op.execute('CREATE EXTENSION IF NOT EXISTS "vector";')

    op.execute(
        """
        CREATE TABLE claims (
          id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          text               TEXT NOT NULL,
          normalized_text    TEXT NOT NULL,
          embedding          VECTOR(384) NOT NULL,
          language           VARCHAR(8) NOT NULL,
          category           VARCHAR(50) NOT NULL,
          tags               JSONB NOT NULL DEFAULT '[]'::jsonb,
          checkworthy_score  FLOAT,
          verdict            VARCHAR(20) NOT NULL DEFAULT 'false',
          created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
        );
        """
    )
    op.execute(
        "CREATE INDEX idx_claims_embedding ON claims "
        "USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);"
    )
    op.execute("CREATE INDEX idx_claims_language ON claims (language);")
    op.execute("CREATE INDEX idx_claims_category ON claims (category);")

    op.execute(
        """
        CREATE TABLE origins (
          id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          claim_id     UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
          origin_date  DATE NOT NULL,
          platform     VARCHAR(50) NOT NULL,
          country      VARCHAR(2) NOT NULL,
          source_url   TEXT NOT NULL,
          created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
        );
        """
    )
    op.execute("CREATE INDEX idx_origins_claim ON origins (claim_id);")

    op.execute(
        """
        CREATE TABLE mutations (
          id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          claim_id              UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
          version_num           INT NOT NULL,
          text                  TEXT NOT NULL,
          mutation_date         DATE NOT NULL,
          country               VARCHAR(2) NOT NULL,
          language              VARCHAR(8) NOT NULL,
          similarity_to_origin  FLOAT NOT NULL,
          UNIQUE (claim_id, version_num)
        );
        """
    )
    op.execute("CREATE INDEX idx_mutations_claim ON mutations (claim_id);")

    op.execute(
        """
        CREATE TABLE damage_records (
          id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          claim_id     UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
          stat_label   VARCHAR(100) NOT NULL,
          stat_value   NUMERIC NOT NULL,
          description  TEXT NOT NULL,
          source_url   TEXT NOT NULL,
          source_name  VARCHAR(100) NOT NULL
        );
        """
    )
    op.execute("CREATE INDEX idx_damage_claim ON damage_records (claim_id);")

    op.execute(
        """
        CREATE TABLE analysis_log (
          id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          input_hash         VARCHAR(64) NOT NULL,
          matched_claim_id   UUID REFERENCES claims(id),
          similarity_score   FLOAT,
          firebase_uid       VARCHAR(128),
          created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
        );
        """
    )
    op.execute("CREATE INDEX idx_analysis_log_hash ON analysis_log (input_hash);")


def downgrade() -> None:
    op.execute("DROP TABLE IF EXISTS analysis_log;")
    op.execute("DROP TABLE IF EXISTS damage_records;")
    op.execute("DROP TABLE IF EXISTS mutations;")
    op.execute("DROP TABLE IF EXISTS origins;")
    op.execute("DROP TABLE IF EXISTS claims;")
