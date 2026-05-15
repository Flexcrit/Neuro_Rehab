import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Animated circular score ring.
///
/// The ring stroke animates from 0 to the target score value over [duration].
/// Color: teal ≥60, amber 30–59, red <30.
/// The score number counts up in sync with the ring.
class ScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final TextStyle? textStyle;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 52,
    this.strokeWidth = 4,
    this.duration = const Duration(milliseconds: 1200),
    this.textStyle,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  Color get _ringColor => AppColors.scoreColor(widget.score);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: widget.duration, vsync: this);
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _anim = Tween<double>(begin: 0, end: widget.score / 100)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _ringColor;
    final fontSize = widget.size < 50 ? (widget.size * 0.28) : (widget.size * 0.30);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final displayScore = (_anim.value * widget.score).round();
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _anim.value,
              color: color,
              strokeWidth: widget.strokeWidth,
              bgColor: AppColors.surfaceVariant,
            ),
            child: Center(
              child: Text(
                '$displayScore',
                style: widget.textStyle ??
                    TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color bgColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Foreground arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
