import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/analysis.dart';

/// A single row of the leaderboard returned by `GET /api/leaderboard`.
///
/// The task brief specifies this endpoint's existence but not its exact
/// response shape, so parsing is deliberately defensive — every field falls
/// back to a sane default rather than throwing. Tighten this once the real
/// backend contract is available. Not placed under `lib/models/` since the
/// brief pins that directory to exactly: Analysis, Origin, Mutation,
/// DamageStat, LegacyEntry, VerdictType.
final class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.catchesCount,
    this.isCurrentUser = false,
  });

  final int rank;
  final String displayName;
  final int catchesCount;
  final bool isCurrentUser;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      displayName: (json['display_name'] ?? json['name']) as String? ??
          'Anonymous',
      catchesCount:
          (json['catches_count'] ?? json['catches']) as int? ?? 0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }
}

/// Aggregate figures returned by `GET /api/stats/global`.
///
/// Same caveat as [LeaderboardEntry]: parsed defensively pending the real
/// contract.
final class GlobalStats {
  const GlobalStats({
    required this.totalClaimsTraced,
    required this.totalCountriesReached,
    required this.totalUsers,
  });

  final int totalClaimsTraced;
  final int totalCountriesReached;
  final int totalUsers;

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      totalClaimsTraced: json['total_claims_traced'] as int? ?? 0,
      totalCountriesReached: json['total_countries_reached'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? 0,
    );
  }
}

/// Result of [ApiService.generateTruthCard]. See that method's doc for why
/// this shape is a best-effort guess pending the real backend contract.
final class TruthCardResult {
  const TruthCardResult({required this.truthCardId, this.shareUrl});

  final String truthCardId;

  /// An optional shareable web link to accompany the on-device PNG
  /// snapshot, if the backend provides one.
  final String? shareUrl;
}

/// Thrown for any non-2xx [ApiService] response, carrying enough context
/// for the Scanning screen's error state / [ErrorBanner] without callers
/// needing to inspect raw HTTP details.
final class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Talks to the ORACLE backend.
///
/// Every method resolves its host from [AppConfig] — never hardcode a URL
/// inline. When [authTokenProvider] returns a non-empty token, it's
/// attached as `Authorization: Bearer <token>` on every request (not just
/// the ones that strictly require it), per the service brief.
class ApiService {
  ApiService({
    required AppConfig config,
    http.Client? client,
    String? Function()? authTokenProvider,
  })  : _config = config,
        _client = client ?? http.Client(),
        _authTokenProvider = authTokenProvider;

  final AppConfig _config;
  final http.Client _client;
  final String? Function()? _authTokenProvider;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final String? token = _authTokenProvider?.call();
    return <String, String>{
      'Accept': 'application/json',
      if (extra != null) ...extra,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final Uri base = Uri.parse(_config.apiBaseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters:
          query?.map((String k, dynamic v) => MapEntry<String, String>(k, '$v')),
    );
  }

  /// `POST /api/analyze` with a pasted or typed text claim.
  Future<Analysis> analyzeText(String text) async {
    final http.Response response = await _client
        .post(
          _uri('/analyze'),
          headers: _headers(extra: <String, String>{
            'Content-Type': 'application/json',
          }),
          body: jsonEncode(<String, dynamic>{'type': 'text', 'text': text}),
        )
        .timeout(_config.requestTimeout);
    return _parseAnalysis(response, fallbackClaimText: text);
  }

  /// `POST /api/analyze` with a URL whose content should be fetched and
  /// analyzed.
  Future<Analysis> analyzeUrl(String url) async {
    final http.Response response = await _client
        .post(
          _uri('/analyze'),
          headers: _headers(extra: <String, String>{
            'Content-Type': 'application/json',
          }),
          body: jsonEncode(<String, dynamic>{'type': 'url', 'url': url}),
        )
        .timeout(_config.requestTimeout);
    return _parseAnalysis(response, fallbackClaimText: url);
  }

  /// `POST /api/analyze` (multipart) with an image whose embedded text
  /// should be read (OCR) and analyzed. See the Scanning screen's "Reading
  /// image text" first-step behavior for image submissions.
  Future<Analysis> analyzeImage(
    Uint8List imageBytes, {
    required String filename,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', _uri('/analyze'))
          ..headers.addAll(_headers())
          ..fields['type'] = 'image'
          ..files.add(
            http.MultipartFile.fromBytes(
              'image',
              imageBytes,
              filename: filename,
            ),
          );
    final http.StreamedResponse streamed =
        await _client.send(request).timeout(_config.requestTimeout);
    final http.Response response = await http.Response.fromStream(streamed);
    return _parseAnalysis(response);
  }

  /// `POST /api/truthcard` with `{ "analysis_id": analysisId }`.
  ///
  /// The Truth Card image itself is generated on-device (RepaintBoundary +
  /// `toImage`, per §5 screen 7) — this call is for whatever server-side
  /// bookkeeping accompanies that (e.g. minting a shareable web link).
  /// Response shape isn't pinned down by the task brief, so both
  /// `truth_card_id`/`id` and `share_url`/`url` are accepted defensively.
  Future<TruthCardResult> generateTruthCard(String analysisId) async {
    final http.Response response = await _client
        .post(
          _uri('/truthcard'),
          headers: _headers(extra: <String, String>{
            'Content-Type': 'application/json',
          }),
          body: jsonEncode(<String, dynamic>{'analysis_id': analysisId}),
        )
        .timeout(_config.requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The truth card could not be prepared.',
        statusCode: response.statusCode,
      );
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return TruthCardResult(
      truthCardId:
          (json['truth_card_id'] ?? json['id']) as String? ?? analysisId,
      shareUrl: (json['share_url'] ?? json['url']) as String?,
    );
  }

  /// `POST /api/legacy` with `{ "analysis_id": analysisId }`. Requires a
  /// Firebase ID token — throws [ApiException] up front if none is
  /// available yet rather than making a call the backend would reject.
  Future<void> postLegacy({required String analysisId}) async {
    final String? token = _authTokenProvider?.call();
    if (token == null || token.isEmpty) {
      throw ApiException(
        'Sign-in is still starting up — try again in a moment.',
      );
    }
    final http.Response response = await _client
        .post(
          _uri('/legacy'),
          headers: _headers(extra: <String, String>{
            'Content-Type': 'application/json',
          }),
          body: jsonEncode(<String, dynamic>{'analysis_id': analysisId}),
        )
        .timeout(_config.requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'This catch could not be saved to your legacy wall.',
        statusCode: response.statusCode,
      );
    }
  }

  /// `GET /api/leaderboard?scope=&limit=`.
  Future<List<LeaderboardEntry>> getLeaderboard({
    String scope = 'global',
    int limit = 20,
  }) async {
    final http.Response response = await _client
        .get(
          _uri('/leaderboard', <String, dynamic>{
            'scope': scope,
            'limit': limit,
          }),
          headers: _headers(),
        )
        .timeout(_config.requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The leaderboard could not be loaded.',
        statusCode: response.statusCode,
      );
    }
    final dynamic decoded = jsonDecode(response.body);
    final List<dynamic> rows = decoded is List<dynamic>
        ? decoded
        : ((decoded as Map<String, dynamic>)['entries'] as List<dynamic>? ??
            const <dynamic>[]);
    return rows
        .map(
          (dynamic row) =>
              LeaderboardEntry.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  /// `GET /api/stats/global`.
  Future<GlobalStats> getGlobalStats() async {
    final http.Response response = await _client
        .get(_uri('/stats/global'), headers: _headers())
        .timeout(_config.requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Global stats could not be loaded.',
        statusCode: response.statusCode,
      );
    }
    return GlobalStats.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Analysis _parseAnalysis(
    http.Response response, {
    String? fallbackClaimText,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'The scan could not be completed.',
        statusCode: response.statusCode,
      );
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final Analysis analysis = Analysis.fromJson(json);
    // The API response has no knowledge of what was submitted or when —
    // both are stamped on client-side. See Analysis's class doc.
    return analysis.copyWith(
      claimText: fallbackClaimText,
      createdAt: DateTime.now(),
    );
  }

  void dispose() => _client.close();
}
