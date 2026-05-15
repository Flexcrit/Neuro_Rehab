import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Animated number counter widget.
/// Counts from 0 to [target] over [duration] using ease-out curve.
class AnimatedCounter extends StatefulWidget {
  final double target;
  final TextStyle? style;
  final String Function(double)? formatter;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.style,
    this.formatter,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.target)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _animation = Tween<double>(begin: _animation.value, end: widget.target)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
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
      animation: _animation,
      builder: (_, __) {
        final text = widget.formatter != null
            ? widget.formatter!(_animation.value)
            : _animation.value == _animation.value.toInt()
                ? '${_animation.value.toInt()}'
                : _animation.value.toStringAsFixed(1);
        return Text(text,
            style: widget.style ??
                const TextStyle(
                  color: Color(0xFFF0F4FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ));
      },
    );
  }
}
