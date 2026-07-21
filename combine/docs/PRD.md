# ORACLE — Product Requirements Document

**The Fake News Time Machine** — traces where a piece of misinformation was born, how it mutated as it spread, and the real-world damage it caused.

Prepared for: an AI coding assistant building this application end-to-end.
Context: submission for the UNESCO Youth Hackathon 2026 ("Play Your Part: Youth Designing the Future of Media and Information Literacy"), open to ages 18–30, submission window July 6 – August 16, 2026.

---

## Table of contents

1. Project overview
2. Goals & success metrics
3. User stories
4. User flows
5. Wireframe descriptions
6. UI components
7. Animations & micro-interactions
8. Design system
9. Database schema
10. API specifications
11. Folder structure
12. Technology stack
13. Authentication flow
14. Business logic
15. Edge cases
16. Testing requirements
17. Deployment steps
18. Development milestones
19. Step-by-step implementation roadmap

---

## 1. Project overview

### 1.1 What ORACLE is

ORACLE is a mobile-first application that lets a person paste, upload, or share (via the OS share sheet) any piece of suspicious content — a WhatsApp forward, a news screenshot, a social post, a URL — and receive, with **zero effort or quizzing**, a complete forensic story about that content:

- **Where and when it was born** (origin story)
- **How it changed as it spread** across platforms, countries, and languages (mutation timeline)
- **What real-world harm it caused**, backed by documented sources (damage report)
- **A shareable verdict card** the user can post back to the group that shared it with them
- **A personal "Legacy Wall"** tracking every piece of misinformation the user has helped stop

### 1.2 Core design principle (non-negotiable)

> The user never answers a question, takes a quiz, or makes a judgment call. They paste or share content. The app does everything else. This is the single rule every screen, every API, and every piece of copy must respect.

### 1.3 System components

| Component | Platform | Purpose |
|---|---|---|
| Mobile app | Flutter (iOS + Android) | Primary user-facing product |
| AI backend | Python + FastAPI | Content analysis, origin tracing, damage lookup |
| Web dashboard | React | Public spread map, leaderboard, API docs, submission collateral |
| Misinformation knowledge base | PostgreSQL + pgvector | Source of truth for claims, origins, mutations, damage |
| User & real-time data | Firebase (Auth + Firestore + Storage) | Anonymous auth, per-user history, Legacy Wall, generated truth-card images |

### 1.4 One-line pitch

"While everyone fights fake news today, ORACLE goes back in time to show you where it was born, how it mutated, and the real damage it caused."

---

## 2. Goals & success metrics

### 2.1 Primary goals

1. Let any user understand the origin, spread, and impact of a piece of misinformation in under 15 seconds of their own effort.
2. Measurably reduce re-sharing behavior by making the damage emotionally concrete (numbers, dates, real countries) rather than abstract ("this is false").
3. Produce a public, credible artifact (web dashboard + pilot data) suitable for a hackathon judging panel and for real-world pilot use afterward.

### 2.2 Success metrics

| Metric | Target | How it's measured |
|---|---|---|
| Time from paste to first result screen | < 8 seconds (cached), < 20 seconds (cold) | Backend request timing logs |
| Re-share reduction (pilot) | Directionally lower forwarding rate in the group shown full ORACLE results vs. the group shown a plain verdict | Pilot test protocol, see §16.6 |
| Screen completion | All 8 mobile screens implemented and connected end-to-end | QA checklist, §16 |
| Knowledge base coverage at launch | ≥ 200 seeded, fully-sourced misinformation cases | Seed script validation, §9.4 |
| Crash-free session rate | ≥ 99% | Firebase Crashlytics |
| Submission readiness | Proposal PDF, pitch video, working prototype link, all delivered before August 16, 2026 | Manual checklist, §18 |

### 2.3 Explicit non-goals (v1)

- ORACLE is **not** a real-time content moderation system for platforms — it is a personal, on-demand lookup tool.
- ORACLE does **not** claim to fact-check content that has no match in the knowledge base and no fact-check API hit; it says so honestly (see §15).
- ORACLE does **not** support live video analysis in v1 — only text, URLs, and static images (OCR).

---

## 3. User stories

Written as `As a <persona>, I want <capability>, so that <benefit>`. Each maps to backlog items an AI coding agent can implement independently.

1. As a **person who just received a suspicious forward**, I want to paste or share it directly into the app with one tap, so that I don't have to retype or reformat anything.
2. As that same person, I want the app to tell me the full story without asking me anything, so that using it takes no more effort than reading a message.
3. As a **socially cautious user**, I want a polished, shareable "truth card" image, so that I can debunk the claim in my group without writing my own explanation or looking confrontational.
4. As a **returning user**, I want to see a "Legacy Wall" of everything I've caught, so that I feel a sense of progress and come back again.
5. As a **first-time user**, I want to start using the app immediately without creating an account, so that there is zero signup friction.
6. As a **returning user on a new device**, I want the option to sign in and sync my Legacy Wall, so that I don't lose my history.
7. As a **non-English speaking user**, I want the app to detect my content's language automatically, so that I never have to translate anything myself.
8. As a **visually-oriented user**, I want to see exactly which countries a claim spread through, so that the scale of the problem is immediately obvious.
9. As a **judge or member of the public**, I want a web dashboard showing aggregate global impact, so that I can understand ORACLE's value without installing the app.
10. As a **developer or partner organization**, I want documented API access, so that I could integrate ORACLE's checks into another platform.
11. As a **user who submits a claim ORACLE has never seen**, I want an honest "we don't have this yet" response instead of a fabricated answer, so that I can still trust the app when it doesn't know something.
12. As a **user with a slow or offline connection**, I want a clear loading/offline state instead of a frozen screen, so that I understand what's happening.

---

## 4. User flows

### 4.1 Primary flow — the golden path

```
Splash (auto, 2.5s)
  → Home (paste / upload / share-into)
    → Scanning (automatic, no input)
      → Origin (auto-reveal)
        → Mutation (auto-reveal, user can scroll)
          → Damage (auto-reveal)
            → Truth Card (user taps "Save / Share")
              → [OS share sheet] → back to source app (e.g. WhatsApp)
              → Legacy Wall (new entry added automatically)
```

The user only makes **two voluntary taps** in the entire golden path: (1) paste/share content in, (2) tap Share on the Truth Card. Every other transition is automatic.

### 4.2 Alternate flow — no match found

```
Home → Scanning → [no claim similarity ≥ 0.75 AND no fact-check API hit]
  → "New territory" screen:
      "We haven't traced this one yet — but we've logged it for review."
      → Option: Legacy Wall (nothing added) or Home (check something else)
```

### 4.3 Alternate flow — image / screenshot input

```
Home → tap upload icon → OS photo picker → image selected
  → Scanning ("Reading image..." step added before "Checking language...")
  → same as primary flow from Origin onward
```

### 4.4 Alternate flow — share-from-WhatsApp intent

```
User is in WhatsApp → taps Share on a message → selects ORACLE from the share sheet
  → App opens directly to Scanning (Home is skipped since content already arrived)
  → same as primary flow from Origin onward
```

### 4.5 Onboarding flow (first launch only)

```
App install → first open → Splash
  → Firebase anonymous sign-in (silent, no UI)
  → Home, with a single dismissible tooltip: "Paste anything you're not sure about."
```

No account creation, no permissions requested up front. Photo-library and notification permissions are requested only at the moment they're first needed (image upload tap; end of first Legacy Wall visit, respectively).

### 4.6 Web dashboard flow

```
Visitor lands on oracle-app.web → Home (live "chains broken today" counter, CTA to download app)
  → Spread map (Mapbox globe, filters by category/date)
  → Leaderboard (top users, schools, countries)
  → API docs (Swagger UI + curl examples + API key request form)
```

---

## 5. Wireframe descriptions

Each of the 8 mobile screens below is described with layout, primary elements, and states (default, loading, error, empty) so it can be built without visual mockups.

### Screen 1 — Splash
- Full-bleed dark background.
- Centered: floating crystal-ball Rive animation (idle loop).
- Below it: wordmark "ORACLE" fades in at 200ms, tagline "Tracing the truth through time" fades in at 500ms.
- No interactive elements. Auto-navigates to Home after 2500ms.
- State: none (always the same); if Firebase anonymous auth fails, log the error silently and proceed to Home anyway — auth must never block entry.

### Screen 2 — Home
- Top: short instruction text, no header/nav chrome.
- Center: a paste/text-entry card (tap to paste or type), an upload icon (photo picker) and a URL icon (paste a link) inline with it.
- Primary button: "Scan for truth" (disabled/inactive-looking until there is content, but never a hard-disabled control — see design system §8.6 on avoiding disabled buttons; instead show a gentle inline hint "Paste something first").
- Bottom: "Recent checks" — up to 3 most recent results as small tappable rows (thumbnail verdict + snippet + relative time).
- Empty state (no recent checks): the row area is simply omitted, no placeholder graphic needed.
- Share-intent state: if opened via OS share, this screen is skipped entirely.

### Screen 3 — Scanning
- Full-bleed, centered content.
- Floating clock icon (gentle rotation/bob loop).
- A 3–4 item checklist appears one line at a time, each ticking with a checkmark: "Checking language" → "Matching similar claims" → "Cross-referencing sources" → (image only) "Reading image text" appears first.
- Thin progress bar beneath the checklist, filling in sync with backend response arrival (see §7 for exact timing).
- Error state: if the backend call fails or times out (>15s), replace the checklist with: "This is taking longer than usual" + a "Retry" button. Never leave the user on an infinitely spinning screen.

### Screen 4 — Origin
- Scrollable single column.
- A "danger card" (red-tinted) at top: platform + country + date, e.g. "Born on WhatsApp — India, March 2020."
- Row of tag pills below (category tags, e.g. "Health misinformation", "Covid-era").
- A short note line: how many platforms/hops it was traced through before reaching the user.
- Empty/no-origin state: if verdict is "unverified" (no match), this screen is replaced entirely by the "New territory" screen (§4.2) — Origin never renders with placeholder data.

### Screen 5 — Mutation
- Header line: "Spread across N countries."
- A simplified world-spread visual: country markers appearing left-to-right in chronological order of first appearance (see §7 for the mobile-simplified version vs. the full Mapbox version on the web dashboard).
- Below: a version-comparison card showing how the wording changed in one representative variant (original vs. mutated excerpt, plus the country/date of that mutation).
- If only one origin exists with no further mutations: show the origin marker alone with the note "No further spread recorded yet" — never fabricate additional countries.

### Screen 6 — Damage report
- 2×2 grid of stat cards: people misled, countries affected, peak shares/day, days active (exact fields are data-driven from `damage_records`; if a claim has fewer than 4 recorded stats, show only the stats that exist, in a responsive grid — never show a stat card with a fabricated placeholder number).
- Numbers animate from 0 to their final value.
- Background music/sound cue (if audio is enabled) drops to near-silence as the counters animate — this is the emotional peak of the experience.
- Empty state: if a matched claim has zero damage records, this screen is skipped and the flow proceeds straight to Truth Card with a neutral note: "Documented impact isn't available for this one yet."

### Screen 7 — Truth card
- A single preview card: verdict badge (False / Misleading / True / Unverified), the claim text (truncated), a one-line origin+damage summary, tagline "You broke the chain. It ends with you."
- Primary action: "Save & share" → generates a PNG snapshot of the card → opens the OS share sheet.
- Secondary action: "Done" → navigates to Legacy Wall (only if verdict was False/Misleading — a catch was made) or Home (if verdict was True — nothing to add to the wall).
- Error state: if PNG generation fails, allow retry; never block navigation — a "Skip sharing" text link is always available.

### Screen 8 — Legacy wall
- Grid (4 columns) of small icons, one per past catch, most recent first.
- One dashed, empty slot always rendered at the end as an invitation for the next catch.
- Tapping any filled icon reopens that Truth Card (read-only).
- Optional leaderboard teaser at the bottom: user's rank + link to the web dashboard leaderboard.
- Empty state (brand-new user, zero catches): replace the grid with an encouraging empty state per copy rules in §8.7: headline "Start your first catch", body "Paste anything suspicious and we'll trace it for you", no dashed-grid needed yet.

---

## 6. UI components

Reusable component inventory. Each should be built once and composed across screens — an AI agent should treat this as the component library to implement before wiring up screens.

| Component | Used on screens | Notes |
|---|---|---|
| `PasteInputCard` | Home | Text field + inline upload/link icon buttons |
| `RecentCheckRow` | Home | Thumbnail verdict dot + snippet + timestamp |
| `ScanningChecklist` | Scanning | Sequential reveal list, see §7.3 |
| `ScanProgressBar` | Scanning | Linear, driven by real request progress, not a fake timer |
| `DangerCard` | Origin | Red-tinted card for origin facts |
| `TagPill` | Origin | Small rounded category label |
| `SpreadTimeline` | Mutation | Sequential country markers |
| `MutationVersionCard` | Mutation | Original vs. mutated text comparison |
| `StatCounterCard` | Damage report | Label + animated number |
| `TruthCardPreview` | Truth card | The shareable card itself |
| `ShareSheetTrigger` | Truth card | Wraps native share intent |
| `LegacyGridItem` | Legacy wall | Small caught-claim icon, tappable |
| `EmptyLegacySlot` | Legacy wall | Dashed placeholder, always last in grid |
| `PrimaryButton` / `SecondaryButton` | All | See design system §8.6 |
| `ErrorBanner` | Scanning, Truth card | Inline, dismissible, includes a retry action when applicable |
| `OfflineBanner` | Global (app shell) | Persistent top banner when connectivity is lost |
| `LoadingSkeleton` | Home (recent checks) | Shimmer placeholder while Firestore loads |


---

## 7. Animations & micro-interactions

Every animation below has a functional purpose (pacing, feedback, or emotional emphasis) — none are decorative-only, and every looping animation must respect `prefers-reduced-motion` equivalents on mobile (Flutter: check `MediaQuery.of(context).disableAnimations` and skip non-essential loops).

### 7.1 Splash
- Crystal-ball Rive asset: continuous idle float, ~2.4s ease-in-out loop.
- Wordmark opacity 0→1 over 500ms starting at 200ms; tagline opacity 0→1 over 500ms starting at 500ms.
- Implementation: `RiveAnimation.asset()` for the crystal ball; `AnimatedOpacity` for text; `Future.delayed(2500ms)` before navigation.

### 7.2 Home
- No decorative animation. The one micro-interaction: the paste card gets a 150ms border-color transition to the accent color on focus.
- `PrimaryButton` press: scale to 0.98 over 100ms (standard button micro-interaction, applies globally).

### 7.3 Scanning
- Clock icon: gentle rotate ±8° and translateY bob, 2.2s ease-in-out infinite, via `AnimationController` + `CurvedAnimation(curve: Curves.easeInOut)`.
- Checklist items: each item fades/slides in with a 400ms stagger between items (`Future.delayed` chain or a `AnimatedList`).
- Progress bar: width driven by real backend response progress where possible (e.g. 33% after OCR/claim-extraction completes, 66% after fact-check API responses return, 100% on final payload) rather than a fixed fake timer, so the animation never finishes before the data is actually ready.

### 7.4 Origin
- `DangerCard` slides in from a slight vertical offset (`SlideTransition`, 8px → 0), 300ms.
- Tag pills fade in staggered 150ms apart, starting 300ms after the card.
- Origin note text fades in last.

### 7.5 Mutation
- Country markers pop in sequentially (scale 0.6→1, opacity 0→1), 250ms each, staggered 300ms apart in chronological order.
- Mutation version card slides up from below after all markers have appeared.

### 7.6 Damage report
- All stat counters animate simultaneously from 0 to their final value over 2000ms using `Tween<double>` + `AnimationController`.
- If audio is enabled in-app, trigger a volume-ducking callback exactly when the counter animation starts — this is the scripted emotional low point described in the pitch video plan and should feel identical in the live product.

### 7.7 Truth card
- On screen entry: a brief "capture flash" (white/light overlay, opacity 0→0.8→0 over ~350ms) simulating a photo being taken, generated via `RepaintBoundary` + `toImage()`.
- ~500ms after the flash, the share-sheet-style action bar slides up from off-screen (translateY 100%→0, 400–500ms ease-out).

### 7.8 Legacy wall
- Grid items pop in staggered (150ms apart) on first load of a wall with existing entries.
- When a **new** catch is added (arriving from the Truth Card flow), that new item animates in with a slightly larger overshoot ("bounce") — e.g. scale 0→1.15→1 over 400ms — so it reads as distinct from the rest of the grid.
- The dashed empty slot has a slow, subtle pulse (opacity 0.6↔1, 3s loop) to invite the next catch — this is the one continuously-looping animation on this screen and must be skippable under reduced-motion settings.

### 7.9 Global micro-interactions
- All buttons: press scale 0.98, 100ms, spring back on release.
- Pull-to-refresh on Home's recent-checks list: standard platform refresh indicator.
- Haptic feedback (light impact): on successful scan completion (arrival at Origin), on Truth Card share action, and on new Legacy Wall entries.
- Offline banner: slides down from the top (200ms) when connectivity drops, slides back up when restored.

---

## 8. Design system

### 8.1 Visual identity
A single "mystical-dark" theme (no light-mode variant is required for v1 — the app is designed dark-first to support the crystal-ball / time-machine tone, and dark UIs also read better for the video demo and screenshots).

### 8.2 Color palette

| Token | Hex | Usage |
|---|---|---|
| `bg.base` | `#0D0B1A` | App background |
| `bg.surface` | `#17142B` | Cards, sheets |
| `bg.surfaceRaised` | `#201C3B` | Elevated cards (Truth Card, modals) |
| `accent.gold` | `#FFC857` | Primary accent — "the light of truth"; primary buttons, active states, links |
| `danger.red` | `#E24B4A` | Origin danger card, False verdict badge |
| `success.teal` | `#1D9E75` | True verdict badge, success states |
| `warning.amber` | `#EF9F27` | Misleading verdict badge |
| `text.primary` | `#F5F3FF` | Headings, primary body text |
| `text.secondary` | `#A9A3C9` | Supporting text, captions |
| `text.muted` | `#6E698F` | Placeholders, timestamps |
| `border.default` | `#2A2650` | Card borders, dividers |
| `border.strong` | `#3D386B` | Emphasized borders, focus rings |

Contrast requirement: every text/background pairing above meets WCAG AA (4.5:1 for body text, 3:1 for large text/icons). Verify with an automated contrast check as part of the design-system unit tests (§16.5).

### 8.3 Typography

| Role | Font | Weight | Size |
|---|---|---|---|
| Display / wordmark | Space Grotesk | 500 | 28px |
| Headings (H1/H2/H3) | Space Grotesk | 500 | 22 / 18 / 16px |
| Body | Inter | 400 | 15px |
| Body secondary / captions | Inter | 400 | 13px |
| Numbers (stat counters) | Space Grotesk | 500 | 24px |
| Code / API docs (web only) | JetBrains Mono | 400 | 13px |

Line height: 1.5 for body text, 1.2 for headings. Only two weights used anywhere: 400 (regular) and 500 (medium) — never bold (700) for a softer, less aggressive tone that fits the emotional content.

### 8.4 Spacing scale
4, 8, 12, 16, 24, 32, 48, 64px. Card internal padding: 16px. Screen horizontal margin: 20px.

### 8.5 Shape & elevation
- Corner radius: 12px for cards, 8px for buttons and inputs, 999px (pill) for tags and badges.
- No drop shadows (dark theme reads flatter and cleaner with shadows) — elevation is communicated with a lighter surface tone (`bg.surfaceRaised`) and a 0.5px `border.default` outline instead.

### 8.6 Components & states
- Buttons: filled with `accent.gold` for the single primary action per screen; everything else is an outline/ghost button on `border.default`. Never render a hard-disabled button — if an action isn't ready (e.g. "Scan for truth" with empty input), keep it visually present but show an inline hint on tap instead of disabling it, so touch and screen-reader users always get feedback.
- Inputs: 44px minimum height (accessibility tap-target minimum), focus state = `border.strong` + subtle glow using `accent.gold` at low opacity.
- Icons: Phosphor Icons, regular weight, 20–24px, always paired with a text label except in icon-only buttons (which require an accessibility label).

### 8.7 Content & copy rules
- Sentence case everywhere; no title case, no ALL CAPS, no exclamation points in system copy.
- Buttons are verbs: "Scan for truth", "Save & share", not "OK" or "Submit".
- Errors state what happened and what to do next in one sentence, no technical jargon, no "Error:" prefix.
- Empty states are an invitation, not an apology (see Legacy Wall empty state in §5).

### 8.8 Accessibility requirements
- Minimum 44×44pt tap targets everywhere.
- All animations that loop indefinitely (clock bob, empty-slot pulse) must be disabled when the OS-level reduce-motion setting is on; one-shot reveal animations (fades, slides) may remain but should collapse to an instant state change if reduce-motion is set.
- All non-text content (icons, verdict badges) has a semantic label for screen readers.
- Dynamic type: text scales with system font-size settings up to 130% without clipping (test with the largest layout on Damage Report, the most numerically dense screen).


---

## 9. Database schema

ORACLE uses two data stores with a clear split of responsibility:

- **PostgreSQL** — the misinformation knowledge base. Read-heavy, curated/seeded, the source of truth for origin/mutation/damage data.
- **Firestore** — user & real-time data. Per-user history, Legacy Wall entries, live counters, leaderboard cache.

### 9.1 PostgreSQL schema

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

CREATE TABLE claims (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text               TEXT NOT NULL,
  normalized_text    TEXT NOT NULL,
  embedding          VECTOR(384) NOT NULL,      -- sentence-transformers all-MiniLM-L6-v2
  language           VARCHAR(8) NOT NULL,        -- ISO 639-1
  category           VARCHAR(50) NOT NULL,       -- health | election | disaster | deepfake | other
  checkworthy_score  FLOAT,                      -- ClaimBuster score, 0-1
  verdict            VARCHAR(20) NOT NULL DEFAULT 'false', -- false | misleading | true
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_claims_embedding ON claims USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_claims_language ON claims (language);
CREATE INDEX idx_claims_category ON claims (category);

CREATE TABLE origins (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id     UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
  origin_date  DATE NOT NULL,
  platform     VARCHAR(50) NOT NULL,             -- whatsapp | facebook | twitter | tiktok | other
  country      VARCHAR(2) NOT NULL,               -- ISO 3166-1 alpha-2
  source_url   TEXT NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_origins_claim ON origins (claim_id);

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
CREATE INDEX idx_mutations_claim ON mutations (claim_id);

CREATE TABLE damage_records (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id     UUID NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
  stat_label   VARCHAR(100) NOT NULL,             -- e.g. "People misled"
  stat_value   NUMERIC NOT NULL,
  description  TEXT NOT NULL,
  source_url   TEXT NOT NULL,
  source_name  VARCHAR(100) NOT NULL
);
CREATE INDEX idx_damage_claim ON damage_records (claim_id);

CREATE TABLE analysis_log (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  input_hash         VARCHAR(64) NOT NULL,        -- md5 of normalized submitted content
  matched_claim_id   UUID REFERENCES claims(id),
  similarity_score   FLOAT,
  firebase_uid       VARCHAR(128),                -- nullable, anonymous allowed
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_analysis_log_hash ON analysis_log (input_hash);
```

**Validation rule for seed data (enforced by the seed script, §9.4):** every row in `claims` must have at least one linked `origins` row and at least one linked `damage_records` row before it is committed. Incomplete records are rejected, not partially seeded.

### 9.2 Firestore collections

```
users/{uid}
  displayName: string
  authProvider: "anonymous" | "google" | "apple"
  createdAt: timestamp
  legacyCount: number

users/{uid}/checks/{checkId}
  inputHash: string
  verdict: string
  matchedClaimId: string | null
  createdAt: timestamp

legacyWall/{uid}/entries/{entryId}
  claimId: string
  verdict: string
  truthCardUrl: string          -- Firebase Storage public URL
  caughtAt: timestamp

leaderboardCache/{uid}          -- maintained by a scheduled Cloud Function, not written directly by the client
  displayName: string
  catchCount: number
  country: string | null
```

### 9.3 Redis (cache only, not durable storage)
- Key: `analysis:{md5(normalized_content)}`
- Value: the full JSON response of `/api/analyze` for that content
- TTL: 86400 seconds (24 hours)
- Purpose: identical submissions (a viral message pasted by thousands of users) hit the cache instead of recomputing the full NLP + fact-check pipeline every time.

### 9.4 Seed data requirements
- Minimum 200 real, documented misinformation cases before launch.
- Sources: First Draft News archive, WHO Infodemic Manager, IFCN network fact-checkers, Snopes/PolitiFact exports, Reuters fact-check archive, MIT Media Lab / Stanford Internet Observatory research.
- Priority categories: health misinformation (vaccines, COVID, cancer cures), election interference, disaster/emergency hoaxes, viral WhatsApp hoaxes with documented real-world consequences, deepfake/manipulated media.
- The seed script (`backend/scripts/seed_database.py`) must validate the four-field minimum (origin date, origin platform, ≥1 source URL, ≥1 damage record) per claim and log/skip any record that fails validation rather than inserting incomplete data.

---

## 10. API specifications

Base URL: `https://api.oracle-app.example/api` (replace with actual Render deployment URL). All responses are `application/json` unless noted. All error responses share this shape:

```json
{ "error": { "code": "string", "message": "human-readable message" } }
```

### 10.1 `POST /api/analyze`
Analyzes submitted content and returns the full origin/mutation/damage story.

**Auth:** optional. If a Firebase ID token is present in `Authorization: Bearer <token>`, the request is attributed to that user for history/leaderboard purposes; anonymous requests are still fully served.

**Request:** `multipart/form-data`
| Field | Type | Required | Notes |
|---|---|---|---|
| `type` | string enum: `text`, `url`, `image` | yes | |
| `content` | string | required if `type` is `text` or `url` | max 5000 chars |
| `image` | file | required if `type` is `image` | max 10MB, jpeg/png |
| `language_hint` | string | no | ISO 639-1, used to skip auto-detection |

**Response `200`:**
```json
{
  "id": "b3f1...",
  "verdict": "false",
  "cached": false,
  "origin": {
    "platform": "whatsapp",
    "country": "IN",
    "date": "2020-03-14",
    "tags": ["health-misinformation", "covid-era"],
    "hops_traced": 6
  },
  "mutations": [
    { "version": 2, "country": "BR", "date": "2020-04-02", "text_excerpt": "...", "similarity_to_origin": 0.81 }
  ],
  "damage": [
    { "label": "People misled", "value": 47000, "description": "...", "source_name": "Reuters", "source_url": "https://..." }
  ],
  "truth_card_ready": true
}
```

**Response `200` (no match found):**
```json
{ "id": "b3f1...", "verdict": "unverified", "cached": false, "origin": null, "mutations": [], "damage": [], "truth_card_ready": false }
```

**Errors:** `422` invalid/missing fields · `413` file too large · `429` rate limited (see §14.5) · `500` internal error (never exposes stack traces to the client).

### 10.2 `POST /api/truthcard`
Generates the shareable verdict card image for a previously analyzed item.

**Auth:** optional (same rule as `/api/analyze`).
**Request:** `{ "analysis_id": "b3f1..." }`
**Response `200`:** `{ "image_url": "https://firebasestorage.../truthcards/b3f1....png" }`
**Errors:** `404` if `analysis_id` doesn't exist · `422` if the analysis has `truth_card_ready: false`.

### 10.3 `POST /api/legacy`
Records a catch on the authenticated user's Legacy Wall.

**Auth:** required (Firebase ID token; anonymous tokens are accepted — this is about attribution, not identity verification).
**Request:** `{ "analysis_id": "b3f1...", "truth_card_url": "https://..." }`
**Response `200`:** `{ "entry_id": "...", "legacy_count": 12 }`
**Errors:** `401` missing/invalid token · `404` analysis not found · `409` duplicate entry for same analysis_id + user.

### 10.4 `GET /api/leaderboard`
**Auth:** none.
**Query params:** `scope` = `global` | `country` | `school` (default `global`), `limit` (default 50, max 100).
**Response `200`:** `{ "scope": "global", "entries": [ { "rank": 1, "display_name": "...", "catch_count": 812, "country": "NG" } ] }`

### 10.5 `GET /api/stats/global`
Powers the web dashboard's live counter.
**Response `200`:** `{ "chains_broken_today": 1042, "chains_broken_total": 58210, "countries_covered": 61 }`

### 10.6 `GET /health`
**Response `200`:** `{ "status": "ok" }` — used by Render's health check and uptime monitoring.


---

## 11. Folder structure

Monorepo with three independently deployable applications plus shared docs.

```
oracle/
├── mobile/                        # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart                # root widget, routing, theme injection
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── scanning_screen.dart
│   │   │   ├── origin_screen.dart
│   │   │   ├── mutation_screen.dart
│   │   │   ├── damage_screen.dart
│   │   │   ├── truth_card_screen.dart
│   │   │   └── legacy_wall_screen.dart
│   │   ├── widgets/                 # components from §6
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── firestore_service.dart
│   │   ├── models/                  # Analysis, Origin, Mutation, DamageStat, LegacyEntry
│   │   ├── animations/              # reusable animation controllers/curves
│   │   ├── theme/                   # colors, text styles from §8
│   │   └── utils/
│   ├── assets/
│   │   ├── rive/                    # crystal_ball.riv, etc.
│   │   └── fonts/
│   ├── test/                        # widget + unit tests, mirrors lib/ structure
│   ├── integration_test/            # end-to-end flows
│   └── pubspec.yaml
│
├── backend/                       # FastAPI service
│   ├── app/
│   │   ├── main.py
│   │   ├── api/
│   │   │   ├── analyze.py
│   │   │   ├── truthcard.py
│   │   │   ├── legacy.py
│   │   │   ├── leaderboard.py
│   │   │   ├── stats.py
│   │   │   └── health.py
│   │   ├── core/
│   │   │   ├── config.py            # env var loading
│   │   │   └── security.py          # Firebase token verification
│   │   ├── nlp/
│   │   │   ├── content_intake.py    # text/url/image → raw text
│   │   │   ├── claim_extractor.py
│   │   │   ├── origin_tracer.py
│   │   │   ├── mutation_tracker.py
│   │   │   └── damage_estimator.py
│   │   ├── integrations/
│   │   │   ├── claimbuster.py
│   │   │   ├── google_factcheck.py
│   │   │   └── firebase_admin_client.py
│   │   ├── db/
│   │   │   ├── models.py
│   │   │   ├── session.py
│   │   │   └── migrations/          # Alembic
│   │   ├── cache/
│   │   │   └── redis_client.py
│   │   └── schemas/                 # Pydantic request/response models
│   ├── scripts/
│   │   └── seed_database.py
│   ├── tests/
│   │   ├── unit/
│   │   └── integration/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── render.yaml
│
├── web/                            # React dashboard
│   ├── src/
│   │   ├── pages/                  # Home, SpreadMap, Leaderboard, ApiDocs
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── lib/                    # api client, firebase config
│   │   └── main.tsx
│   ├── public/
│   ├── package.json
│   └── vite.config.ts
│
└── docs/
    ├── PRD.md                      # this document
    └── pitch/                      # proposal doc, pitch script, pilot test results
```

---

## 12. Technology stack

| Layer | Technology | Why |
|---|---|---|
| Mobile | Flutter 3.x + Dart | Cross-platform, best-in-class animation support |
| Mobile animation | Rive | Designer-friendly, performant vector animations (splash crystal ball) |
| Mobile state mgmt | Riverpod | Testable, no BuildContext coupling for services |
| Auth | Firebase Authentication (anonymous + Google/Apple upgrade) | Zero-friction entry, easy account linking |
| Realtime/user data | Firebase Firestore | Real-time sync, simple client SDKs |
| Media storage | Firebase Storage | Truth card PNGs |
| Backend framework | FastAPI (Python 3.11) | Async, fast, automatic OpenAPI docs |
| NLP | spaCy (`en_core_web_lg`), `sentence-transformers` (`all-MiniLM-L6-v2`), HuggingFace `distilbert-base-uncased-mnli` | Claim extraction, embedding similarity, language detection |
| Fact-check sources | ClaimBuster API, Google Fact Check Tools API | Free, check-worthiness scoring + existing fact-check cross-reference |
| Knowledge base | PostgreSQL + `pgvector` (hosted on Render or Supabase) | Structured relational data + vector similarity search in one store |
| Cache | Redis | 24h response cache keyed by content hash |
| OCR | `pytesseract` + Pillow | Image → text for screenshot submissions |
| Web scraping | `requests` + BeautifulSoup4 | URL content intake |
| Web dashboard | React 18 + Vite + TypeScript + TailwindCSS | Fast dev loop, small bundle |
| Maps | Mapbox GL JS (web), a simplified custom spread visual (mobile, see §5 Screen 5) | Full interactivity on web, lightweight on mobile |
| Data viz | D3.js, Recharts | Spread map layers, dashboard charts |
| Hosting | Render (backend), Firebase Hosting (web) | Free tiers sufficient for hackathon + pilot scale |
| CI/CD | GitHub Actions | Lint + test on PR, auto-deploy on merge to `main` |
| Monitoring | Firebase Crashlytics (mobile), Render health checks + logs (backend), UptimeRobot (external ping) | |

---

## 13. Authentication flow

Authentication must never be a barrier to the core "paste and see" experience — it exists only to attribute history and enable optional multi-device sync.

### 13.1 Flow
1. On first app launch, the client silently calls Firebase Anonymous Auth. No UI is shown; if it fails, the app proceeds unauthenticated and retries silently on the next launch.
2. The client stores the Firebase ID token in memory (via the Firebase SDK's own token management) and attaches it as `Authorization: Bearer <token>` on any backend request that supports optional or required auth (`/api/analyze`, `/api/truthcard`, `/api/legacy`).
3. The backend verifies the token using `firebase-admin`'s `auth.verify_id_token()`. A valid token yields a `uid`; requests to `/api/analyze` and `/api/truthcard` proceed even without a token (uid is simply `null` in `analysis_log`). Requests to `/api/legacy` **require** a valid token (anonymous uid is sufficient — the point is attribution, not identity verification) and return `401` otherwise.
4. **Optional upgrade:** at any point (surfaced as a low-pressure prompt the first time a user opens the Legacy Wall with ≥3 entries — "Sign in to keep this safe across devices"), the user may link their anonymous account to Google or Apple sign-in via Firebase's account-linking API. This preserves their existing `uid` and all associated Firestore/`analysis_log` data — it is a link, not a new account.
5. Tokens are refreshed automatically by the Firebase client SDK; the backend has no session state of its own (fully stateless, token-verified per request).

### 13.2 What is explicitly out of scope
- No email/password auth flow (adds friction with no benefit for this use case).
- No admin/moderator role system in v1 — the seed database is the only source of "verified" claims, curated offline by the content team, not through an in-app moderation UI.

---

## 14. Business logic

### 14.1 Content intake
- `type: text` → used as-is.
- `type: url` → fetched via `requests`, main content extracted with BeautifulSoup4 (strip nav/ads/boilerplate).
- `type: image` → decoded, run through `pytesseract.image_to_string()`. If OCR returns fewer than 10 characters of recognizable text, treat as an OCR failure (§15).

### 14.2 Claim extraction & check-worthiness
1. Detect language (`langdetect`).
2. Strip emotional trigger words using a curated list (reduces noise in embedding similarity).
3. Use the fine-tuned claim model to isolate the core verifiable statement from surrounding text (greetings, forward chains, emoji).
4. Score check-worthiness via ClaimBuster; **threshold 0.5** — below this, treat as "not a factual claim" and return the `unverified` verdict without a wasted knowledge-base search.

### 14.3 Origin tracing & similarity matching
1. Encode the extracted claim with `all-MiniLM-L6-v2`.
2. Run a cosine-similarity search against `claims.embedding` using `pgvector`'s `ivfflat` index.
3. **Similarity threshold: 0.75.** Below this, there is no match — proceed to the Google Fact Check API as a secondary check; if that also returns nothing, the verdict is `unverified` and the claim is logged (not seeded) for the content team's manual review queue.
4. Above 0.75, the highest-scoring `claims` row is the match; its linked `origins`, `mutations`, and `damage_records` rows are assembled into the response.

### 14.4 Mutation assembly
- All `mutations` rows for the matched `claim_id` are returned ordered by `mutation_date`.
- `similarity_to_origin` (precomputed at seed time) powers the "how much did the wording drift" comparison shown in the Mutation screen.

### 14.5 Caching & rate limiting
- Every request is hashed (`md5` of normalized, lowercased, whitespace-stripped content) and checked against Redis before any NLP/API work begins. Cache hit → instant response, `cached: true`.
- Rate limiting: 30 requests per 10 minutes per IP (unauthenticated) or per `uid` (authenticated), enforced at the API gateway/middleware level, returning `429` with a `Retry-After` header. This protects the free-tier fact-check APIs from being exhausted by abuse or a single viral spike, while comfortably covering legitimate repeated use.

### 14.6 Damage estimation
- `damage_records` are looked up directly by `claim_id` — this is curated data, not computed/estimated at request time, to avoid ever showing a fabricated statistic.

### 14.7 Truth card generation
- Rendered server-side (Pillow, 1080×1920) using the verdict, top damage stat, and the fixed tagline, then uploaded to Firebase Storage; the mobile client's own "capture flash" animation (§7.7) is purely presentational and does not itself generate the final shareable asset — it fires while the server request is in flight.

### 14.8 Legacy Wall & leaderboard logic
- A Legacy Wall entry is only created for verdicts of `false` or `misleading` — a `true` verdict means nothing was "caught," so no entry is added (see Truth Card screen logic, §5 Screen 7).
- The leaderboard is **not** written synchronously on every catch; a scheduled Cloud Function aggregates `legacyWall` counts into `leaderboardCache` every 5 minutes, keeping the hot write path (`/api/legacy`) fast and avoiding leaderboard write contention during a viral spike.


---

## 15. Edge cases

Grouped by category. Every one of these must have an explicit, designed behavior — "shouldn't happen" is not an acceptable answer for an AI agent building this system.

**Input edge cases**
- Empty paste / empty submission → "Scan for truth" shows an inline hint instead of submitting; no request is sent.
- Content exceeds 5000 characters → truncate with a visible notice ("We checked the first 5,000 characters") rather than rejecting outright.
- Image with no readable text (OCR returns <10 chars) → Scanning screen shows "We couldn't read any text in this image" with options to retry with a clearer photo or paste text instead.
- Non-Latin scripts / mixed-language content → language detection runs per-claim, not per-character; if detection confidence is low, fall back to the `language_hint` if provided, else default to treating the dominant script's language.
- Extremely short, non-factual content ("lol", "ok") → fails the check-worthiness threshold (§14.2), returns `unverified` immediately without a wasted knowledge-base search.

**Matching edge cases**
- Claim matches multiple clusters at similar similarity scores → the single highest-scoring match is used; this is a known v1 limitation, logged for the content team rather than silently guessed at.
- Claim is genuinely **true** → verdict `true` is a first-class outcome, not an error state; Truth Card and copy adapt accordingly ("This one's actually true"), and no Legacy Wall entry is created.
- Ambiguous or satirical content → satire is out of scope for automatic detection in v1; if ClaimBuster/similarity match a satirical claim already in the knowledge base, it is tagged `category: satire` at seed time and the Truth Card copy reflects that distinction rather than a flat "false."
- Claim about a very recent/breaking event with no historical data yet → verdict `unverified`, explicit "New territory" screen (§4.2), logged for review — never fabricated.

**System / network edge cases**
- No internet connection → `OfflineBanner` (§6) appears immediately; any in-flight submission is queued client-side and retried automatically on reconnect, with the Scanning screen showing "Waiting for connection" instead of a generic spinner.
- Backend request times out (>15s) or returns `500` → Scanning screen error state (§5) with a Retry action; the failure is logged with the request ID for debugging, never surfaced as a raw stack trace to the user.
- Rate limit exceeded (`429`) → user-facing copy: "You're checking things quickly — give it a minute and try again," not a technical rate-limit message.
- Backend fully down (health check failing) → mobile app falls back to showing only cached/local recent checks on Home; new scans show the offline/error state rather than hanging.

**Social / content edge cases**
- User submits offensive, harmful, or clearly abusive content (not misinformation, but intentionally harmful text) → the claim-extraction/check-worthiness pipeline will simply fail to find a factual claim and return `unverified`; ORACLE does not attempt content moderation or flagging of the user's submission in v1 — that is explicitly out of scope.
- Duplicate submission of viral content by many different users → served entirely from the Redis cache (§14.5); this is treated as the expected, common case, not an edge case to special-case in the UI.

**Account / sync edge cases**
- Anonymous user uninstalls and reinstalls the app → a new anonymous `uid` is created and prior history is lost, **unless** they had previously linked to Google/Apple sign-in. This tradeoff is accepted for v1 in favor of zero-friction onboarding; the sign-in upgrade prompt (§13.1) exists specifically to mitigate this for engaged users.
- Legacy Wall write conflict across two devices signed into the same linked account → Firestore's last-write-wins semantics apply; entries themselves are additive (new documents), so the only real conflict surface is the cached `legacyCount`, which is corrected by the same scheduled aggregation function used for the leaderboard (§14.8).
- Leaderboard gaming (spamming low-effort or synthetic submissions to inflate catch count) → mitigated by the rate limiter (§14.5) and by the fact that a Legacy Wall entry requires a real `false`/`misleading` verdict from the knowledge base, not a self-reported claim — an attacker would need to repeatedly submit genuinely-matched misinformation, which has natural diminishing returns from the cache.


---

## 16. Testing requirements

### 16.1 Backend unit tests
- NLP pipeline: claim extraction on a fixed set of sample inputs (short, long, multi-language, non-factual), check-worthiness threshold boundary cases (0.49 vs 0.51).
- Similarity matching: boundary cases at the 0.75 threshold; verify the correct claim wins when two candidates score close together.
- Damage estimator: verify it never fabricates a stat — returns exactly the `damage_records` rows linked to the matched claim, no more, no fewer.
- Cache key generation: verify identical content (including whitespace/case differences) hashes to the same key.

### 16.2 Backend integration tests
- Full request/response cycle for every endpoint in §10 against a test database, including all documented error codes.
- Auth middleware: valid token, missing token, expired token, malformed token — verify each endpoint's documented auth requirement is enforced.
- Rate limiter: verify the 429 triggers at the documented threshold and resets after the window.

### 16.3 Mobile widget tests
- One widget test per screen in §5, covering default, loading, error, and empty states listed in each screen's wireframe description.
- Component tests for every item in the §6 inventory in isolation.

### 16.4 Mobile end-to-end tests (`integration_test`)
- Golden path: paste text → Scanning → Origin → Mutation → Damage → Truth Card → share → Legacy Wall entry appears.
- No-match path: submit nonsense text → "New territory" screen appears, no Legacy Wall entry is created.
- Offline path: disable network mid-scan → offline banner appears, retry succeeds once network is restored.

### 16.5 Design-system / accessibility tests
- Automated contrast check for every color pairing in §8.2.
- Dynamic-type test at 130% system font scale on the Damage Report screen (the most text/number-dense screen).
- `prefers-reduced-motion` (Flutter's `disableAnimations`) verified to suppress the two continuously-looping animations (Scanning clock, Legacy Wall empty-slot pulse).

### 16.6 Load testing
- Backend load test (Locust or k6) simulating concurrent `/api/analyze` calls, including a "viral spike" scenario where hundreds of requests hit the same cache key simultaneously — verify Redis absorbs the load and the underlying NLP pipeline isn't invoked redundantly.

### 16.7 Pilot user validation test (real-world, not automated)
Because the pitch and Truth Card copy make a specific behavioral claim ("seeing the origin story makes people less likely to re-share"), it must be backed by a real, documented pilot, not an automated test:
1. Recruit 20 participants, split into Group A (10) and Group B (10).
2. Show both groups the same misinformation. Group A sees a plain "this is false" verdict; Group B sees the full ORACLE result (origin, mutation, damage).
3. One week later, send both groups a similar new piece of misinformation via WhatsApp and measure, within 48 hours, how many people in each group forward it onward.
4. Document the real ratio (whatever it is) with participant count and a one-paragraph methodology — this real number replaces any placeholder statistic in the product copy and pitch materials.

### 16.8 Manual QA checklist
A pass/fail checklist mapping 1:1 to every row of §5's wireframe descriptions and every state (default/loading/error/empty) listed there, run once before each milestone demo (§18) and once before final submission.

---

## 17. Deployment steps

### 17.1 Backend (Render)
1. Create `render.yaml` defining the FastAPI web service, its build command (`pip install -r requirements.txt`), start command (`uvicorn app.main:app --host 0.0.0.0 --port $PORT`), and a managed PostgreSQL instance with the `vector` extension enabled.
2. Set environment variables in the Render dashboard: `DATABASE_URL`, `REDIS_URL`, `FIREBASE_ADMIN_CREDENTIALS_JSON`, `CLAIMBUSTER_API_KEY`, `GOOGLE_FACTCHECK_API_KEY`.
3. Run Alembic migrations (`alembic upgrade head`) as a Render pre-deploy/release command.
4. Run `scripts/seed_database.py` once against the production database after migrations succeed.
5. Confirm `/health` returns `200 {"status":"ok"}` before pointing the mobile app / web dashboard at the new URL.

### 17.2 Web dashboard (Firebase Hosting)
1. `firebase init hosting` in `web/`, connect to the project's Firebase project.
2. Set the `VITE_API_BASE_URL` and Firebase client config as build-time environment variables.
3. `npm run build` then `firebase deploy --only hosting`.
4. Verify the live counter (`/api/stats/global`) and spread map load correctly against the production backend.

### 17.3 Mobile app
1. Configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from the Firebase project.
2. Point `ApiService`'s base URL at the Render production URL via a build-time flavor/environment config (never hardcode; support `dev`/`prod` flavors).
3. Build release artifacts: `flutter build appbundle` (Android), `flutter build ipa` (iOS).
4. Distribute to internal testers via Firebase App Distribution (fast, no store review needed) for the hackathon demo; store submission (Play Console / App Store Connect) is a post-hackathon step, not required for the July–August submission window.

### 17.4 CI/CD (GitHub Actions)
- On every PR: run backend unit + integration tests, run Flutter `flutter test` and `flutter analyze`, run web `npm run lint` and `npm run build`.
- On merge to `main`: auto-deploy backend to Render (via Render's GitHub integration) and web to Firebase Hosting; mobile builds remain manually triggered (release builds are deliberate, not continuous).

### 17.5 Pre-launch checklist
- [ ] `/health` green on production
- [ ] Seed database validated (≥200 claims, all four required fields present, §9.4)
- [ ] Rate limiting confirmed active in production config
- [ ] Firebase security rules reviewed (Firestore: users can only write their own `users/{uid}` and `legacyWall/{uid}` documents; `leaderboardCache` is read-only from the client)
- [ ] Crashlytics and Render logs both confirmed receiving events

---

## 18. Development milestones

Mapped to the hackathon's 4-week build window, each with a concrete Definition of Done.

| Week | Focus | Definition of done |
|---|---|---|
| 1 | Design & architecture | All 8 screens' wireframe descriptions finalized (§5); repo scaffolded per §11; PostgreSQL schema migrated; fact-check API keys obtained and test-called successfully |
| 2 | Core build | All 8 Flutter screens render with static/mock data and correct layout; `/api/analyze`, `/api/truthcard` endpoints functional against seeded data; web dashboard skeleton deployed with placeholder data |
| 3 | Polish & connect | Mobile app fully wired to live backend (no mock data remaining); all animations from §7 implemented; Legacy Wall + leaderboard functioning end-to-end; pilot test (§16.7) launched |
| 4 | Pitch & submit | Pitch video recorded; pilot test results collected and real numbers inserted into product copy and proposal doc; full manual QA checklist (§16.8) passed; proposal document finalized and exported to PDF; submission completed before August 16, 2026, with buffer by August 14 |

---

## 19. Step-by-step implementation roadmap

Ordered so an AI coding agent can execute sequentially with minimal ambiguity. Each phase assumes the previous phase's Definition of Done is met.

**Phase 0 — Repository setup**
1. Create the monorepo structure exactly as specified in §11.
2. Initialize `backend/` as a Poetry or pip-based Python 3.11 project with `requirements.txt` pinned per §12.
3. Initialize `mobile/` as a Flutter 3.x project; add dependencies (`rive`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `share_plus`, `http`, `cached_network_image`, `flutter_riverpod`).
4. Initialize `web/` with Vite + React + TypeScript + Tailwind; add `mapbox-gl`, `react-map-gl`, `d3`, `axios`, `recharts`, `@tanstack/react-query`.
5. Set up GitHub Actions workflows per §17.4 (they will fail initially with no tests — that's expected until Phase 1–3 add them).

**Phase 1 — Backend data layer**
6. Implement the SQLAlchemy models matching §9.1 exactly; generate the initial Alembic migration.
7. Implement `scripts/seed_database.py` with the validation rule from §9.4; source and load the first batch of seed claims (start with 20–30 to unblock Phase 2, grow to 200+ by end of Week 3).
8. Stand up Redis locally (Docker) and implement `cache/redis_client.py` with the hashing scheme from §14.5.

**Phase 2 — Backend API & NLP pipeline**
9. Implement `content_intake.py` (text/url/image → raw text), including the OCR and BeautifulSoup paths.
10. Implement `claim_extractor.py` (language detection, trigger-word stripping, claim isolation) and wire in the ClaimBuster check-worthiness call.
11. Implement `origin_tracer.py` using `pgvector` similarity search at the 0.75 threshold; implement the Google Fact Check fallback for near-misses.
12. Implement `mutation_tracker.py` and `damage_estimator.py` as direct, non-fabricating lookups per §14.4 and §14.6.
13. Wire all of the above into `POST /api/analyze` exactly per the request/response contract in §10.1, including the cache check as the very first step of the handler.
14. Implement `/api/truthcard`, `/api/legacy`, `/api/leaderboard`, `/api/stats/global`, and `/health` per §10.2–§10.6.
15. Implement Firebase token verification middleware (`core/security.py`) and apply the correct optional/required auth rule per endpoint.
16. Write backend unit and integration tests per §16.1–16.2 alongside each of the steps above, not as a separate pass at the end.

**Phase 3 — Mobile app, static first**
17. Implement the design system (`theme/`) from §8 as Dart constants/`ThemeData` before building any screen.
18. Build the component library from §6 with mock data and Storybook-style preview harness (a debug-only route that renders every component in isolation) to validate visuals before screen assembly.
19. Build all 8 screens per §5, wired to mock/static data first, matching every state (default/loading/error/empty) described.
20. Implement the animations from §7 on top of the static screens, gated behind the reduced-motion check from §8.8.

**Phase 4 — Mobile-backend integration**
21. Implement `api_service.dart` against the real backend (local/dev environment first); replace all mock data in the screens from step 19 with live calls.
22. Implement `auth_service.dart` (anonymous sign-in on launch, optional Google/Apple linking) per §13.
23. Implement `firestore_service.dart` for recent checks, Legacy Wall entries, and reading `leaderboardCache`.
24. Implement the share-intent entry point (`share_plus` receive intent) so ORACLE can be opened directly from another app's share sheet, skipping Home per §4.4.
25. Implement offline handling and the global `OfflineBanner` per §15's system/network edge cases.

**Phase 5 — Web dashboard**
26. Build the Home, Spread Map, Leaderboard, and API Docs pages per §4.6, consuming `/api/stats/global`, `/api/leaderboard`, and the OpenAPI schema FastAPI generates automatically.
27. Deploy to Firebase Hosting per §17.2.

**Phase 6 — Testing pass**
28. Execute the full test suite from §16.1–16.6.
29. Run the manual QA checklist (§16.8) against a full build.
30. Launch the pilot test (§16.7) — this can and should start as early as Phase 3 completes, running in parallel with Phases 4–5, since it takes two calendar weeks.

**Phase 7 — Deployment & submission**
31. Execute the production deployment steps in §17.1–17.3, followed by the pre-launch checklist in §17.5.
32. Insert the real pilot-test statistic (§16.7 step 4) into all product copy and pitch materials, replacing any placeholder numbers.
33. Record the pitch video demo using the live, deployed product (not a local dev build) to ensure what judges see matches what actually ships.
34. Final proposal document pass: add real team bios, the prototype URL, and confirm the technical section matches whatever actually got built (update anything that changed from this PRD during implementation).
35. Submit before August 16, 2026, targeting internal completion by August 14 for buffer.
