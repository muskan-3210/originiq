/// App-wide configuration, resolved once at startup.
///
/// Base URLs are intentionally **not** hardcoded inline anywhere else in the
/// app — every service reads [AppConfig.current] instead. The active flavor
/// is chosen via a `--dart-define=ORACLE_FLAVOR=prod` (or `dev`) build flag;
/// it defaults to `dev` so `flutter run` with no extra flags talks to a
/// local backend.
enum AppFlavor { dev, prod }

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.requestTimeout,
    required this.scanTimeout,
  });

  final AppFlavor flavor;

  /// Base URL for all `ApiService` calls, e.g. `$apiBaseUrl/analyze`.
  final String apiBaseUrl;

  /// Default timeout for a single HTTP request.
  final Duration requestTimeout;

  /// Max time the Scanning screen (§5 screen 3) waits for `/api/analyze`
  /// before flipping to its "taking longer than usual" error state.
  final Duration scanTimeout;

  static const String _flavorFlag = String.fromEnvironment(
    'ORACLE_FLAVOR',
    defaultValue: 'dev',
  );

  // `String.fromEnvironment`'s own `defaultValue` already does exactly
  // "use the --dart-define value if one was supplied, otherwise fall back"
  // — so the fallback host lives directly here rather than behind a
  // separate `.isEmpty` check on a const string (simpler, and avoids
  // leaning on any specific compiler's constant-folding support for
  // instance getters).
  static const AppConfig _dev = AppConfig(
    flavor: AppFlavor.dev,
    apiBaseUrl: String.fromEnvironment(
      'ORACLE_API_BASE_URL_DEV',
      defaultValue: 'http://localhost:8000/api',
    ),
    requestTimeout: Duration(seconds: 20),
    scanTimeout: Duration(seconds: 15),
  );

  // NOTE: replace this placeholder host with the deployed backend origin
  // before shipping a release build (or supply
  // --dart-define=ORACLE_API_BASE_URL_PROD=https://your-api.example.com/api).
  static const AppConfig _prod = AppConfig(
    flavor: AppFlavor.prod,
    apiBaseUrl: String.fromEnvironment(
      'ORACLE_API_BASE_URL_PROD',
      defaultValue: 'https://api.oracle.example.com/api',
    ),
    requestTimeout: Duration(seconds: 20),
    scanTimeout: Duration(seconds: 15),
  );

  /// The resolved config for this build, chosen by `ORACLE_FLAVOR`.
  static AppConfig get current => _flavorFlag == 'prod' ? _prod : _dev;

  bool get isProd => flavor == AppFlavor.prod;
  bool get isDev => flavor == AppFlavor.dev;
}
