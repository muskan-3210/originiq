import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animations/delayed_fade_in.dart';
import '../animations/loop_controller.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';

/// §5 screen 1 — full-bleed splash. No interactive elements; auto-navigates
/// to Home after [OracleConstants.splashMinDuration].
///
/// Firebase anonymous sign-in is kicked off here but never awaited before
/// navigating — per the brief, "if Firebase anon auth fails, log silently
/// and proceed anyway." `AuthService.signInAnonymouslySilently` already
/// swallows its own errors internally, so there's deliberately no
/// try/catch here: the only thing left to guard against is it taking a
/// while, and the fire-and-forget call already doesn't block on that.
///
/// NOTE: if the app was opened via an OS share (per §5 screen 2, "if
/// opened via OS share, this screen is skipped"), the launch path should
/// detect that here (or in `main.dart`/`app.dart`, before this widget is
/// even built) and route straight to Scanning instead of Home. Wiring that
/// up needs a share-intent package (e.g. `receive_sharing_intent`), which
/// isn't in this scaffold's dependency list — see `app.dart`.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    unawaited(ref.read(authServiceProvider).signInAnonymouslySilently());

    _navigationTimer = Timer(OracleConstants.splashMinDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OracleColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const _CrystalBall(),
              const SizedBox(height: OracleSpacing.xxl),
              const DelayedFadeIn(
                delay: OracleConstants.splashWordmarkDelay,
                child: Text(
                  OracleConstants.wordmark,
                  style: OracleTypography.display,
                ),
              ),
              const SizedBox(height: OracleSpacing.sm),
              DelayedFadeIn(
                delay: OracleConstants.splashTaglineDelay,
                child: Text(
                  OracleConstants.tagline,
                  style: OracleTypography.body.copyWith(
                    color: OracleColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder crystal-ball animation: a glowing circle with a subtle float
/// loop. Swap for the real asset at `assets/rive/crystal_ball.riv` (see
/// that directory's `.gitkeep`) once it's supplied, e.g. via
/// `RiveAnimation.asset('assets/rive/crystal_ball.riv')` from the `rive`
/// package already in `pubspec.yaml`.
class _CrystalBall extends StatelessWidget {
  const _CrystalBall();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Oracle',
      child: GatedLoop(
        duration: const Duration(milliseconds: 2200),
        curve: OracleCurves.floatLoop,
        reverse: true,
        builder: (BuildContext context, Animation<double> animation) {
          final double bob = -8 * animation.value;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    OracleColors.accentGold.withValues(alpha: 0.55),
                    OracleColors.accentGold.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: OracleColors.accentGold.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
