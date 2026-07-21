import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/origin.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/formatters.dart';

/// The red-tinted card at the top of the Origin screen (§5 screen 4), e.g.
/// "Born on WhatsApp — India, March 2020."
class DangerCard extends StatelessWidget {
  const DangerCard({super.key, required this.origin});

  final Origin origin;

  @override
  Widget build(BuildContext context) {
    final String platform = OracleFormatters.platformName(origin.platform);
    final String country = OracleFormatters.countryName(origin.country);
    final String monthYear = OracleFormatters.monthYear(origin.date);

    return Semantics(
      label: 'Born on $platform — $country, $monthYear.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(OracleSpacing.cardPadding),
        decoration: BoxDecoration(
          color: OracleColors.dangerRed.withValues(alpha: 0.12),
          borderRadius: OracleShapes.cardRadius,
          border: Border.all(
            color: OracleColors.dangerRed.withValues(alpha: 0.5),
            width: OracleShapes.borderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: OracleColors.dangerRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.mapPin(),
                  size: 20,
                  color: OracleColors.dangerRed,
                ),
              ),
            ),
            const SizedBox(width: OracleSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Born on $platform', style: OracleTypography.h3),
                  const SizedBox(height: OracleSpacing.xs),
                  Text(
                    '$country, $monthYear',
                    style: OracleTypography.body.copyWith(
                      color: OracleColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
