import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'damage_stat.dart';
import 'mutation.dart';
import 'origin.dart';
import 'verdict.dart';

/// The full result of submitting content to `POST /api/analyze`.
///
/// Matches the backend response exactly:
/// ```json
/// { "id":"b3f1...", "verdict":"false", "cached":false,
///   "origin":{...}, "mutations":[...], "damage":[...],
///   "truth_card_ready":true }
/// ```
/// No-match / unverified responses look like:
/// ```json
/// { "id":"...", "verdict":"unverified", "cached":false,
///   "origin":null, "mutations":[], "damage":[], "truth_card_ready":false }
/// ```
///
/// [claimText] and [createdAt] are **not** part of the `/api/analyze` wire
/// schema — that endpoint has no knowledge of relative time or of echoing
/// back the submitted text. They are populated client-side instead:
///   - immediately after a successful `analyzeText`/`analyzeUrl`/
///     `analyzeImage` call, from the text the user actually submitted and
///     `DateTime.now()` (see `ApiService`), and
///   - when hydrating "Recent checks" from Firestore (`users/{uid}/checks`,
///     see `FirestoreService`), via [Analysis.fromFirestore], since that
///     collection is expected to store the submitted snippet + timestamp
///     alongside the verdict.
/// Screens should treat both fields as optional and fall back gracefully
/// (see `RecentCheckRow`).
final class Analysis {
  const Analysis({
    required this.id,
    required this.verdict,
    required this.cached,
    required this.origin,
    required this.mutations,
    required this.damage,
    required this.truthCardReady,
    this.claimText,
    this.createdAt,
  });

  final String id;
  final VerdictType verdict;
  final bool cached;

  /// `null` when [verdict] is [VerdictType.unverified] — no origin was
  /// found. Never populate this with placeholder data.
  final Origin? origin;

  final List<Mutation> mutations;
  final List<DamageStat> damage;
  final bool truthCardReady;

  /// The originally submitted text (or a caption for image/URL submissions).
  /// See class doc — not part of the server schema.
  final String? claimText;

  /// When this analysis was created. See class doc — not part of the
  /// server schema.
  final DateTime? createdAt;

  bool get hasOrigin => origin != null;
  bool get hasMutations => mutations.isNotEmpty;
  bool get hasDamage => damage.isNotEmpty;

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      id: json['id'] as String,
      verdict: VerdictType.fromWire(json['verdict'] as String),
      cached: json['cached'] as bool? ?? false,
      origin: json['origin'] == null
          ? null
          : Origin.fromJson(json['origin'] as Map<String, dynamic>),
      mutations: (json['mutations'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic m) => Mutation.fromJson(m as Map<String, dynamic>))
          .toList(growable: false),
      damage: (json['damage'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic d) => DamageStat.fromJson(d as Map<String, dynamic>))
          .toList(growable: false),
      truthCardReady: json['truth_card_ready'] as bool? ?? false,
    );
  }

  /// Hydrates an [Analysis] summary from a Firestore `users/{uid}/checks`
  /// document (see `FirestoreService.watchRecentChecks`). These documents
  /// are expected to carry only a summary (id, verdict, snippet, timestamp)
  /// rather than the full origin/mutation/damage breakdown, since that is
  /// re-fetched from the API on demand when a recent check is reopened.
  factory Analysis.fromFirestore(String docId, Map<String, dynamic> data) {
    return Analysis(
      id: (data['analysis_id'] as String?) ?? docId,
      verdict: VerdictType.fromWire(data['verdict'] as String? ?? 'unverified'),
      cached: true,
      origin: null,
      mutations: const <Mutation>[],
      damage: const <DamageStat>[],
      truthCardReady: data['truth_card_ready'] as bool? ?? false,
      claimText: data['claim_excerpt'] as String? ?? data['snippet'] as String?,
      createdAt: _parseFirestoreTimestamp(data['created_at']),
    );
  }

  /// Firestore stores timestamps as [Timestamp], not ISO-8601 strings —
  /// this accepts either (plus a raw [DateTime], for tests that construct
  /// fake Firestore data by hand) so a schema tweak on the backend doesn't
  /// silently drop every recent check's timestamp.
  static DateTime? _parseFirestoreTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'verdict': verdict.wireValue,
      'cached': cached,
      'origin': origin?.toJson(),
      'mutations': mutations.map((Mutation m) => m.toJson()).toList(),
      'damage': damage.map((DamageStat d) => d.toJson()).toList(),
      'truth_card_ready': truthCardReady,
    };
  }

  Analysis copyWith({
    String? id,
    VerdictType? verdict,
    bool? cached,
    Origin? origin,
    bool clearOrigin = false,
    List<Mutation>? mutations,
    List<DamageStat>? damage,
    bool? truthCardReady,
    String? claimText,
    DateTime? createdAt,
  }) {
    return Analysis(
      id: id ?? this.id,
      verdict: verdict ?? this.verdict,
      cached: cached ?? this.cached,
      origin: clearOrigin ? null : (origin ?? this.origin),
      mutations: mutations ?? this.mutations,
      damage: damage ?? this.damage,
      truthCardReady: truthCardReady ?? this.truthCardReady,
      claimText: claimText ?? this.claimText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Analysis &&
        other.id == id &&
        other.verdict == verdict &&
        other.cached == cached &&
        other.origin == origin &&
        other.truthCardReady == truthCardReady &&
        other.claimText == claimText &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, verdict, cached, origin, truthCardReady, claimText, createdAt);
  }

  @override
  String toString() => 'Analysis(id: $id, verdict: $verdict)';
}
