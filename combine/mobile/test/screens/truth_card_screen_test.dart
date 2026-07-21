import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/truth_card_screen.dart';
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/constants.dart';
import 'package:oracle/utils/mock_data.dart';

void main() {
  testWidgets('renders the truth card preview and both actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAnalysisProvider.overrideWith(
            (ref) => MockData.falseAnalysis,
          ),
        ],
        child: const MaterialApp(home: TruthCardScreen()),
      ),
    );
    // A single pump is enough: unlike Origin/Mutation/Damage/Scanning,
    // this screen has no auto-advance timer — the only animation is the
    // one-shot capture flash, which doesn't need to complete for its
    // sibling widgets to be queryable.
    await tester.pump();

    expect(find.text('Save & share'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text(OracleConstants.skipSharing), findsOneWidget);
    expect(find.text('False'), findsOneWidget); // VerdictBadge label
  });

  testWidgets('shows a fallback instead of crashing with no analysis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TruthCardScreen())),
    );
    await tester.pump();

    expect(find.text('Nothing to share yet'), findsOneWidget);
  });
}
