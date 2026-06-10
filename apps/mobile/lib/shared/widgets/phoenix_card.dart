import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PhoenixCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool hasGlow;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  const PhoenixCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.hasGlow = false,
    this.glowColor,
    this.borderRadius,
  });

  @override
  State<PhoenixCard> createState() => _PhoenixCardState();
}

class _PhoenixCardState extends State<PhoenixCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.surface : AppColors.card,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? (widget.glowColor ?? AppColors.primary).withValues(alpha: 0.5)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: widget.hasGlow
              ? [
                  BoxShadow(
                    color: (widget.glowColor ?? AppColors.primary).withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: widget.child,
        ),
      ),
    );
  }
}
