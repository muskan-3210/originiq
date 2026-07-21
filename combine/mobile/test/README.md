# Widget tests

These tests need the Flutter SDK (`flutter test`) to run — this scaffold
was produced in an environment with no Flutter/Dart SDK installed, so none
of the code here (app or tests) has actually been executed or verified by
running it. Everything was written to be correct by inspection; treat
these as a starting point and re-check them once the SDK is available.

## Running

```
cd mobile
flutter test
```

## What's covered

One `test/screens/<name>_screen_test.dart` per screen in `lib/screens/`,
each a light smoke test: pump the screen, assert its key content/actions
are present, and (for the screens that auto-advance per §4.1) advance
fake time far enough to confirm navigation actually happens.

## Patterns used throughout

- **Provider overrides instead of Firebase mocks.** Several providers in
  `lib/services/providers.dart` construct `AuthService`/`FirestoreService`,
  which talk to `FirebaseAuth.instance`/`FirebaseFirestore.instance` —
  neither exists in a plain widget test (no `Firebase.initializeApp()` was
  run, and there's no real backend). Rather than mock Firebase itself
  (which would need a package like `firebase_auth_mocks` — not in this
  scaffold's fixed dev-dependency list), each test overrides the
  screen-facing provider directly (`recentChecksProvider`,
  `legacyWallProvider`, `leaderboardProvider`, `currentAnalysisProvider`)
  with canned data via `ProviderScope(overrides: [...])`. Because Riverpod
  overrides replace the provider's implementation outright, the original
  (Firebase-touching) provider body never runs.

- **`SplashScreen` is the one exception** — it calls
  `ref.read(authServiceProvider)` directly. Its test supplies a
  `noSuchMethod`-backed fake (`_NoopAuthService implements AuthService`)
  that overrides only `signInAnonymouslySilently()` and lets every other
  member fall through to `noSuchMethod`. This is the same technique
  Mockito-style mocks use internally and avoids needing a mocking package.

- **Never `tester.pumpAndSettle()`.** Several screens have deliberately
  infinite looping animations (the splash crystal-ball float, the
  Scanning clock's rotate+bob, the Legacy Wall's empty-slot pulse) —
  `pumpAndSettle()` would hang waiting for them to finish, since they
  never do. Every test uses bounded `tester.pump()`/`tester.pump(duration)`
  calls instead.

- **Screens that auto-advance get pumped past their timer.** Per §4.1,
  Splash and Scanning (and, once an analysis is in flight, Origin/
  Mutation/Damage) each auto-navigate via a real `Timer`. Flutter's test
  binding fails a test if a `Timer` is still pending when it ends, so
  those tests advance fake time past the relevant duration (and register
  a lightweight placeholder route for wherever navigation lands) rather
  than leaving it mid-flight.

## Known gaps

- These tests don't exercise real network/Firebase/share-sheet calls —
  by design, given the mock-data scope of this scaffold. Once the real
  `ApiService`/`AuthService`/`FirestoreService` wiring lands, add
  integration coverage (the `integration_test` dev-dependency is already
  in `pubspec.yaml` for that) alongside these widget tests.
- Exact timings (dwell durations, stage durations) live in
  `lib/utils/constants.dart` — if those change, the corresponding
  `tester.pump(duration)` calls in these tests need to keep exceeding them.
