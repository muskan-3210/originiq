import 'package:flutter/material.dart';

import 'screens/damage_screen.dart';
import 'screens/home_screen.dart';
import 'screens/legacy_wall_screen.dart';
import 'screens/mutation_screen.dart';
import 'screens/origin_screen.dart';
import 'screens/scanning_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/truth_card_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

/// The root widget: a single dark theme built from `lib/theme/` (there is
/// no light mode — see `OracleAppTheme`), a named-route table for all 8
/// screens (§5), and Splash as the initial route.
///
/// NOTE: per §5 screen 2, an app opened via an OS share should skip
/// Splash landing on Home and go straight to Scanning with the shared
/// content pre-filled. That needs a share-intent package (e.g.
/// `receive_sharing_intent`), which isn't in this scaffold's dependency
/// list — the hook would live here, choosing the initial route/arguments
/// before `MaterialApp` is built, once that package is added.
class OracleApp extends StatelessWidget {
  const OracleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: OracleConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: OracleAppTheme.dark,
      darkTheme: OracleAppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const SplashScreen(),
        '/home': (BuildContext context) => const HomeScreen(),
        '/scanning': (BuildContext context) => const ScanningScreen(),
        '/origin': (BuildContext context) => const OriginScreen(),
        '/mutation': (BuildContext context) => const MutationScreen(),
        '/damage': (BuildContext context) => const DamageScreen(),
        '/truth-card': (BuildContext context) => const TruthCardScreen(),
        '/legacy-wall': (BuildContext context) => const LegacyWallScreen(),
      },
    );
  }
}
