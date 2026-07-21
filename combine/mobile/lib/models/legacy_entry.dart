import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'verdict.dart';

/// A single past catch on a user's Legacy Wall (§5 screen 8).
///
/// Mirrors documents under the Firestore path `legacyWall/{uid}/entries`
/// (see `lib/services/firestore_service.dart`). Each entry is a compact
/// pointer back to a completed [Analysis] rather than a full copy of it —
/// tapping a [LegacyGridItem] re-fetches (or re-hydrates from cache) the
/// full Truth Card for read-only viewing.
final class LegacyEntry {
  const LegacyEntry({
    required this.id,
    required this.analysisId,
    required this.verdict,
    required this.claimExcerpt,
    required this.createdAt,
    this.truthCardImageUrl,
  });

  /// Firestore document id.
  final String id;

  /// The `Analysis.id` this entry points back to, so the full Truth Card
  /// can be re-opened read-only.
  final String analysisId;

  final VerdictType verdict;

  /// A short excerpt of the original claim, shown as a fallback label when
  /// no snapshot image is available.
  final String claimExcerpt;

  /// When this catch was recorded, used to sort most-recent-first.
  final DateTime createdAt;

  /// Optional Firebase Storage URL of the generated Truth Card PNG
  /// snapshot, used as the grid icon thumbnail when present.
  final String? truthCardImageUrl;

  factory LegacyEntry.fromJson(Map<String, dynamic> json) {
    return LegacyEntry(
      id: json['id'] as String,
      analysisId: json['analysis_id'] as String,
      verdict: VerdictType.fromWire(json['verdict'] as String),
      claimExcerpt: json['claim_excerpt'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      truthCardImageUrl: json['truth_card_image_url'] as String?,
    );
  }

  /// Hydrates a [LegacyEntry] from a Firestore `legacyWall/{uid}/entries`
  /// document (see `FirestoreService.watchLegacyWall`). Firestore stores
  /// timestamps as [Timestamp] rather than ISO-8601 strings, so this does
  /// not reuse [fromJson] as-is — it accepts either representation.
  factory LegacyEntry.fromFirestore(String docId, Map<String, dynamic> data) {
    return LegacyEntry(
      id: docId,
      analysisId: data['analysis_id'] as String? ?? docId,
      verdict: VerdictType.fromWire(data['verdict'] as String? ?? 'unverified'),
      claimExcerpt: data['claim_excerpt'] as String? ?? '',
      createdAt: _parseFirestoreTimestamp(data['created_at']) ?? DateTime.now(),
      truthCardImageUrl: data['truth_card_image_url'] as String?,
    );
  }

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
      'analysis_id': analysisId,
      'verdict': verdict.wireValue,
      'claim_excerpt': claimExcerpt,
      'created_at': createdAt.toIso8601String(),
      if (truthCardImageUrl != null) 'truth_card_image_url': truthCardImageUrl,
    };
  }

  LegacyEntry copyWith({
    String? id,
    String? analysisId,
    VerdictType? verdict,
    String? claimExcerpt,
    DateTime? createdAt,
    String? truthCardImageUrl,
  }) {
    return LegacyEntry(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
      verdict: verdict ?? this.verdict,
      claimExcerpt: claimExcerpt ?? this.claimExcerpt,
      createdAt: createdAt ?? this.createdAt,
      truthCardImageUrl: truthCardImageUrl ?? this.truthCardImageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegacyEntry &&
        other.id == id &&
        other.analysisId == analysisId &&
        other.verdict == verdict &&
        other.claimExcerpt == claimExcerpt &&
        other.createdAt == createdAt &&
        other.truthCardImageUrl == truthCardImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      analysisId,
      verdict,
      claimExcerpt,
      createdAt,
      truthCardImageUrl,
    );
  }

  @override
  String toString() => 'LegacyEntry(id: $id, verdict: $verdict)';
}
