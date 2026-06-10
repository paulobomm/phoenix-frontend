import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PhoenixLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const PhoenixLogo({super.key, this.size = 64, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.primary,
            size: size * 0.55,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'PHOENIX',
          style: TextStyle(
            color: AppColors.text,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          const Text(
            'DataStore Management',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
