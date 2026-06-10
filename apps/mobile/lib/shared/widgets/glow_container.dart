import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 20,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppColors.primary).withValues(alpha: 0.25),
            blurRadius: glowRadius,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
