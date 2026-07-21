import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/shapes.dart';

/// A thin, determinate progress bar beneath [ScanningChecklist] (§5 screen
/// 3). Driven by real backend progress in production; the Scanning screen
/// animates it in discrete stages for now (see `ScanningScreen`).
///
/// Uses its own [AnimationController] (rather than `TweenAnimationBuilder`
/// with a fixed `begin`) so that each time [progress] increases, the bar
/// animates smoothly from wherever it currently sits to the new value
/// instead of resetting to zero and refilling.
class ScanProgressBar extends StatefulWidget {
  const ScanProgressBar({super.key, required this.progress});

  /// 0.0-1.0.
  final double progress;

  @override
  State<ScanProgressBar> createState() => _ScanProgressBarState();
}

class _ScanProgressBarState extends State<ScanProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.progress.clamp(0, 1).toDouble(),
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant ScanProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      unawaited(
        _controller.animateTo(
          widget.progress.clamp(0, 1).toDouble(),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(OracleShapes.radiusPill),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          return LinearProgressIndicator(
            value: _controller.value,
            minHeight: 4,
            backgroundColor: OracleColors.borderDefault,
            valueColor: const AlwaysStoppedAnimation<Color>(
              OracleColors.accentGold,
            ),
          );
        },
      ),
    );
  }
}
