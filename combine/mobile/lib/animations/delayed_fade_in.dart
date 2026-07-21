import 'package:flutter/material.dart';

/// Fades (and gently rises into) [child] after [delay], used by the Splash
/// screen for the wordmark (200ms delay) and tagline (500ms delay).
///
/// This is a one-shot entrance animation, not a loop, so it is not gated
/// behind `disableAnimations` — the design system only requires *looping*
/// animations to be disabled under reduced motion. It still respects it by
/// skipping the rise offset (opacity-only) so nothing appears to move.
class DelayedFadeIn extends StatefulWidget {
  const DelayedFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.riseFrom = 8,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Pixels the child rises from below its resting position while fading
  /// in. Set to `0` (or reduced motion is active) for a pure fade.
  final double riseFrom;

  @override
  State<DelayedFadeIn> createState() => _DelayedFadeInState();
}

class _DelayedFadeInState extends State<DelayedFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.riseFrom / 100),
      end: Offset.zero,
    ).animate(_opacity);

    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    return FadeTransition(
      opacity: _opacity,
      child: reduceMotion
          ? widget.child
          : SlideTransition(position: _offset, child: widget.child),
    );
  }
}
