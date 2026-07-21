import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analysis.dart';
import '../models/damage_stat.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/offline_banner.dart';
import '../widgets/secondary_button.dart';
import '../widgets/stat_counter_card.dart';

/// §5 screen 6 — Damage report. A 2x2 grid of [StatCounterCard]s showing
/// only the stats that actually exist (never a fabricated placeholder).
///
/// Auto-advances to the Truth Card after a dwell (§4.1). If there are zero
/// damage records, this screen skips the grid and shows a short note
/// instead, advancing sooner.
class DamageScreen extends ConsumerStatefulWidget {
  const DamageScreen({super.key});

  @override
  ConsumerState<DamageScreen> createState() => _DamageScreenState();
}

class _DamageScreenState extends ConsumerState<DamageScreen> {
  Timer? _advanceTimer;
  bool _scheduled = false;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _scheduleAdvanceIfNeeded(Analysis? analysis) {
    if (_scheduled || analysis == null) return;
    _scheduled = true;
    final Duration dwell = analysis.hasDamage
        ? OracleConstants.storyDwellDuration
        : OracleConstants.storyDwellDurationShort;
    _advanceTimer = Timer(dwell, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/truth-card');
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
                  : _DamageContent(analysis: analysis),
            ),
          ],
        ),
      ),
    );
  }
}

class _DamageContent extends StatelessWidget {
  const _DamageContent({required this.analysis});

  final Analysis analysis;

  @override
  Widget build(BuildContext context) {
    // A 2x2 grid per §5 screen 6 — cap at 4 even if the backend ever sends
    // more, so the layout contract holds.
    final List<DamageStat> stats = analysis.damage.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.screenMargin,
        vertical: OracleSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Damage report', style: OracleTypography.h1),
          const SizedBox(height: OracleSpacing.xl),
          Expanded(
            child: stats.isEmpty
                ? Center(
                    child: Text(
                      OracleConstants.noDamageRecorded,
                      style: OracleTypography.body.copyWith(
                        color: OracleColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: OracleSpacing.md,
                    crossAxisSpacing: OracleSpacing.md,
                    childAspectRatio: 0.95,
                    children: <Widget>[
                      for (final DamageStat stat in stats)
                        StatCounterCard(stat: stat),
                    ],
                  ),
          ),
        ],
      ),
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
