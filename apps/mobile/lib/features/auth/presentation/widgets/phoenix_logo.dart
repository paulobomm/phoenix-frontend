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
        Image.asset(
          'assets/images/phoenix_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
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
