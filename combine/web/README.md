# ORACLE — web dashboard

The public web dashboard for **ORACLE — the fake news time machine**. It shows the
aggregate global impact of misinformation-fighting (a live "chains broken" counter), a
spread map, a leaderboard, and public API docs — the credible public artifact for
hackathon judges, and a way to understand the product without installing the mobile app.

Part of the ORACLE monorepo (`mobile/`, `backend/`, `web/`, `docs/`) — see
[`../docs/PRD.md`](../docs/PRD.md) for the full product spec.

## Stack

Vite + React 18 + TypeScript + Tailwind CSS. Data fetching via axios +
`@tanstack/react-query`. Map via Mapbox GL JS (`react-map-gl`). Charts via Recharts + D3.

## Getting started

```bash
npm install
npm run dev
```

The dev server runs at `http://localhost:5173`. The app is designed to render fully —
navigable, no crashes — even with **no backend running and no Mapbox token set**: every
data-dependent view falls back to a loading, empty, or graceful-fallback state instead.

### Environment variables

Copy `.env.example` to `.env` and fill in what you have:

| Variable | Required for | Behavior when unset |
|---|---|---|
| `VITE_API_BASE_URL` | Live stats, leaderboard, API docs examples | Falls back to `http://localhost:8000/api`; pages show loading/"connecting…" states if nothing answers there |
| `VITE_MAPBOX_TOKEN` | The live spread map | Spread map page shows a styled "add a Mapbox token" panel instead of crashing |
| `VITE_FIREBASE_*` (6 vars) | Firebase-backed features | Firebase simply doesn't initialize; the app continues to work without it |

This dashboard expects the ORACLE backend (FastAPI) to be reachable at
`VITE_API_BASE_URL` — see `../backend`. Without it, `/`, `/leaderboard`, and the Swagger
link on `/api` show their offline/loading states rather than data.

## Scripts

| Command | What it does |
|---|---|
| `npm run dev` | Start the Vite dev server with HMR |
| `npm run build` | Type-check (`tsc -b`) then build a production bundle to `dist/` |
| `npm run preview` | Serve the production build locally |
| `npm run lint` | Run ESLint over `src/` |

## Project structure

```
src/
├── main.tsx          # React root: QueryClientProvider + BrowserRouter
├── App.tsx           # Route table
├── index.css         # Tailwind directives + base dark styles
├── lib/               # apiClient, types, firebase, category color/label maps
├── hooks/             # useGlobalStats, useLeaderboard (React Query)
├── components/        # Nav, Footer, Layout, StatCounter, VerdictBadge, ...
└── pages/              # Home, SpreadMap, Leaderboard, ApiDocs
```

## Design system

Dark-first "mystical-dark" theme shared with the mobile app — see `tailwind.config.js`
for the color/radius tokens and `../docs/PRD.md` §8 for the full spec (Space Grotesk for
headings, Inter for body text, JetBrains Mono for code, sentence case copy, no drop
shadows — elevation via a raised surface + hairline border instead).

## What's not wired up yet

- **Firebase**: guarded to no-op without real `VITE_FIREBASE_*` values (see `src/lib/firebase.ts`).
- **Mapbox**: the spread map needs a real `VITE_MAPBOX_TOKEN`; its markers are an
  illustrative sample dataset until a live spread-geodata endpoint exists on the backend.
- **API key request form** (`/api`): UI only, does not submit anywhere yet.
- **Backend**: this dashboard is a client for `../backend` (a working FastAPI service —
  see `../backend/README.md`). Run it locally, or point `VITE_API_BASE_URL` at a deployed
  instance, to see live data instead of the loading/fallback states.
