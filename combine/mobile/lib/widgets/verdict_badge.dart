import 'package:flutter/material.dart';

import '../models/verdict.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// A small pill showing a claim's verdict — False / Misleading / True /
/// Unverified — colored per [VerdictType.color]. Used prominently on the
/// Truth Card preview and anywhere else a verdict needs a standalone label.
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.verdict, this.dense = false});

  final VerdictType verdict;

  /// Slightly smaller padding/text for tight contexts.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final Color color = verdict.color;
    return Semantics(
      label: 'Verdict: ${verdict.label}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? OracleSpacing.sm : OracleSpacing.md,
          vertical: dense ? 2 : OracleSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: OracleShapes.pillRadius,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: OracleShapes.borderWidth,
          ),
        ),
        child: Text(
          verdict.label,
          style: OracleTypography.captionMedium.copyWith(color: color),
        ),
      ),
    );
  }
}
