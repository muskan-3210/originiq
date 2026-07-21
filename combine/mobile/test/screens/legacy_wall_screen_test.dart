import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/models/legacy_entry.dart';
import 'package:oracle/screens/legacy_wall_screen.dart';
import 'package:oracle/services/api_service.dart' show LeaderboardEntry;
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/constants.dart';
import 'package:oracle/utils/mock_data.dart';

void main() {
  // `legacyWallProvider`/`leaderboardProvider`'s real implementations read
  // Firebase-backed services — overriding them directly here means the
  // test never touches either.
  List<Override> overridesWith(List<LegacyEntry> entries) {
    return <Override>[
      legacyWallProvider.overrideWith(
        (ref) => Stream<List<LegacyEntry>>.value(entries),
      ),
      leaderboardProvider.overrideWith(
        (ref) => Future<List<LeaderboardEntry>>.value(
          const <LeaderboardEntry>[],
        ),
      ),
    ];
  }

  testWidgets('renders a grid cell per catch plus a trailing empty slot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesWith(MockData.legacyEntries),
        child: const MaterialApp(home: LegacyWallScreen()),
      ),
    );
    // A couple of pumps to let the overridden Stream/Future deliver their
    // first values (never `pumpAndSettle` here — the trailing empty slot
    // has a genuinely infinite pulse loop that would never "settle").
    await tester.pump();
    await tester.pump();

    expect(find.text('Legacy wall'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('shows the empty-state invitation when there are no catches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesWith(const <LegacyEntry>[]),
        child: const MaterialApp(home: LegacyWallScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(OracleConstants.legacyWallEmptyHeadline), findsOneWidget);
    expect(find.text(OracleConstants.legacyWallEmptyBody), findsOneWidget);
  });
}
