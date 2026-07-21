import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/mutation_screen.dart';
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/mock_data.dart';

void main() {
  testWidgets(
    'renders the spread timeline, then advances to Damage',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentAnalysisProvider.overrideWith(
              (ref) => MockData.falseAnalysis,
            ),
          ],
          child: MaterialApp(
            initialRoute: '/mutation',
            routes: <String, WidgetBuilder>{
              '/mutation': (BuildContext context) => const MutationScreen(),
              '/damage': (BuildContext context) =>
                  const Scaffold(body: Text('damage placeholder')),
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Spread across'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('damage placeholder'), findsOneWidget);
    },
  );

  testWidgets('shows the "no further spread" note when there are no mutations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAnalysisProvider.overrideWith(
            (ref) => MockData.singleOriginNoMutationsAnalysis,
          ),
        ],
        child: MaterialApp(
          initialRoute: '/mutation',
          routes: <String, WidgetBuilder>{
            '/mutation': (BuildContext context) => const MutationScreen(),
            '/damage': (BuildContext context) =>
                const Scaffold(body: Text('damage placeholder')),
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No further spread recorded yet'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('damage placeholder'), findsOneWidget);
  });
}
