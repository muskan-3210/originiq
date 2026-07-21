import 'package:flutter/material.dart';

import '../models/damage_stat.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/formatters.dart';

/// A single stat tile in the Damage report's 2x2 grid (§5 screen 6), e.g.
/// "47,000 people misled". The number animates from 0 to its final value
/// on first build (instantly, under reduced motion).
class StatCounterCard extends StatelessWidget {
  const StatCounterCard({super.key, required this.stat});

  final DamageStat stat;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OracleSpacing.cardPadding),
      decoration: OracleShapes.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: stat.value.toDouble()),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double value, Widget? _) {
              return Text(
                OracleFormatters.thousands(value),
                style: OracleTypography.statNumber,
              );
            },
          ),
          const SizedBox(height: OracleSpacing.xs),
          Text(stat.label, style: OracleTypography.bodyMedium),
          if (stat.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: OracleSpacing.xs),
            Text(
              stat.description,
              style: OracleTypography.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (stat.hasSource) ...<Widget>[
            const SizedBox(height: OracleSpacing.sm),
            Text(
              'Source: ${stat.sourceName}',
              style: OracleTypography.caption.copyWith(
                color: OracleColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
