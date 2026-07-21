import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../models/mutation.dart';
import '../models/origin.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/formatters.dart';

/// A simplified left-to-right spread visual for the Mutation screen (§5
/// screen 5): the origin country followed by each subsequent mutation's
/// country, in chronological order, connected by a single line.
///
/// [mutations] is expected to already be in chronological order (as
/// returned by `POST /api/analyze`'s `mutations` array).
class SpreadTimeline extends StatelessWidget {
  const SpreadTimeline({
    super.key,
    required this.origin,
    required this.mutations,
  });

  final Origin origin;
  final List<Mutation> mutations;

  @override
  Widget build(BuildContext context) {
    final List<_TimelineStop> stops = <_TimelineStop>[
      _TimelineStop(
        country: origin.country,
        date: origin.date,
        isOrigin: true,
      ),
      ...mutations.map(
        (Mutation m) =>
            _TimelineStop(country: m.country, date: m.date, isOrigin: false),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < stops.length; i++) ...<Widget>[
            _TimelineMarker(stop: stops[i]),
            if (i != stops.length - 1) const _TimelineConnector(),
          ],
        ],
      ),
    );
  }
}

class _TimelineStop {
  const _TimelineStop({
    required this.country,
    required this.date,
    required this.isOrigin,
  });

  final String country;
  final DateTime date;
  final bool isOrigin;
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: OracleSpacing.xs),
      color: OracleColors.borderDefault,
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({required this.stop});

  final _TimelineStop stop;

  @override
  Widget build(BuildContext context) {
    final Color color = stop.isOrigin
        ? OracleColors.dangerRed
        : OracleColors.warningAmber;
    final String countryName = OracleFormatters.countryName(stop.country);
    final String monthYear = OracleFormatters.monthYear(stop.date);

    return Semantics(
      label:
          '${stop.isOrigin ? 'Origin' : 'Spread to'} $countryName, $monthYear',
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.mapPin(),
                  size: 16,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: OracleSpacing.sm),
            Text(
              countryName,
              style: OracleTypography.captionMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              monthYear,
              style: OracleTypography.caption.copyWith(
                color: OracleColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
