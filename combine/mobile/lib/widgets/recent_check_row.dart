import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/formatters.dart';

/// A single tappable row on Home's "Recent checks" list (§5 screen 2): a
/// small verdict-colored dot, a truncated claim snippet, and a relative
/// timestamp.
class RecentCheckRow extends StatelessWidget {
  const RecentCheckRow({super.key, required this.analysis, this.onTap});

  final Analysis analysis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String snippet = OracleFormatters.truncate(
      (analysis.claimText == null || analysis.claimText!.isEmpty)
          ? 'Untitled check'
          : analysis.claimText!,
      maxLength: 64,
    );
    final String time = analysis.createdAt == null
        ? ''
        : OracleFormatters.relativeTime(analysis.createdAt!);

    return Semantics(
      button: true,
      label: '${analysis.verdict.label}: $snippet${time.isEmpty ? '' : ', $time'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: OracleSpacing.sm,
                horizontal: OracleSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: analysis.verdict.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: OracleSpacing.md),
                  Expanded(
                    child: Text(
                      snippet,
                      style: OracleTypography.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (time.isNotEmpty) ...<Widget>[
                    const SizedBox(width: OracleSpacing.md),
                    Text(
                      time,
                      style: OracleTypography.caption.copyWith(
                        color: OracleColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
