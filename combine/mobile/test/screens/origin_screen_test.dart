import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/origin_screen.dart';
import 'package:oracle/services/providers.dart';
import 'package:oracle/utils/mock_data.dart';

void main() {
  testWidgets(
    'renders the danger card for a matched origin, then advances to Mutation',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentAnalysisProvider.overrideWith(
              (ref) => MockData.falseAnalysis,
            ),
          ],
          child: MaterialApp(
            initialRoute: '/origin',
            routes: <String, WidgetBuilder>{
              '/origin': (BuildContext context) => const OriginScreen(),
              '/mutation': (BuildContext context) =>
                  const Scaffold(body: Text('mutation placeholder')),
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Born on'), findsOneWidget);

      // Past the full-content dwell duration so the auto-advance timer
      // fires and navigation completes, leaving no pending timer behind.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('mutation placeholder'), findsOneWidget);
    },
  );

  testWidgets('shows "New territory" for an unverified analysis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          currentAnalysisProvider.overrideWith(
            (ref) => MockData.unverifiedAnalysis,
          ),
        ],
        child: MaterialApp(
          initialRoute: '/origin',
          routes: <String, WidgetBuilder>{
            '/origin': (BuildContext context) => const OriginScreen(),
            '/home': (BuildContext context) =>
                const Scaffold(body: Text('home placeholder')),
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New territory'), findsOneWidget);

    // The unverified branch uses the shorter empty-state dwell.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('home placeholder'), findsOneWidget);
  });
}
