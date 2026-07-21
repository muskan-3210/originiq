/// A single mutated version of a claim as it spread to a new country.
///
/// Matches one entry of the `mutations` array of `POST /api/analyze`:
/// ```json
/// { "version":2,"country":"BR","date":"2020-04-02",
///   "text_excerpt":"...","similarity_to_origin":0.81 }
/// ```
final class Mutation {
  const Mutation({
    required this.version,
    required this.country,
    required this.date,
    required this.textExcerpt,
    required this.similarityToOrigin,
  });

  /// 1-based order in which this mutation appeared (origin is implicitly
  /// version 1; the `mutations` array starts at version 2 onward per the
  /// sample payload).
  final int version;

  /// ISO 3166-1 alpha-2 country code, e.g. "BR".
  final String country;

  /// The date this mutated version appeared.
  final DateTime date;

  /// A short excerpt of the mutated wording.
  final String textExcerpt;

  /// 0.0-1.0 similarity score to the original claim.
  final double similarityToOrigin;

  factory Mutation.fromJson(Map<String, dynamic> json) {
    return Mutation(
      version: json['version'] as int,
      country: json['country'] as String,
      date: DateTime.parse(json['date'] as String),
      textExcerpt: json['text_excerpt'] as String,
      similarityToOrigin: (json['similarity_to_origin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'country': country,
      'date': _formatDate(date),
      'text_excerpt': textExcerpt,
      'similarity_to_origin': similarityToOrigin,
    };
  }

  static String _formatDate(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Mutation copyWith({
    int? version,
    String? country,
    DateTime? date,
    String? textExcerpt,
    double? similarityToOrigin,
  }) {
    return Mutation(
      version: version ?? this.version,
      country: country ?? this.country,
      date: date ?? this.date,
      textExcerpt: textExcerpt ?? this.textExcerpt,
      similarityToOrigin: similarityToOrigin ?? this.similarityToOrigin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mutation &&
        other.version == version &&
        other.country == country &&
        other.date == date &&
        other.textExcerpt == textExcerpt &&
        other.similarityToOrigin == similarityToOrigin;
  }

  @override
  int get hashCode {
    return Object.hash(version, country, date, textExcerpt, similarityToOrigin);
  }

  @override
  String toString() {
    return 'Mutation(version: $version, country: $country, date: $date, '
        'similarityToOrigin: $similarityToOrigin)';
  }
}
