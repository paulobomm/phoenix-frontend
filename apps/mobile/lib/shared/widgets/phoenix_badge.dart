import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeStatus { success, warning, error, info, pending }

class PhoenixBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final bool small;

  const PhoenixBadge({
    super.key,
    required this.label,
    required this.status,
    this.small = false,
  });

  Color get _bgColor {
    switch (status) {
      case BadgeStatus.success:
        return AppColors.success.withValues(alpha: 0.15);
      case BadgeStatus.warning:
        return AppColors.warning.withValues(alpha: 0.15);
      case BadgeStatus.error:
        return AppColors.error.withValues(alpha: 0.15);
      case BadgeStatus.info:
        return const Color(0xFF60A5FA).withValues(alpha: 0.15);
      case BadgeStatus.pending:
        return AppColors.textSecondary.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case BadgeStatus.success:
        return AppColors.success;
      case BadgeStatus.warning:
        return AppColors.warning;
      case BadgeStatus.error:
        return AppColors.error;
      case BadgeStatus.info:
        return const Color(0xFF60A5FA);
      case BadgeStatus.pending:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
