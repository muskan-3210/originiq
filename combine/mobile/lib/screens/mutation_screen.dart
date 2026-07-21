import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analysis.dart';
import '../models/mutation.dart';
import '../models/origin.dart';
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/mutation_version_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/secondary_button.dart';
import '../widgets/spread_timeline.dart';

/// §5 screen 5 — Mutation. Header "Spread across N countries," a
/// [SpreadTimeline], and a [MutationVersionCard] per mutated version
/// comparing its wording against the original.
///
/// Auto-advances to Damage after a dwell (§4.1). If there's an origin but
/// no recorded mutations, shows the origin marker alone with a "no further
/// spread" note instead of fabricating countries.
class MutationScreen extends ConsumerStatefulWidget {
  const MutationScreen({super.key});

  @override
  ConsumerState<MutationScreen> createState() => _MutationScreenState();
}

class _MutationScreenState extends ConsumerState<MutationScreen> {
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
    final Duration dwell = analysis.hasMutations
        ? OracleConstants.storyDwellDuration
        : OracleConstants.storyDwellDurationShort;
    _advanceTimer = Timer(dwell, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/damage');
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
              child: (analysis == null || analysis.origin == null)
                  ? const _NoOriginFallback()
                  : _MutationContent(analysis: analysis),
            ),
          ],
        ),
      ),
    );
  }
}

class _MutationContent extends StatelessWidget {
  const _MutationContent({required this.analysis});

  final Analysis analysis;

  @override
  Widget build(BuildContext context) {
    final Origin origin = analysis.origin!;
    final List<Mutation> mutations = analysis.mutations;
    // Origin counts as the first country; each mutation's country adds to
    // the total (de-duplicated, in case two mutations share a country).
    final int countryCount =
        1 + mutations.map((Mutation m) => m.country).toSet().length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.screenMargin,
        vertical: OracleSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            countryCount <= 1
                ? 'Spread across 1 country'
                : 'Spread across $countryCount countries',
            style: OracleTypography.h1,
          ),
          const SizedBox(height: OracleSpacing.xl),
          SpreadTimeline(origin: origin, mutations: mutations),
          const SizedBox(height: OracleSpacing.xl),
          if (mutations.isEmpty)
            Text(
              OracleConstants.noFurtherSpread,
              style: OracleTypography.body.copyWith(
                color: OracleColors.textSecondary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final Mutation mutation in mutations) ...<Widget>[
                  MutationVersionCard(
                    originalText: analysis.claimText ?? '',
                    mutation: mutation,
                  ),
                  const SizedBox(height: OracleSpacing.md),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// Shown if this screen is somehow reached with no in-flight analysis (or
/// one with no origin) rather than crashing.
class _NoOriginFallback extends StatelessWidget {
  const _NoOriginFallback();

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
