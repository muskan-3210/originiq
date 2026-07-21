import '../models/analysis.dart';
import '../models/damage_stat.dart';
import '../models/legacy_entry.dart';
import '../models/mutation.dart';
import '../models/origin.dart';
import '../models/verdict.dart';

/// Static sample data so every screen renders a complete, reviewable layout
/// before the real backend is wired up.
///
/// Nothing under `lib/screens/` or `lib/widgets/` should hardcode sample
/// copy directly — pull it from here so swapping in live data later means
/// changing providers, not screen bodies.
abstract final class MockData {
  static final DateTime _now = DateTime(2026, 7, 21, 9, 30);

  // ---------------------------------------------------------------------
  // Golden path: a rich "false" verdict with full origin/mutation/damage.
  // This is the primary example used as the default preview for Origin,
  // Mutation, Damage, and Truth Card screens.
  // ---------------------------------------------------------------------
  static final Analysis falseAnalysis = Analysis(
    id: 'b3f1a2c4-saltwater-cure',
    verdict: VerdictType.falseVerdict,
    cached: false,
    truthCardReady: true,
    claimText:
        'Gargling warm salt water every 2 hours cures COVID-19 within 24 '
        'hours, according to doctors at a major hospital.',
    createdAt: _now,
    origin: Origin(
      platform: 'whatsapp',
      country: 'IN',
      date: DateTime(2020, 3, 14),
      tags: const <String>['health-misinformation', 'covid-era'],
      hopsTraced: 6,
    ),
    mutations: <Mutation>[
      Mutation(
        version: 2,
        country: 'BR',
        date: DateTime(2020, 4, 2),
        textExcerpt:
            'Gargle salt water with turmeric every hour to kill the '
            'coronavirus in your throat before it reaches your lungs.',
        similarityToOrigin: 0.81,
      ),
      Mutation(
        version: 3,
        country: 'NG',
        date: DateTime(2020, 4, 19),
        textExcerpt:
            'Hospitals confirm: hot salt water gargles clear coronavirus '
            'in one day. Share to save a life.',
        similarityToOrigin: 0.74,
      ),
      Mutation(
        version: 4,
        country: 'PH',
        date: DateTime(2020, 5, 6),
        textExcerpt:
            'Doctors in Europe say salt water + vinegar gargle is a '
            '24-hour COVID cure. Government hiding this.',
        similarityToOrigin: 0.62,
      ),
    ],
    damage: <DamageStat>[
      const DamageStat(
        label: 'People misled',
        value: 47000,
        description: 'Estimated shares and forwards across tracked groups.',
        sourceName: 'Reuters',
        sourceUrl: 'https://reuters.com/fact-check/example',
      ),
      const DamageStat(
        label: 'Countries affected',
        value: 4,
        description: 'Confirmed local-language variants circulating.',
        sourceName: 'AFP Fact Check',
        sourceUrl: 'https://factcheck.afp.com/example',
      ),
      const DamageStat(
        label: 'Peak shares/day',
        value: 9200,
        description: 'Recorded during the second week of spread.',
        sourceName: 'WHO EPI-WIN',
        sourceUrl: 'https://who.int/epi-win/example',
      ),
      const DamageStat(
        label: 'Days active',
        value: 58,
        description: 'From first appearance to peak fact-check coverage.',
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // A "misleading" verdict — true kernel, false framing.
  // ---------------------------------------------------------------------
  static final Analysis misleadingAnalysis = Analysis(
    id: 'c7d2b6e1-vitamin-headline',
    verdict: VerdictType.misleading,
    cached: false,
    truthCardReady: true,
    claimText:
        'Study "proves" vitamin D alone prevents hospitalization — '
        'headlines dropped the dosage and pre-existing immunity caveats.',
    createdAt: _now.subtract(const Duration(hours: 5)),
    origin: Origin(
      platform: 'twitter',
      country: 'US',
      date: DateTime(2021, 1, 9),
      tags: const <String>['health-misinformation', 'misquoted-study'],
      hopsTraced: 3,
    ),
    mutations: <Mutation>[
      Mutation(
        version: 2,
        country: 'GB',
        date: DateTime(2021, 1, 15),
        textExcerpt:
            'New study: vitamin D pills cut hospital risk to almost zero.',
        similarityToOrigin: 0.7,
      ),
    ],
    damage: <DamageStat>[
      const DamageStat(
        label: 'People misled',
        value: 12500,
        description: 'Engagement on the top five reposts.',
        sourceName: 'Full Fact',
        sourceUrl: 'https://fullfact.org/example',
      ),
      const DamageStat(
        label: 'Countries affected',
        value: 2,
        description: 'Variant headlines confirmed in two markets.',
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // A "true" verdict — confirmed accurate, routes to Home (not Legacy Wall).
  // ---------------------------------------------------------------------
  static final Analysis trueAnalysis = Analysis(
    id: 'a91e4f08-vaccine-cold-chain',
    verdict: VerdictType.trueVerdict,
    cached: true,
    truthCardReady: true,
    claimText:
        'Vaccine vials must be kept between 2-8°C during transport or they '
        'lose effectiveness.',
    createdAt: _now.subtract(const Duration(days: 2)),
    origin: Origin(
      platform: 'blog',
      country: 'US',
      date: DateTime(2019, 11, 2),
      tags: const <String>['public-health', 'verified'],
      hopsTraced: 1,
    ),
    mutations: const <Mutation>[],
    damage: const <DamageStat>[],
  );

  // ---------------------------------------------------------------------
  // "unverified" — no match found. Drives the "New territory" screen
  // instead of Origin (§5 screen 4).
  // ---------------------------------------------------------------------
  static final Analysis unverifiedAnalysis = Analysis(
    id: 'f10c9a77-no-match',
    verdict: VerdictType.unverified,
    cached: false,
    truthCardReady: false,
    claimText:
        'A message claiming a new toll rule starts next week in a city '
        'that was not named.',
    createdAt: _now.subtract(const Duration(minutes: 40)),
    origin: null,
    mutations: const <Mutation>[],
    damage: const <DamageStat>[],
  );

  // ---------------------------------------------------------------------
  // Origin found, but nothing has mutated yet — Mutation screen's "no
  // further spread" empty state (§5 screen 5).
  // ---------------------------------------------------------------------
  static final Analysis singleOriginNoMutationsAnalysis = Analysis(
    id: 'd44b1e90-single-origin',
    verdict: VerdictType.falseVerdict,
    cached: false,
    truthCardReady: true,
    claimText: 'A photo claiming to show a landmark flooded overnight.',
    createdAt: _now.subtract(const Duration(hours: 1)),
    origin: Origin(
      platform: 'instagram',
      country: 'ID',
      date: DateTime(2024, 2, 1),
      tags: const <String>['manipulated-media'],
      hopsTraced: 1,
    ),
    mutations: const <Mutation>[],
    damage: <DamageStat>[
      const DamageStat(
        label: 'People misled',
        value: 900,
        description: 'Shares before the original photo source was found.',
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Origin + mutations found, but zero damage records — Damage screen's
  // empty state skips straight to the Truth Card (§5 screen 6).
  // ---------------------------------------------------------------------
  static final Analysis zeroDamageAnalysis = Analysis(
    id: 'e83a7c21-no-damage-yet',
    verdict: VerdictType.misleading,
    cached: false,
    truthCardReady: true,
    claimText: 'A rumor about a school closure spreading in a local group.',
    createdAt: _now.subtract(const Duration(minutes: 12)),
    origin: Origin(
      platform: 'sms',
      country: 'PH',
      date: DateTime(2025, 9, 3),
      tags: const <String>['local-rumor'],
      hopsTraced: 2,
    ),
    mutations: const <Mutation>[],
    damage: const <DamageStat>[],
  );

  /// Up to [OracleConstants.recentChecksLimit] recent results for the Home
  /// screen (§5 screen 2). Most recent first.
  static final List<Analysis> recentChecks = <Analysis>[
    unverifiedAnalysis,
    misleadingAnalysis,
    falseAnalysis,
  ];

  /// An empty variant, used to preview Home's "omit the row area entirely"
  /// empty state.
  static const List<Analysis> noRecentChecks = <Analysis>[];

  // ---------------------------------------------------------------------
  // Legacy Wall (§5 screen 8).
  // ---------------------------------------------------------------------
  static final List<LegacyEntry> legacyEntries = <LegacyEntry>[
    LegacyEntry(
      id: 'legacy-1',
      analysisId: falseAnalysis.id,
      verdict: VerdictType.falseVerdict,
      claimExcerpt: falseAnalysis.claimText ?? '',
      createdAt: _now,
    ),
    LegacyEntry(
      id: 'legacy-2',
      analysisId: misleadingAnalysis.id,
      verdict: VerdictType.misleading,
      claimExcerpt: misleadingAnalysis.claimText ?? '',
      createdAt: _now.subtract(const Duration(hours: 5)),
    ),
    LegacyEntry(
      id: 'legacy-3',
      analysisId: zeroDamageAnalysis.id,
      verdict: VerdictType.misleading,
      claimExcerpt: zeroDamageAnalysis.claimText ?? '',
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
    LegacyEntry(
      id: 'legacy-4',
      analysisId: singleOriginNoMutationsAnalysis.id,
      verdict: VerdictType.falseVerdict,
      claimExcerpt: singleOriginNoMutationsAnalysis.claimText ?? '',
      createdAt: _now.subtract(const Duration(days: 3)),
    ),
    LegacyEntry(
      id: 'legacy-5',
      analysisId: 'old-catch-flood-photo',
      verdict: VerdictType.falseVerdict,
      claimExcerpt: 'A manipulated flood photo claiming to be current.',
      createdAt: _now.subtract(const Duration(days: 6)),
    ),
  ];

  static const List<LegacyEntry> noLegacyEntries = <LegacyEntry>[];

  // ---------------------------------------------------------------------
  // Leaderboard teaser (bottom of Legacy Wall).
  // ---------------------------------------------------------------------
  static const int leaderboardRank = 128;
  static const int leaderboardTotalPlayers = 4302;
}
