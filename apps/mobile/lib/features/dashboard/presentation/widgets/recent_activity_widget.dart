import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../audit/data/models/log_model.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<LogModel> logs;

  const RecentActivityWidget({super.key, required this.logs});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.cancel_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text('Atividade Recente', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: logs.take(5).map((log) {
              final color = _getStatusColor(log.status);
              final isLast = logs.indexOf(log) == logs.take(5).length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(log.status), color: color, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.action,
                                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                log.details,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTime(log.timestamp),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: AppColors.border, height: 1, indent: 14, endIndent: 14),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
