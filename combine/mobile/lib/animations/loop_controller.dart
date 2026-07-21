import 'package:flutter/material.dart';

/// Shared curves for the small set of looping animations used across the
/// app (splash crystal-ball float, Scanning clock rotate+bob, Legacy Wall
/// empty-slot pulse). Centralizing these keeps every loop feeling like part
/// of the same system rather than ad hoc per screen.
abstract final class OracleCurves {
  static const Curve floatLoop = Curves.easeInOut;
  static const Curve rotateLoop = Curves.easeInOut;
  static const Curve pulseLoop = Curves.easeInOut;
}

/// Wraps a single repeating [AnimationController] and exposes it to
/// [builder], automatically respecting the platform's reduce-motion
/// preference.
///
/// Per the ORACLE design system (§8 accessibility): "looping animations
/// must be disabled when MediaQuery.of(context).disableAnimations is true."
/// When that flag is set, [builder] still runs — the layout stays intact —
/// but the controller is parked at [restingValue] instead of repeating, so
/// only the motion is removed.
///
/// Used by the splash crystal-ball float, the Scanning clock icon's
/// rotate+bob, and [EmptyLegacySlot]'s pulse.
class GatedLoop extends StatefulWidget {
  const GatedLoop({
    super.key,
    required this.builder,
    required this.duration,
    this.curve = Curves.easeInOut,
    this.restingValue = 0,
    this.reverse = false,
  });

  /// Called on every animation tick (and once, statically, under reduced
  /// motion) with the current animation to drive transforms/opacity from.
  final Widget Function(BuildContext context, Animation<double> animation)
      builder;

  final Duration duration;
  final Curve curve;

  /// The value the animation is parked at when reduced motion is active.
  final double restingValue;

  /// Whether the controller should ping-pong (`repeat(reverse: true)`)
  /// rather than loop forward-only.
  final bool reverse;

  @override
  State<GatedLoop> createState() => _GatedLoopState();
}

class _GatedLoopState extends State<GatedLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;

    if (reduceMotion) {
      _controller.stop();
      _controller.value = widget.restingValue;
    } else if (widget.reverse) {
      _controller.repeat(reverse: true);
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (BuildContext context, Widget? _) {
        return widget.builder(context, _curved);
      },
    );
  }
}
