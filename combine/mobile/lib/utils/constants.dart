/// App-wide constants that aren't design tokens (those live in `lib/theme/`)
/// and aren't environment config (that lives in `lib/config/app_config.dart`).
abstract final class OracleConstants {
  // Copy (§8 copy rules: sentence case, no ALL CAPS, no "!", no "Error:").
  static const String appName = 'Oracle';
  static const String wordmark = 'ORACLE'; // wordmark only — display lockup.
  static const String tagline = 'Tracing the truth through time';
  static const String legacyWallEmptyHeadline = 'Start your first catch';
  static const String legacyWallEmptyBody =
      'Paste anything suspicious and we’ll trace it for you';
  static const String truthCardTagline =
      'You broke the chain. It ends with you.';
  static const String pasteHintEmpty = 'Paste something first';
  static const String scanTakingLong = 'This is taking longer than usual';
  static const String noDamageRecorded =
      'Documented impact isn’t available for this one yet';
  static const String noFurtherSpread = 'No further spread recorded yet';
  static const String newTerritoryHeadline = 'New territory';
  static const String newTerritoryBody =
      'We couldn’t match this to anything we’ve traced before — it’s now '
      'part of what we’re watching.';
  static const String photoUploadUnavailable =
      'Photo upload needs a device photo library — coming soon';
  static const String skipSharing = 'Skip sharing';
  static const String truthCardShareFailed =
      'The truth card couldn’t be saved as an image';

  // Timing (§5 screen 1: splash auto-navigates after 2500ms).
  static const Duration splashMinDuration = Duration(milliseconds: 2500);
  static const Duration splashWordmarkDelay = Duration(milliseconds: 200);
  static const Duration splashTaglineDelay = Duration(milliseconds: 500);

  // Scanning screen (§5 screen 3) checklist stage timing when animating
  // in mock/offline mode (real progress is driven by the backend).
  static const Duration scanStageDuration = Duration(milliseconds: 900);

  // Origin/Mutation/Damage (§5 screens 4-6) each auto-advance to the next
  // screen in the golden path — per §4.1, every transition is automatic
  // except the two named taps (paste, and Share on the Truth Card). These
  // are the dwell times before auto-advancing.
  static const Duration storyDwellDuration = Duration(milliseconds: 4200);

  /// A shorter dwell for a screen showing only an empty-state note (New
  /// territory, "no further spread yet", "no damage recorded yet") rather
  /// than full content.
  static const Duration storyDwellDurationShort = Duration(
    milliseconds: 2400,
  );

  // Truth Card (§5 screen 7) capture flash timing.
  static const Duration captureFlashDuration = Duration(milliseconds: 350);

  // Home screen (§5 screen 2): show at most this many recent checks.
  static const int recentChecksLimit = 3;

  // Legacy Wall (§5 screen 8) grid layout.
  static const int legacyWallColumns = 4;

  static const String firestoreChecksSubcollection = 'checks';
  static const String firestoreLegacyWallCollection = 'legacyWall';
  static const String firestoreLegacyEntriesSubcollection = 'entries';
  static const String firestoreLeaderboardCacheCollection = 'leaderboardCache';
  static const String firestoreUsersCollection = 'users';
}
