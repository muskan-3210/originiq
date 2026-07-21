# ORACLE — mobile app

Flutter client for **ORACLE — The Fake News Time Machine**. A user pastes,
shares, or uploads suspicious content; the app does everything else —
tracing where it was born, how it mutated, the damage it caused, and
closing with a shareable Truth Card. The user never answers questions or
takes a quiz.

This directory is self-contained: nothing outside `mobile/` was touched
while building it, and nothing in here assumes anything about the rest of
the monorepo beyond the `POST /api/analyze` (and friends) contract
described below.

> **This scaffold was written with no Flutter/Dart SDK available in the
> build environment.** Every screen, widget, model, and service is real,
> complete Dart — not stubs — but none of it has actually been run,
> compiled, or `flutter analyze`d. Treat first-run friction as expected;
> see "Known gaps" below for exactly what's left.

## Structure

```
mobile/
  lib/
    main.dart              Entry point — guarded Firebase.initializeApp, runApp(ProviderScope(OracleApp()))
    app.dart                MaterialApp: dark theme, named-route table for all 8 screens
    config/
      app_config.dart       Dev/prod base URLs + timeouts, resolved via --dart-define
    theme/                  Design tokens (§8) — colors, typography, spacing, shapes, ThemeData
    models/                 Analysis, Origin, Mutation, DamageStat, LegacyEntry, VerdictType
    services/
      api_service.dart      POST /api/analyze (text/url/image), /api/truthcard, /api/legacy, GET /api/leaderboard, /api/stats/global
      auth_service.dart     Silent Firebase anonymous sign-in + optional Google/Apple account linking
      firestore_service.dart Recent checks, Legacy Wall, leaderboard cache streams
      providers.dart         Every Riverpod provider wiring the above together
    screens/                One file per §5 screen (Splash, Home, Scanning, Origin, Mutation, Damage, Truth Card, Legacy Wall)
    widgets/                One file per §6 component (19 widgets)
    animations/             Shared curves + a reduced-motion-aware looping-animation wrapper
    utils/
      mock_data.dart         Sample Analysis/LegacyEntry data every screen renders from today
      constants.dart         Copy strings, timing constants, Firestore path segments
      formatters.dart        Relative time, number formatting, truncation, country/platform names
  assets/
    rive/.gitkeep            crystal_ball.riv goes here (splash uses a hand-rolled fallback until then)
    fonts/.gitkeep            Space Grotesk + Inter .ttf files go here
  test/
    screens/                 One light widget test per screen
    README.md                 How these tests are structured and what they don't cover yet
  pubspec.yaml
  analysis_options.yaml
```

## Running it (once Flutter is installed)

```bash
cd mobile
flutter pub get
flutter run
```

Without any further setup, the app **launches and is fully click-through
navigable end to end using mock data** (see `lib/utils/mock_data.dart`) —
Firebase and the real backend are both optional for reviewing the UI.
Firebase failures are swallowed by design (`AuthService` and
`main.dart` both guard against it — see §5 screen 1's "log silently and
proceed anyway" rule).

Run the widget tests:

```bash
flutter test
```

See `test/README.md` for how those are structured (provider overrides
instead of Firebase mocks, why `pumpAndSettle()` is never used, etc.).

## What must be supplied before this is a real, shippable app

1. **Fonts.** Drop `SpaceGrotesk-Regular.ttf`, `SpaceGrotesk-Medium.ttf`,
   `Inter-Regular.ttf`, and `Inter-Medium.ttf` into `assets/fonts/`
   (both families are free on Google Fonts), then uncomment the `fonts:`
   block in `pubspec.yaml` — it's commented out for now because Flutter's
   asset bundler hard-fails the build if a declared font file is missing.
   Until then, text silently falls back to the platform default font;
   nothing crashes.

2. **The crystal-ball Rive animation.** Drop `crystal_ball.riv` into
   `assets/rive/` and wire it into `lib/screens/splash_screen.dart`
   (`_CrystalBall`) via `RiveAnimation.asset(...)` — the `rive` package is
   already a dependency. Until then, splash shows a hand-rolled glowing,
   floating circle in its place.

3. **Firebase project config.** Run `flutterfire configure` (or manually
   add `android/app/google-services.json` and
   `ios/Runner/GoogleService-Info.plist`) for a real Firebase project with
   Anonymous Auth, Firestore, and Storage enabled. `main.dart` calls
   `Firebase.initializeApp()` in a try/catch specifically so a missing
   config doesn't crash the app — but Recent checks, Legacy Wall, and
   `postLegacy` all need it to do anything real.

4. **A reachable backend.** `lib/config/app_config.dart` points at
   `http://localhost:8000/api` (dev) and a placeholder
   `https://api.oracle.example.com/api` (prod) — override either via
   `--dart-define=ORACLE_API_BASE_URL_DEV=...` /
   `--dart-define=ORACLE_API_BASE_URL_PROD=...`, or edit the fallback
   directly. Pick the flavor with `--dart-define=ORACLE_FLAVOR=prod`.

5. **Swap mock data for the real API call.** Every screen currently reads
   from `lib/utils/mock_data.dart` (via `currentAnalysisProvider`,
   `recentChecksProvider`, etc. — see `lib/services/providers.dart`).
   The one call site that actually needs to change is
   `ScanningScreen._finishScan()` in `lib/screens/scanning_screen.dart`,
   which has an explicit `NOTE(mock data)` comment showing the
   `ApiService.analyzeText/analyzeUrl/analyzeImage` calls to switch in.

6. **Photo upload.** The Home screen's photo icon
   (`PasteInputCard`/`HomeScreen._handlePickPhoto`) currently shows a
   snackbar explaining it isn't wired up — reading real image bytes needs
   an image-picking package (e.g. `image_picker`), which was intentionally
   left out of this scaffold's fixed dependency list. Add it, then thread
   the picked bytes into `ApiService.analyzeImage`.

7. **Package versions.** This environment had no live access to pub.dev,
   so every version in `pubspec.yaml` is a best-effort recollection, not a
   confirmed-current release. Run `flutter pub outdated` and bump
   anything that's fallen behind (Firebase packages in particular tend to
   ship breaking major versions periodically).

8. **Google/Apple account linking.** `AuthService.linkWithGoogleCredential`
   /`linkWithAppleCredential` are fully implemented against
   `firebase_auth`'s credential APIs, but obtaining the native
   idToken/accessToken/rawNonce they take as input needs `google_sign_in`
   / `sign_in_with_apple` (also not in this scaffold's dependency list).

9. **OS share-intent handling.** Per §5 screen 2, opening the app via an
   OS share sheet should skip Home and land directly on Scanning with the
   shared content pre-filled. That needs a package like
   `receive_sharing_intent`; the hook point is noted in both
   `lib/app.dart` and `lib/screens/splash_screen.dart`.

10. **Reopening a Legacy Wall / recent-check entry.** Tapping a
    `LegacyGridItem` or `RecentCheckRow` currently shows a snackbar rather
    than actually re-hydrating the full `Analysis` (the compact
    `LegacyEntry`/summary `Analysis` stored for those lists doesn't carry
    the full origin/mutation/damage payload). The real fix is a new
    `ApiService` method to fetch a full `Analysis` by id — the call site
    is marked with a `TODO(real data)` comment in
    `lib/screens/legacy_wall_screen.dart`.

## Design system notes

Everything under `lib/theme/` mirrors the ORACLE spec (§8) as literal,
named tokens — no widget hardcodes a hex color, a spacing number, or a
radius; they all reference `OracleColors`/`OracleSpacing`/`OracleShapes`/
`OracleTypography`. If the palette or scale ever changes, it changes in
exactly one place.

The app is dark-only by design (`OracleAppTheme.dark`, forced via
`themeMode: ThemeMode.dark` in `app.dart`) — there is no light theme to
maintain.
