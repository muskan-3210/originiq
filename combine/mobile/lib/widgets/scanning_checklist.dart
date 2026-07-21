import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// The Scanning screen's (§5 screen 3) step-by-step checklist — reveals one
/// line at a time as each stage of the analysis pipeline completes, e.g.
/// "Checking language" -> "Matching similar claims" -> "Cross-referencing
/// sources". For image input, "Reading image text" is prepended as the
/// first stage by the caller.
class ScanningChecklist extends StatelessWidget {
  const ScanningChecklist({
    super.key,
    required this.stages,
    required this.completedCount,
  });

  final List<String> stages;

  /// How many [stages] have fully completed. The stage at this index (if
  /// any) is the one currently in progress; stages after it haven't been
  /// revealed yet.
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final int visibleCount = (completedCount + 1).clamp(0, stages.length).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < visibleCount; index++)
          _RevealItem(
            key: ValueKey<int>(index),
            child: _StageRow(label: stages[index], isDone: index < completedCount),
          ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OracleSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StageIndicator(isDone: isDone),
          const SizedBox(width: OracleSpacing.md),
          Flexible(
            child: Text(
              label,
              style: isDone
                  ? OracleTypography.body
                  : OracleTypography.body.copyWith(
                      color: OracleColors.textSecondary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageIndicator extends StatelessWidget {
  const _StageIndicator({required this.isDone});

  final bool isDone;

  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: _size,
        height: _size,
        decoration: const BoxDecoration(
          color: OracleColors.successTeal,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: PhosphorIcon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            size: 12,
            color: OracleColors.bgBase,
          ),
        ),
      );
    }
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: OracleColors.borderStrong, width: 1.5),
      ),
    );
  }
}

/// Fades and gently rises a checklist row into place the first time it's
/// built — i.e. the moment its stage is revealed.
class _RevealItem extends StatelessWidget {
  const _RevealItem({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 6),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
