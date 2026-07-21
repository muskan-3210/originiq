import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/analysis.dart';
import '../models/legacy_entry.dart';
import '../utils/constants.dart';
import 'api_service.dart' show LeaderboardEntry;

/// Reads/streams the Firestore-backed parts of ORACLE's data model.
///
/// `ApiService` (backed by `POST /api/analyze` and friends) is the source
/// of truth for *running* an analysis. This service is the source of truth
/// for *reading back* what's already been recorded for a given user —
/// recent checks and the Legacy Wall — plus the shared leaderboard cache.
///
/// `FirebaseFirestore.instance` throws synchronously if no Firebase app has
/// been initialized (see the matching note on `AuthService`), so `_firestore`
/// is null in that case and every read degrades to an empty result instead —
/// consistent with this class's own "a missing leaderboard/wall is a
/// legitimate empty state, not an error" stance below.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore =
            firestore ?? (Firebase.apps.isEmpty ? null : FirebaseFirestore.instance);

  final FirebaseFirestore? _firestore;

  /// Streams up to [limit] of a user's most recent checks, most recent
  /// first, from `users/{uid}/checks`. Powers the Home screen's "Recent
  /// checks" rows (§5 screen 2).
  Stream<List<Analysis>> watchRecentChecks(
    String uid, {
    int limit = OracleConstants.recentChecksLimit,
  }) {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) return Stream<List<Analysis>>.value(const <Analysis>[]);
    return firestore
        .collection(OracleConstants.firestoreUsersCollection)
        .doc(uid)
        .collection(OracleConstants.firestoreChecksSubcollection)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                Analysis.fromFirestore(doc.id, doc.data()),
          )
          .toList(growable: false);
    });
  }

  /// Streams a user's Legacy Wall entries, most recent first, from
  /// `legacyWall/{uid}/entries`. Powers the Legacy Wall grid (§5 screen 8).
  Stream<List<LegacyEntry>> watchLegacyWall(String uid) {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) {
      return Stream<List<LegacyEntry>>.value(const <LegacyEntry>[]);
    }
    return firestore
        .collection(OracleConstants.firestoreLegacyWallCollection)
        .doc(uid)
        .collection(OracleConstants.firestoreLegacyEntriesSubcollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                LegacyEntry.fromFirestore(doc.id, doc.data()),
          )
          .toList(growable: false);
    });
  }

  /// Reads the precomputed `leaderboardCache` collection rather than
  /// aggregating scores on-device. Returns an empty list if the cache
  /// doesn't exist yet rather than throwing — a missing leaderboard is a
  /// legitimate "nothing here yet" empty state, not an error.
  ///
  /// Field-name caveat: same as `ApiService.getLeaderboard` — the task
  /// brief doesn't pin down the leaderboard document schema, so this
  /// assumes documents shaped like `{ scope, rank, display_name,
  /// catches_count }`. Adjust once the real schema is confirmed.
  Future<List<LeaderboardEntry>> readLeaderboardCache({
    String scope = 'global',
    int limit = 20,
  }) async {
    final FirebaseFirestore? firestore = _firestore;
    if (firestore == null) return const <LeaderboardEntry>[];
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection(OracleConstants.firestoreLeaderboardCacheCollection)
        .where('scope', isEqualTo: scope)
        .orderBy('rank')
        .limit(limit)
        .get();
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              LeaderboardEntry.fromJson(doc.data()),
        )
        .toList(growable: false);
  }
}
