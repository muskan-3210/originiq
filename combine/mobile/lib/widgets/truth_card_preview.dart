import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../models/damage_stat.dart';
import '../models/origin.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'verdict_badge.dart';

/// The Truth Card itself (§5 screen 7): verdict badge, truncated claim
/// text, a one-line origin+damage summary, and the closing tagline.
///
/// This is exactly what gets captured as a PNG for sharing — wrap it in a
/// `RepaintBoundary` at the screen level to snapshot it, rather than
/// building capture logic into this widget. Keep anything that shouldn't
/// appear in the shared image (loading chrome, app navigation, snackbars)
/// outside of it.
class TruthCardPreview extends StatelessWidget {
  const TruthCardPreview({super.key, required this.analysis});

  final Analysis analysis;

  String get _summary {
    final Origin? origin = analysis.origin;
    final StringBuffer buffer = StringBuffer();
    if (origin != null) {
      buffer.write(
        'Born on ${OracleFormatters.platformName(origin.platform)}, '
        '${OracleFormatters.countryName(origin.country)}',
      );
    }
    if (analysis.hasDamage) {
      final DamageStat first = analysis.damage.first;
      if (buffer.isNotEmpty) buffer.write(' · ');
      buffer.write(
        '${OracleFormatters.compactNumber(first.value)} '
        '${first.label.toLowerCase()}',
      );
    }
    if (buffer.isEmpty) {
      buffer.write('Traced and recorded for the first time.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OracleSpacing.xl),
      decoration: BoxDecoration(
        color: OracleColors.bgSurfaceRaised,
        borderRadius: OracleShapes.cardRadius,
        border: Border.all(
          color: OracleColors.borderDefault,
          width: OracleShapes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                OracleConstants.wordmark,
                style: OracleTypography.display.copyWith(fontSize: 18),
              ),
              const Spacer(),
              VerdictBadge(verdict: analysis.verdict),
            ],
          ),
          const SizedBox(height: OracleSpacing.xl),
          Text(
            OracleFormatters.truncate(
              analysis.claimText ?? 'This claim',
              maxLength: 180,
            ),
            style: OracleTypography.h2,
          ),
          const SizedBox(height: OracleSpacing.md),
          Text(
            _summary,
            style: OracleTypography.body.copyWith(
              color: OracleColors.textSecondary,
            ),
          ),
          const SizedBox(height: OracleSpacing.xl),
          Container(
            height: OracleShapes.borderWidth,
            color: OracleColors.borderDefault,
          ),
          const SizedBox(height: OracleSpacing.lg),
          Text(
            OracleConstants.truthCardTagline,
            style: OracleTypography.bodyMedium.copyWith(
              color: OracleColors.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}
