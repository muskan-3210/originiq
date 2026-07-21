import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle/screens/splash_screen.dart';
import 'package:oracle/services/auth_service.dart';
import 'package:oracle/services/providers.dart';

/// A `noSuchMethod`-backed test double: it satisfies the `AuthService`
/// interface without touching Firebase (unlike the real `AuthService`,
/// whose constructor talks to `FirebaseAuth.instance`), by overriding only
/// the one method `SplashScreen` actually calls and letting every other
/// member fall through to `noSuchMethod`. This is the same pattern
/// hand-written/generated mocks use.
class _NoopAuthService implements AuthService {
  @override
  Future<void> signInAnonymouslySilently() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('shows the wordmark and tagline, then navigates to Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authServiceProvider.overrideWithValue(_NoopAuthService()),
        ],
        child: MaterialApp(
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => const SplashScreen(),
            '/home': (BuildContext context) =>
                const Scaffold(body: Text('home placeholder')),
          },
        ),
      ),
    );

    // The wordmark/tagline are present in the tree immediately (their
    // fade-in only animates opacity, it doesn't delay insertion).
    expect(find.text('ORACLE'), findsOneWidget);
    expect(find.text('Tracing the truth through time'), findsOneWidget);

    // Advance well past the 2500ms auto-navigate timer.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();

    expect(find.text('home placeholder'), findsOneWidget);
  });
}
