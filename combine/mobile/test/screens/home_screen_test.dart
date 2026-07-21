import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/models/analysis.dart';
import 'package:oracle/models/damage_stat.dart';
import 'package:oracle/models/mutation.dart';
import 'package:oracle/models/verdict.dart';
import 'package:oracle/screens/home_screen.dart';
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/constants.dart';

void main() {
  // `recentChecksProvider`'s real implementation reads the signed-in uid
  // (via Firebase Auth) before it ever reaches Firestore — overriding it
  // directly here means the test never touches either.
  List<Override> overridesWith(List<Analysis> recentChecks) {
    return <Override>[
      recentChecksProvider.overrideWith(
        (ref) => Stream<List<Analysis>>.value(recentChecks),
      ),
    ];
  }

  testWidgets('shows the paste card and the primary action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesWith(const <Analysis>[]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Scan for truth'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    // Empty state: no recent-checks row area at all.
    expect(find.text('Recent checks'), findsNothing);
  });

  testWidgets('shows an inline hint instead of navigating when input is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesWith(const <Analysis>[]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Scan for truth'));
    await tester.pump();

    expect(find.text(OracleConstants.pasteHintEmpty), findsOneWidget);
  });

  testWidgets('lists up to the recent-checks limit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesWith(<Analysis>[
          Analysis(
            id: '1',
            verdict: VerdictType.falseVerdict,
            cached: false,
            origin: null,
            mutations: const <Mutation>[],
            damage: const <DamageStat>[],
            truthCardReady: true,
            claimText: 'A claim about something suspicious',
            createdAt: DateTime.now(),
          ),
        ]),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Recent checks'), findsOneWidget);
    expect(
      find.textContaining('A claim about something suspicious'),
      findsOneWidget,
    );
  });
}
