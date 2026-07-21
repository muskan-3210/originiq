import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Requires platform Firebase config (google-services.json /
    // GoogleService-Info.plist, or a generated firebase_options.dart from
    // `flutterfire configure`) that this scaffold doesn't include yet —
    // see mobile/README.md. Guarded so a missing/misconfigured project
    // never blocks app launch.
    await Firebase.initializeApp();
  } catch (error) {
    // Per §5 screen 1: a Firebase failure should never block entry to the
    // app. `AuthService.signInAnonymouslySilently` (called from
    // `SplashScreen`) already tolerates Firebase being unavailable, so
    // the rest of the app still works in mock-data form even if this
    // fails.
    debugPrint('Firebase.initializeApp failed: $error');
  }

  runApp(const ProviderScope(child: OracleApp()));
}
