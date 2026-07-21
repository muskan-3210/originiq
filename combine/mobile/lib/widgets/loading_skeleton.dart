import 'package:flutter/material.dart';

import '../animations/loop_controller.dart';
import '../theme/colors.dart';

/// A shimmering placeholder block for content that's still loading.
///
/// Hand-rolled rather than pulled from a shimmer package (the dependency
/// list is fixed) — a highlight band sweeps left to right across a base
/// tone. Respects reduced motion via [GatedLoop]: under
/// `MediaQuery.disableAnimations`, it renders a static, centered highlight
/// instead of a moving sweep.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  /// Sized for a single line of body text.
  const LoadingSkeleton.line({super.key, this.width})
    : height = 15,
      borderRadius = null;

  /// Sized for a rectangular block (card, image, chart area).
  const LoadingSkeleton.block({super.key, this.width, this.height = 64})
    : borderRadius = null;

  /// Sized for a circular avatar/icon placeholder.
  const LoadingSkeleton.circle({super.key, required double diameter})
    : width = diameter,
      height = diameter,
      borderRadius = null;

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  bool get _isCircle => borderRadius == null && width == height && width != null;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ??
        (_isCircle ? BorderRadius.circular(height / 2) : BorderRadius.circular(6));

    return Semantics(
      label: 'Loading',
      child: GatedLoop(
        duration: const Duration(milliseconds: 1400),
        restingValue: 0.5,
        builder: (BuildContext context, Animation<double> animation) {
          final double t = animation.value;
          final double shift = -1.5 + 3.0 * t;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment(shift - 0.5, 0),
                end: Alignment(shift + 0.5, 0),
                colors: const <Color>[
                  OracleColors.bgSurfaceRaised,
                  OracleColors.borderDefault,
                  OracleColors.bgSurfaceRaised,
                ],
                stops: const <double>[0, 0.5, 1],
              ),
            ),
          );
        },
      ),
    );
  }
}
