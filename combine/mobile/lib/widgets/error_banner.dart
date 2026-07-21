import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// An inline banner for a recoverable problem.
///
/// Per the ORACLE copy rules (§8), [message] should never be prefixed with
/// "Error:" and should read like a plain sentence. Pair with a
/// [SecondaryButton] "Retry" below it where a retry makes sense, or use
/// [onRetry] for a compact inline text action instead.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;

  /// When provided, renders a compact "Retry" text action inline.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(OracleSpacing.lg),
        decoration: OracleShapes.cardDecoration(
          background: OracleColors.bgSurfaceRaised,
          borderColor: OracleColors.dangerRed,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PhosphorIcon(
              PhosphorIcons.warningCircle(),
              size: 20,
              color: OracleColors.dangerRed,
            ),
            const SizedBox(width: OracleSpacing.md),
            Expanded(child: Text(message, style: OracleTypography.body)),
            if (onRetry != null) ...<Widget>[
              const SizedBox(width: OracleSpacing.sm),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 44),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
