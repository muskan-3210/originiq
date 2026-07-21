# ORACLE backend

FastAPI service that powers ORACLE: it ingests suspicious content (text / URL /
image), traces it against a curated misinformation knowledge base, and returns
the origin → mutation → damage story plus a shareable truth card.

## Two run modes

| Mode | Knowledge base | Cache | Embedder | Needs |
|---|---|---|---|---|
| **lite** (default) | in-memory (`app/data/seed_claims.json`) | in-process | signed hashing | nothing |
| **full** (prod) | Postgres + pgvector | Redis | sentence-transformers | DB, Redis, keys |

Everything is selected by env vars (`REPOSITORY_BACKEND`, `CACHE_BACKEND`,
`NLP_EMBEDDER`) — see `.env.example`. Lite mode boots the entire API — analyze,
truth card, legacy wall, leaderboard, stats — with **no external services**, so
the mobile and web apps have a real backend to build against immediately.

## Run locally (lite)

```bash
python -m venv .venv && . .venv/Scripts/activate     # Windows
pip install -r requirements-lite.txt
cp .env.example .env
uvicorn app.main:app --reload
```

- API: <http://localhost:8000>  ·  interactive docs: <http://localhost:8000/docs>
- Health: `GET /health` → `{"status":"ok"}`

Try it:

```bash
curl -s -F type=text -F "content=5G networks spread the coronavirus" \
  http://localhost:8000/api/analyze | jq
```

## Endpoints (see PRD §10)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/analyze` | optional | Full origin/mutation/damage analysis |
| POST | `/api/truthcard` | optional | Render the shareable verdict PNG |
| POST | `/api/legacy` | required | Record a catch on the Legacy Wall |
| GET | `/api/leaderboard` | none | Top users/countries/schools |
| GET | `/api/stats/global` | none | Dashboard live counter |
| GET | `/health` | none | Health check |

Errors always use the envelope `{"error": {"code", "message"}}`; stack traces
are never returned to clients.

## Tests

```bash
pip install -r requirements-lite.txt -r requirements-dev.txt
python -m pytest            # unit + integration, all in lite mode
```

## Seed data

`app/data/seed_claims.json` holds documented misinformation cases. Validate it
without a database:

```bash
python scripts/seed_database.py --validate-only
```

Each claim must have ≥1 origin (date, platform, country, source URL) and ≥1
damage record, or it's skipped (§9.4). **The figures are provisional** — the
content team verifies each against its cited source before production.

## Full stack / production

1. `REPOSITORY_BACKEND=postgres`, `CACHE_BACKEND=redis`,
   `NLP_EMBEDDER=sentence-transformers` and set `DATABASE_URL`, `REDIS_URL`,
   `FIREBASE_ADMIN_CREDENTIALS_JSON`, `FIREBASE_STORAGE_BUCKET`,
   `CLAIMBUSTER_API_KEY`, `GOOGLE_FACTCHECK_API_KEY`.
2. `alembic upgrade head` (creates the pgvector schema, §9.1).
3. `python scripts/seed_database.py`.
4. `uvicorn app.main:app`. Deploy via `Dockerfile` / `render.yaml` (§17.1).

## Layout

```
app/
├── main.py            # app factory, CORS, error handlers, static
├── api/               # one router per endpoint (§10)
├── core/              # config, logging, errors, security, rate limiting
├── db/                # models (§9.1), repositories (postgres + in-memory), migrations
├── nlp/               # content intake, claim extraction, embedder, origin/mutation/damage
├── integrations/      # claimbuster, google fact check, firebase, firestore
├── media/             # truth card renderer (Pillow)
├── schemas/           # Pydantic request/response models
├── cache/             # redis + in-memory
└── data/              # seed_claims.json
```
