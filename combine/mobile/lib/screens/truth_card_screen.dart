import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analysis.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/error_banner.dart';
import '../widgets/offline_banner.dart';
import '../widgets/secondary_button.dart';
import '../widgets/share_sheet_trigger.dart';
import '../widgets/truth_card_preview.dart';

/// §5 screen 7 — Truth Card. A single preview card, "Save & share" as the
/// primary action (captures a PNG via `RepaintBoundary` + `toImage` and
/// opens the OS share sheet), and "Done" as the secondary action routing
/// to the Legacy Wall (False/Misleading verdicts) or Home (True).
///
/// On entry, a brief white "capture flash" plays over the card per §5
/// screen 7. Sharing failures show an [ErrorBanner] with the share button
/// itself acting as the retry (tapping it again re-attempts capture), and
/// "Skip sharing" always stays available so a failure never strands the
/// user on this screen.
class TruthCardScreen extends ConsumerStatefulWidget {
  const TruthCardScreen({super.key});

  @override
  ConsumerState<TruthCardScreen> createState() => _TruthCardScreenState();
}

class _TruthCardScreenState extends ConsumerState<TruthCardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  late final AnimationController _flashController;
  String? _shareError;
  bool _flashScheduled = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: OracleConstants.captureFlashDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_flashScheduled) return;
    _flashScheduled = true;
    if (!MediaQuery.of(context).disableAnimations) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) _flashController.forward();
      });
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void _handleShared() {
    if (!mounted) return;
    setState(() => _shareError = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Shared')));
  }

  void _handleShareError(Object error) {
    if (!mounted) return;
    setState(() => _shareError = OracleConstants.truthCardShareFailed);
  }

  void _handleDone(Analysis analysis) {
    ref.read(currentAnalysisProvider.notifier).state = null;
    final String destination = analysis.verdict.belongsOnLegacyWall
        ? '/legacy-wall'
        : '/home';
    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  Widget build(BuildContext context) {
    final Analysis? analysis = ref.watch(currentAnalysisProvider);

    return Scaffold(
      backgroundColor: OracleColors.bgBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(
              child: analysis == null
                  ? const _NoAnalysisFallback()
                  : Stack(
                      children: <Widget>[
                        _TruthCardContent(
                          analysis: analysis,
                          repaintKey: _repaintKey,
                          shareError: _shareError,
                          onShared: _handleShared,
                          onShareError: _handleShareError,
                          onDone: () => _handleDone(analysis),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: _CaptureFlash(
                              controller: _flashController,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TruthCardContent extends StatelessWidget {
  const _TruthCardContent({
    required this.analysis,
    required this.repaintKey,
    required this.shareError,
    required this.onShared,
    required this.onShareError,
    required this.onDone,
  });

  final Analysis analysis;
  final GlobalKey repaintKey;
  final String? shareError;
  final VoidCallback onShared;
  final void Function(Object error) onShareError;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.screenMargin,
        vertical: OracleSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RepaintBoundary(
            key: repaintKey,
            child: TruthCardPreview(analysis: analysis),
          ),
          const SizedBox(height: OracleSpacing.xl),
          if (shareError != null) ...<Widget>[
            ErrorBanner(message: shareError!),
            const SizedBox(height: OracleSpacing.md),
          ],
          ShareSheetTrigger(
            repaintBoundaryKey: repaintKey,
            shareText:
                '${OracleConstants.truthCardTagline} Traced with ORACLE.',
            onShared: onShared,
            onError: onShareError,
          ),
          const SizedBox(height: OracleSpacing.md),
          SecondaryButton(label: 'Done', onPressed: onDone),
          const SizedBox(height: OracleSpacing.md),
          Center(
            child: TextButton(
              onPressed: onDone,
              child: const Text(OracleConstants.skipSharing),
            ),
          ),
        ],
      ),
    );
  }
}

/// The white "capture flash" that plays once on entry: opacity 0 -> 0.8 ->
/// 0 over [OracleConstants.captureFlashDuration]. Purely decorative, so it
/// sits behind [IgnorePointer] in the parent stack and is skipped
/// entirely under reduced motion (never started in that case).
class _CaptureFlash extends StatelessWidget {
  const _CaptureFlash({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final double t = controller.value;
        final double opacity = t < 0.5
            ? (t / 0.5) * 0.8
            : (1 - (t - 0.5) / 0.5) * 0.8;
        return Opacity(
          opacity: opacity.clamp(0, 0.8).toDouble(),
          child: const ColoredBox(color: Colors.white),
        );
      },
    );
  }
}

/// Shown if this screen is somehow reached with no in-flight analysis
/// rather than crashing.
class _NoAnalysisFallback extends StatelessWidget {
  const _NoAnalysisFallback();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OracleSpacing.screenMargin),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Nothing to share yet',
              style: OracleTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OracleSpacing.sm),
            Text(
              'Paste something on Home to start a new trace.',
              style: OracleTypography.body.copyWith(
                color: OracleColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OracleSpacing.lg),
            SecondaryButton(
              label: 'Back to home',
              expand: false,
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
