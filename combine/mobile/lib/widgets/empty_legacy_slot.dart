import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../animations/loop_controller.dart';
import '../theme/colors.dart';
import '../theme/shapes.dart';

/// The dashed, always-last slot in the Legacy Wall grid (§5 screen 8),
/// inviting the next catch. Pulses subtly on a loop — skipped under
/// reduced motion via [GatedLoop], which parks it at a static mid-opacity
/// instead.
class EmptyLegacySlot extends StatelessWidget {
  const EmptyLegacySlot({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Empty slot for your next catch',
      child: Material(
        color: Colors.transparent,
        borderRadius: OracleShapes.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: OracleShapes.cardRadius,
          child: AspectRatio(
            aspectRatio: 1,
            child: GatedLoop(
              duration: const Duration(milliseconds: 1800),
              curve: OracleCurves.pulseLoop,
              reverse: true,
              restingValue: 0.5,
              builder: (BuildContext context, Animation<double> animation) {
                final double t = animation.value;
                final double opacity = 0.4 + (t * 0.3);
                return CustomPaint(
                  painter: _DashedRectPainter(
                    color: OracleColors.borderStrong.withValues(alpha: opacity),
                    radius: OracleShapes.radiusCard,
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIcons.plus(),
                      size: 22,
                      color: OracleColors.textMuted.withValues(alpha: opacity),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a dashed rounded-rectangle outline — hand-rolled via
/// `Path.computeMetrics` since no dotted-border package is in the
/// dependency list.
class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  static const double _dashWidth = 6;
  static const double _gapWidth = 4;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(path), paint);
  }

  Path _dashPath(Path source) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? _dashWidth : _gapWidth;
        final double next = (distance + length).clamp(0, metric.length).toDouble();
        if (draw) {
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
