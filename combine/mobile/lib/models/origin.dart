/// Where a piece of misinformation was first traced back to.
///
/// Matches the `origin` object of `POST /api/analyze`:
/// ```json
/// { "platform":"whatsapp","country":"IN","date":"2020-03-14",
///   "tags":["health-misinformation","covid-era"],"hops_traced":6 }
/// ```
/// `origin` is `null` in the response for `unverified` results — callers
/// should treat a `null` origin as "no match found" rather than construct a
/// placeholder [Origin].
final class Origin {
  const Origin({
    required this.platform,
    required this.country,
    required this.date,
    required this.tags,
    required this.hopsTraced,
  });

  /// e.g. "whatsapp", "facebook", "twitter".
  final String platform;

  /// ISO 3166-1 alpha-2 country code, e.g. "IN".
  final String country;

  /// The date the claim first appeared.
  final DateTime date;

  /// Category tags, e.g. "health-misinformation", "covid-era".
  final List<String> tags;

  /// Number of platforms/hops traced between origin and the pasted content.
  final int hopsTraced;

  factory Origin.fromJson(Map<String, dynamic> json) {
    return Origin(
      platform: json['platform'] as String,
      country: json['country'] as String,
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic tag) => tag as String)
          .toList(growable: false),
      hopsTraced: json['hops_traced'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'platform': platform,
      'country': country,
      'date': _formatDate(date),
      'tags': tags,
      'hops_traced': hopsTraced,
    };
  }

  static String _formatDate(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Origin copyWith({
    String? platform,
    String? country,
    DateTime? date,
    List<String>? tags,
    int? hopsTraced,
  }) {
    return Origin(
      platform: platform ?? this.platform,
      country: country ?? this.country,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      hopsTraced: hopsTraced ?? this.hopsTraced,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Origin &&
        other.platform == platform &&
        other.country == country &&
        other.date == date &&
        _listEquals(other.tags, tags) &&
        other.hopsTraced == hopsTraced;
  }

  @override
  int get hashCode {
    return Object.hash(platform, country, date, Object.hashAll(tags), hopsTraced);
  }

  @override
  String toString() {
    return 'Origin(platform: $platform, country: $country, date: $date, '
        'tags: $tags, hopsTraced: $hopsTraced)';
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
