import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/damage_screen.dart';
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/mock_data.dart';

void main() {
  testWidgets(
    'renders the damage stat grid, then advances to the Truth Card',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentAnalysisProvider.overrideWith(
              (ref) => MockData.falseAnalysis,
            ),
          ],
          child: MaterialApp(
            initialRoute: '/damage',
            routes: <String, WidgetBuilder>{
              '/damage': (BuildContext context) => const DamageScreen(),
              '/truth-card': (BuildContext context) =>
                  const Scaffold(body: Text('truth card placeholder')),
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Damage report'), findsOneWidget);
      expect(find.text('People misled'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('truth card placeholder'), findsOneWidget);
    },
  );

  testWidgets('shows the empty-state note when there are no damage records', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAnalysisProvider.overrideWith(
            (ref) => MockData.zeroDamageAnalysis,
          ),
        ],
        child: MaterialApp(
          initialRoute: '/damage',
          routes: <String, WidgetBuilder>{
            '/damage': (BuildContext context) => const DamageScreen(),
            '/truth-card': (BuildContext context) =>
                const Scaffold(body: Text('truth card placeholder')),
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Documented impact isn’t available for this one yet'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('truth card placeholder'), findsOneWidget);
  });
}
