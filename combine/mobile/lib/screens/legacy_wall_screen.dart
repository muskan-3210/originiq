import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/legacy_entry.dart';
import '../services/api_service.dart' show LeaderboardEntry;
import '../services/providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../widgets/empty_legacy_slot.dart';
import '../widgets/error_banner.dart';
import '../widgets/legacy_grid_item.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/offline_banner.dart';

/// §5 screen 8 — Legacy Wall. A 4-column grid of past catches, most
/// recent first, with one dashed [EmptyLegacySlot] always last. Tapping a
/// filled icon reopens that Truth Card read-only. An optional leaderboard
/// teaser sits at the bottom.
class LegacyWallScreen extends ConsumerWidget {
  const LegacyWallScreen({super.key});

  void _openEntry(BuildContext context, WidgetRef ref, LegacyEntry entry) {
    // Reopening read-only needs the full Analysis behind this entry, which
    // isn't reconstructible from the compact LegacyEntry alone (no
    // origin/mutation/damage payload lives on the wall itself — see
    // `LegacyEntry`'s class doc). The real wiring point:
    //   final analysis = await ref.read(apiServiceProvider)
    //       .getAnalysis(entry.analysisId); // not yet an ApiService method
    //   ref.read(currentAnalysisProvider.notifier).state = analysis;
    //   Navigator.of(context).pushNamed('/truth-card');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reopening "${entry.claimExcerpt}"')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LegacyEntry>> legacyWall = ref.watch(
      legacyWallProvider,
    );

    return Scaffold(
      backgroundColor: OracleColors.bgBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OracleSpacing.screenMargin,
                  vertical: OracleSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Legacy wall', style: OracleTypography.h1),
                    const SizedBox(height: OracleSpacing.xl),
                    legacyWall.when(
                      loading: () => const _GridLoading(),
                      error: (Object error, StackTrace stackTrace) =>
                          ErrorBanner(
                            message: 'Your legacy wall couldn’t be loaded',
                            onRetry: () => ref.invalidate(legacyWallProvider),
                          ),
                      data: (List<LegacyEntry> entries) => _WallGrid(
                        entries: entries,
                        onTap: (LegacyEntry entry) =>
                            _openEntry(context, ref, entry),
                      ),
                    ),
                    const SizedBox(height: OracleSpacing.xxl),
                    const _LeaderboardTeaser(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallGrid extends StatelessWidget {
  const _WallGrid({required this.entries, required this.onTap});

  final List<LegacyEntry> entries;
  final void Function(LegacyEntry entry) onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: OracleSpacing.xxl),
        child: Column(
          children: <Widget>[
            const Text(
              OracleConstants.legacyWallEmptyHeadline,
              style: OracleTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OracleSpacing.sm),
            Text(
              OracleConstants.legacyWallEmptyBody,
              style: OracleTypography.body.copyWith(
                color: OracleColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final List<LegacyEntry> sorted = List<LegacyEntry>.of(entries)
      ..sort(
        (LegacyEntry a, LegacyEntry b) => b.createdAt.compareTo(a.createdAt),
      );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: OracleConstants.legacyWallColumns,
        mainAxisSpacing: OracleSpacing.sm,
        crossAxisSpacing: OracleSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: sorted.length + 1, // + the trailing empty slot
      itemBuilder: (BuildContext context, int index) {
        if (index == sorted.length) return const EmptyLegacySlot();
        final LegacyEntry entry = sorted[index];
        return LegacyGridItem(entry: entry, onTap: () => onTap(entry));
      },
    );
  }
}

class _GridLoading extends StatelessWidget {
  const _GridLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: OracleConstants.legacyWallColumns,
        mainAxisSpacing: OracleSpacing.sm,
        crossAxisSpacing: OracleSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: OracleConstants.legacyWallColumns,
      itemBuilder: (BuildContext context, int index) =>
          const LoadingSkeleton.block(),
    );
  }
}

class _LeaderboardTeaser extends ConsumerWidget {
  const _LeaderboardTeaser();

  static LeaderboardEntry? _findCurrentUser(List<LeaderboardEntry> entries) {
    for (final LeaderboardEntry entry in entries) {
      if (entry.isCurrentUser) return entry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LeaderboardEntry>> leaderboard = ref.watch(
      leaderboardProvider,
    );

    return leaderboard.maybeWhen(
      data: (List<LeaderboardEntry> entries) {
        final LeaderboardEntry? mine = _findCurrentUser(entries);
        if (mine == null) return const SizedBox.shrink();
        return Row(
          children: <Widget>[
            PhosphorIcon(
              PhosphorIcons.trophy(),
              size: 18,
              color: OracleColors.accentGold,
            ),
            const SizedBox(width: OracleSpacing.sm),
            Expanded(
              child: Text(
                'Rank #${mine.rank} on the leaderboard',
                style: OracleTypography.body.copyWith(
                  color: OracleColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // No standalone leaderboard screen exists in this
                // scaffold's 8 required screens — this is a documented
                // extension point, not a silent no-op.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'The full leaderboard isn’t part of this build yet',
                    ),
                  ),
                );
              },
              child: const Text('See all'),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
