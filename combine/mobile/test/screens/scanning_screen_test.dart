import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/scanning_screen.dart';

void main() {
  testWidgets(
    'shows the checklist, then advances to Origin once every stage completes',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            initialRoute: '/scanning',
            routes: <String, WidgetBuilder>{
              '/scanning': (BuildContext context) => const ScanningScreen(),
              '/origin': (BuildContext context) =>
                  const Scaffold(body: Text('origin placeholder')),
            },
          ),
        ),
      );
      await tester.pump();

      // The first stage for text/URL input (no "Reading image text" step
      // — that only applies to image input, see ScanningScreen's doc).
      expect(find.text('Checking language'), findsOneWidget);

      // Advance well past every simulated stage (3 stages x 900ms for
      // non-image input) so the chained timers all fire and navigation
      // completes — leaving no pending timers behind once ScanningScreen
      // is disposed.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('origin placeholder'), findsOneWidget);
    },
  );
}
