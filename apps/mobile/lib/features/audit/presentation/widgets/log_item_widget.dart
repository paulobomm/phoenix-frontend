import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;

  const LogItemWidget({super.key, required this.log});

  Color get _statusColor {
    switch (log.status) {
      case 'error': return AppColors.error;
      case 'warning': return AppColors.warning;
      case 'success': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    if (log.action.contains('backup')) return Icons.cloud_upload_outlined;
    if (log.action.contains('restore')) return Icons.restore_rounded;
    if (log.action.contains('corrupt')) return Icons.bug_report_outlined;
    if (log.action.contains('anomaly')) return Icons.trending_up_rounded;
    return Icons.info_outline_rounded;
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: log.status == 'error'
              ? AppColors.error.withValues(alpha: 0.3)
              : log.status == 'warning'
                  ? AppColors.warning.withValues(alpha: 0.3)
                  : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action.replaceAll('.', ' ').replaceAll('_', ' '),
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(log.details, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_formatTime(log.timestamp), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(log.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
