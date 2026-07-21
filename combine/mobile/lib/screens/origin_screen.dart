import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/analysis.dart';
import '../models/origin.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/danger_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/secondary_button.dart';
import '../widgets/tag_pill.dart';

/// §5 screen 4 — Origin. A red-tinted [DangerCard] with platform/country/
/// date, a row of category [TagPill]s, and a short note on how many hops
/// the claim was traced through.
///
/// Auto-advances to Mutation after a dwell — per §4.1, every golden-path
/// transition is automatic except the two named taps. When the analysis
/// is unverified (no origin was found), this screen shows "New territory"
/// instead and returns to Home rather than continuing the chain, since
/// there's no origin/mutation/damage story to tell for it (and
/// `Analysis.truthCardReady` is false for that verdict).
class OriginScreen extends ConsumerStatefulWidget {
  const OriginScreen({super.key});

  @override
  ConsumerState<OriginScreen> createState() => _OriginScreenState();
}

class _OriginScreenState extends ConsumerState<OriginScreen> {
  Timer? _advanceTimer;
  bool _scheduled = false;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  // Deliberately scheduled from `build` (guarded to run exactly once) so
  // it naturally waits for `currentAnalysisProvider` to actually hold a
  // value — this screen can be reached either right after Scanning (value
  // already set) or, in tests, before it exists yet.
  void _scheduleAdvanceIfNeeded(Analysis? analysis) {
    if (_scheduled || analysis == null) return;
    _scheduled = true;

    final bool hasOrigin = analysis.origin != null;
    final Duration dwell = hasOrigin
        ? OracleConstants.storyDwellDuration
        : OracleConstants.storyDwellDurationShort;

    _advanceTimer = Timer(dwell, () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(hasOrigin ? '/mutation' : '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final Analysis? analysis = ref.watch(currentAnalysisProvider);
    _scheduleAdvanceIfNeeded(analysis);

    return Scaffold(
      backgroundColor: OracleColors.bgBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(
              child: analysis == null
                  ? const _NoAnalysisFallback()
                  : (analysis.origin == null
                        ? const _NewTerritory()
                        : _OriginContent(analysis: analysis)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OriginContent extends StatelessWidget {
  const _OriginContent({required this.analysis});

  final Analysis analysis;

  String _hopsNote(int hops) {
    if (hops <= 0) return 'Traced directly to this source.';
    if (hops == 1) return 'Traced through 1 platform before reaching you.';
    return 'Traced through $hops platforms before reaching you.';
  }

  @override
  Widget build(BuildContext context) {
    final Origin origin = analysis.origin!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.screenMargin,
        vertical: OracleSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Origin', style: OracleTypography.h1),
          const SizedBox(height: OracleSpacing.lg),
          DangerCard(origin: origin),
          if (origin.tags.isNotEmpty) ...<Widget>[
            const SizedBox(height: OracleSpacing.lg),
            Wrap(
              spacing: OracleSpacing.sm,
              runSpacing: OracleSpacing.sm,
              children: <Widget>[
                for (final String tag in origin.tags) TagPill(label: tag),
              ],
            ),
          ],
          const SizedBox(height: OracleSpacing.lg),
          Text(
            _hopsNote(origin.hopsTraced),
            style: OracleTypography.body.copyWith(
              color: OracleColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// §5 screen 4's alternate branch: shown instead of the normal Origin
/// content whenever the analysis is unverified. Never rendered with
/// placeholder origin data.
class _NewTerritory extends StatelessWidget {
  const _NewTerritory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.screenMargin,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PhosphorIcon(
              PhosphorIcons.compass(),
              size: 40,
              color: OracleColors.textMuted,
            ),
            const SizedBox(height: OracleSpacing.lg),
            const Text(
              OracleConstants.newTerritoryHeadline,
              style: OracleTypography.h1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OracleSpacing.sm),
            Text(
              OracleConstants.newTerritoryBody,
              style: OracleTypography.body.copyWith(
                color: OracleColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown if this screen is somehow reached with no analysis in flight
/// (e.g. a deep link, or a widget test rendering it in isolation) rather
/// than crashing on a null origin.
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
              'Nothing to trace yet',
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
