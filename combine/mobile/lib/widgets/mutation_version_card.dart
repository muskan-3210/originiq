import 'package:flutter/material.dart';

import '../models/mutation.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/formatters.dart';

/// Compares a mutated version's wording against the original, for the
/// Mutation screen (§5 screen 5) — plus which country/date it appeared in.
class MutationVersionCard extends StatelessWidget {
  const MutationVersionCard({
    super.key,
    required this.originalText,
    required this.mutation,
  });

  /// The original claim text, shown alongside [mutation] for comparison.
  final String originalText;

  final Mutation mutation;

  @override
  Widget build(BuildContext context) {
    final int similarityPercent = (mutation.similarityToOrigin * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OracleSpacing.cardPadding),
      decoration: OracleShapes.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${OracleFormatters.countryName(mutation.country)} · '
                  '${OracleFormatters.monthYear(mutation.date)}',
                  style: OracleTypography.h3,
                ),
              ),
              Text(
                '$similarityPercent% similar',
                style: OracleTypography.caption.copyWith(
                  color: OracleColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: OracleSpacing.md),
          _WordingBlock(label: 'Original', text: originalText),
          const SizedBox(height: OracleSpacing.md),
          _WordingBlock(
            label: 'This version',
            text: mutation.textExcerpt,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _WordingBlock extends StatelessWidget {
  const _WordingBlock({
    required this.label,
    required this.text,
    this.emphasize = false,
  });

  final String label;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: OracleTypography.caption.copyWith(
            color: OracleColors.textMuted,
          ),
        ),
        const SizedBox(height: OracleSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(OracleSpacing.md),
          decoration: BoxDecoration(
            color: emphasize
                ? OracleColors.bgSurfaceRaised
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: emphasize
                ? Border.all(color: OracleColors.warningAmber.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(text, style: OracleTypography.body),
        ),
      ],
    );
  }
}
