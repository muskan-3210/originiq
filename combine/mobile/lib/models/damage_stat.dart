/// A single real-world impact statistic for the Damage report screen.
///
/// Matches one entry of the `damage` array of `POST /api/analyze`:
/// ```json
/// { "label":"People misled","value":47000,"description":"...",
///   "source_name":"Reuters","source_url":"https://..." }
/// ```
/// The Damage screen (§5 screen 6) renders only the stats that exist in
/// this list — never a fabricated placeholder stat.
final class DamageStat {
  const DamageStat({
    required this.label,
    required this.value,
    required this.description,
    this.sourceName,
    this.sourceUrl,
  });

  /// e.g. "People misled", "Countries affected", "Peak shares/day", "Days
  /// active".
  final String label;

  /// The raw numeric value backing the stat, animated 0 -> final on-screen.
  final num value;

  /// A short supporting sentence for the stat.
  final String description;

  /// Optional attribution, e.g. "Reuters".
  final String? sourceName;

  /// Optional link to the source backing this stat.
  final String? sourceUrl;

  bool get hasSource => sourceName != null && sourceName!.isNotEmpty;

  factory DamageStat.fromJson(Map<String, dynamic> json) {
    return DamageStat(
      label: json['label'] as String,
      value: json['value'] as num,
      description: json['description'] as String? ?? '',
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'value': value,
      'description': description,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceUrl != null) 'source_url': sourceUrl,
    };
  }

  DamageStat copyWith({
    String? label,
    num? value,
    String? description,
    String? sourceName,
    String? sourceUrl,
  }) {
    return DamageStat(
      label: label ?? this.label,
      value: value ?? this.value,
      description: description ?? this.description,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DamageStat &&
        other.label == label &&
        other.value == value &&
        other.description == description &&
        other.sourceName == sourceName &&
        other.sourceUrl == sourceUrl;
  }

  @override
  int get hashCode {
    return Object.hash(label, value, description, sourceName, sourceUrl);
  }

  @override
  String toString() => 'DamageStat(label: $label, value: $value)';
}
