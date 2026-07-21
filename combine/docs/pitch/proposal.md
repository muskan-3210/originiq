# ORACLE — proposal

> **The Fake News Time Machine.** While everyone fights fake news *today*, ORACLE goes back in time to show you where it was born, how it mutated, and the real damage it caused.

_Submission for the UNESCO Youth Hackathon 2026 — "Play Your Part: Youth Designing the Future of Media and Information Literacy."_

---

## 1. The problem
Fact-checks arrive after a lie has already spread, and a flat "this is false" rarely changes behaviour. People re-share because the harm feels abstract. Media and information literacy interventions that *quiz* users add friction most people won't accept.

## 2. Our solution
A person pastes or shares any suspicious content and — **with zero effort or quizzing** — receives a forensic story: the **origin** (where/when it was born), the **mutation timeline** (how it changed across countries and languages), the **documented damage** (real numbers, real sources), and a **shareable truth card** they can post back to the group that sent it. Every catch is recorded on a personal **Legacy Wall**.

The design rule behind every screen: *the user never answers a question or makes a judgment call — they paste, the app does the rest.*

## 3. How it works
- **Mobile app** (Flutter) — the primary experience: paste / upload / share-in → scanning → origin → mutation → damage → truth card → legacy wall.
- **Backend** (FastAPI) — normalises content, extracts the claim, embeds it, and runs a cosine-similarity search against a curated misinformation knowledge base (Postgres + pgvector) at a 0.75 threshold; falls back to public fact-check APIs; assembles origin/mutation/damage from **curated, sourced records only** (never fabricated).
- **Web dashboard** (React) — public spread map, leaderboard, live "chains broken" counter, and API docs.

## 4. Why it's credible
- Damage statistics are **looked up, never estimated at request time** — each is tied to a named source (§14.6).
- When ORACLE has no match, it says so honestly ("New territory") rather than inventing an answer (§4.2, §15).
- Knowledge base seeded from public fact-check archives (First Draft, WHO, IFCN, Reuters, Snopes/PolitiFact, academic sources).

## 5. Impact & measurement
| Metric | Target |
|---|---|
| Effort from paste to full story | < 15 s of the user's own effort |
| Re-share reduction | Documented via the pilot study (§16.7) — **[insert real ratio]** |
| Knowledge base coverage at launch | ≥ 200 sourced cases |

The re-share number is **not** a guess — it comes from the pilot in [pilot_test_protocol.md](pilot_test_protocol.md).

## 6. Technology
Flutter · FastAPI · PostgreSQL + pgvector · Redis · sentence-transformers · Firebase (Auth/Firestore/Storage) · React + Mapbox. Free-tier hosting (Render + Firebase) covers hackathon and pilot scale.

## 7. Roadmap (4-week build)
1. Design & architecture 2. Core build 3. Polish & connect + launch pilot 4. Pitch & submit. (Full detail: PRD §18–§19.)

## 8. Team
_[Names, ages (18–30), roles, one-line bios. Confirm all members are within the eligible age range.]_

## 9. Links
- Prototype (deployed): _[URL — from Firebase App Distribution / web dashboard]_
- Web dashboard: _[URL]_
- Source: _[repo URL]_
- Demo video: _[URL]_

---
_Placeholders in brackets are filled with real values before submission (§34)._
