import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/analysis.dart';
import '../models/legacy_entry.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// The resolved [AppConfig] for this build (dev vs prod chosen by the
/// `ORACLE_FLAVOR` dart-define — see that class).
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.current;
});

/// The single [AuthService] instance for the app's lifetime.
final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) {
  final AuthService service = AuthService();
  ref.onDispose(service.dispose);
  return service;
});

/// The single [FirestoreService] instance for the app's lifetime.
final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// The single [ApiService] instance for the app's lifetime. Reads the
/// current ID token from [authServiceProvider] on every request rather than
/// capturing it once, so a token refresh mid-session is picked up
/// automatically.
final Provider<ApiService> apiServiceProvider = Provider<ApiService>((ref) {
  final AppConfig config = ref.watch(appConfigProvider);
  final AuthService auth = ref.watch(authServiceProvider);
  final ApiService service = ApiService(
    config: config,
    authTokenProvider: () => auth.currentIdToken,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Fires on sign-in, sign-out, and (implicitly) the initial anonymous
/// sign-in performed at startup — see `main.dart`.
final StreamProvider<User?> authStateChangesProvider = StreamProvider<User?>((
  ref,
) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// The signed-in uid, or null before the initial anonymous sign-in
/// resolves. Most screens should prefer this over reading
/// [authStateChangesProvider] directly.
final Provider<String?> currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateChangesProvider).valueOrNull?.uid;
});

/// Up to `OracleConstants.recentChecksLimit` of the current user's most
/// recent checks, most recent first, for the Home screen (§5 screen 2).
/// Emits an empty list (rather than erroring) until a uid is available.
final StreamProvider<List<Analysis>> recentChecksProvider =
    StreamProvider<List<Analysis>>((ref) {
  final String? uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream<List<Analysis>>.value(const <Analysis>[]);
  return ref.watch(firestoreServiceProvider).watchRecentChecks(uid);
});

/// The current user's Legacy Wall entries, most recent first, for §5
/// screen 8. Emits an empty list until a uid is available.
final StreamProvider<List<LegacyEntry>> legacyWallProvider =
    StreamProvider<List<LegacyEntry>>((ref) {
  final String? uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return Stream<List<LegacyEntry>>.value(const <LegacyEntry>[]);
  }
  return ref.watch(firestoreServiceProvider).watchLegacyWall(uid);
});

/// The leaderboard teaser shown at the bottom of the Legacy Wall.
final FutureProvider<List<LeaderboardEntry>> leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) {
  return ref.watch(firestoreServiceProvider).readLeaderboardCache();
});

/// The analysis currently moving through the golden path (Scanning ->
/// Origin -> Mutation -> Damage -> Truth Card). Null before a scan
/// completes, and reset to null once the user leaves the golden path (Home
/// or Legacy Wall) so the next scan starts clean.
final StateProvider<Analysis?> currentAnalysisProvider =
    StateProvider<Analysis?>((ref) => null);

/// Whether the device currently appears offline, for [OfflineBanner].
///
/// NOTE: this is a manual flag, not real connectivity detection — wiring
/// that up needs a package like `connectivity_plus`, which isn't in this
/// scaffold's dependency list (see `pubspec.yaml`). Defaults to `false` so
/// the banner never appears unexpectedly in the mock-data build. Toggle it
/// from `ApiService` call sites (e.g. on a `SocketException`) once real
/// networking lands.
final StateProvider<bool> isOfflineProvider = StateProvider<bool>(
  (ref) => false,
);
