import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;

  const LogItemWidget({super.key, required this.log});

  String get _label => log.eventType.isNotEmpty ? log.eventType : log.routingKey;
  String get _detail => log.routingKey.isNotEmpty && log.exchange.isNotEmpty
      ? '${log.exchange} › ${log.routingKey}'
      : log.exchange;

  Color get _statusColor {
    final et = log.eventType.toLowerCase();
    if (et.contains('error') || et.contains('fail')) return AppColors.error;
    if (et.contains('warn')) return AppColors.warning;
    if (et.contains('restore')) return const Color(0xFF60A5FA);
    return AppColors.success;
  }

  IconData get _icon {
    final et = log.eventType.toLowerCase();
    if (et.contains('error') || et.contains('fail')) return Icons.cancel_rounded;
    if (et.contains('restore')) return Icons.restore_rounded;
    if (et.contains('backup') || et.contains('snapshot')) return Icons.cloud_upload_outlined;
    if (et.contains('anomaly')) return Icons.trending_up_rounded;
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
        border: Border.all(color: AppColors.border),
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
                  _label.replaceAll('.', ' ').replaceAll('_', ' '),
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(_detail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_formatTime(log.occurredAt), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
