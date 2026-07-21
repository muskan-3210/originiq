import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// A small neutral pill for a category tag, e.g. "health-misinformation",
/// "covid-era" on the Origin screen (§5 screen 4).
///
/// Converts hyphen/underscore slugs into readable sentence case for
/// display — the raw slug from `Origin.tags` is passed in as-is.
class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label});

  final String label;

  String get _displayLabel {
    final String spaced = label.replaceAll('-', ' ').replaceAll('_', ' ');
    if (spaced.isEmpty) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OracleSpacing.md,
        vertical: OracleSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: OracleColors.bgSurfaceRaised,
        borderRadius: OracleShapes.pillRadius,
        border: OracleShapes.outline(),
      ),
      child: Text(_displayLabel, style: OracleTypography.captionMedium),
    );
  }
}
