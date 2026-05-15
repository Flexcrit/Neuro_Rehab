import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// A card wrapper that applies scale(0.97) on press with a teal border brighten.
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Border? border;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderRadius = 16,
    this.margin,
    this.padding,
    this.border,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ??
                Border.all(
                  color: _pressed
                      ? AppColors.primaryAccent.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                  width: 1,
                ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: _pressed ? 4 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
