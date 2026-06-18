import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../audit/data/models/log_model.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<LogModel> logs;

  const RecentActivityWidget({super.key, required this.logs});

  Color _colorForEvent(String eventType) {
    if (eventType.contains('error') || eventType.contains('fail')) return AppColors.error;
    if (eventType.contains('warn')) return AppColors.warning;
    if (eventType.contains('restore')) return const Color(0xFF60A5FA);
    return AppColors.success;
  }

  IconData _iconForEvent(String eventType) {
    if (eventType.contains('error') || eventType.contains('fail')) return Icons.cancel_rounded;
    if (eventType.contains('warn')) return Icons.warning_rounded;
    if (eventType.contains('restore')) return Icons.restore_rounded;
    if (eventType.contains('backup') || eventType.contains('snapshot')) return Icons.cloud_done_rounded;
    return Icons.info_rounded;
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  String _labelForEvent(LogModel log) {
    final et = log.eventType;
    if (et.isNotEmpty) return et;
    return log.routingKey.isNotEmpty ? log.routingKey : log.exchange;
  }

  String _detailForEvent(LogModel log) {
    if (log.routingKey.isNotEmpty && log.exchange.isNotEmpty) {
      return '${log.exchange} › ${log.routingKey}';
    }
    return log.routingKey.isNotEmpty ? log.routingKey : log.exchange;
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text('Nenhuma atividade recente', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
          ),
        ],
      );
    }

    final visibleLogs = logs.take(5).toList();

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
            children: List.generate(visibleLogs.length, (i) {
              final log = visibleLogs[i];
              final eventType = log.eventType.toLowerCase();
              final color = _colorForEvent(eventType);
              final isLast = i == visibleLogs.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(_iconForEvent(eventType), color: color, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _labelForEvent(log),
                                style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _detailForEvent(log),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTime(log.occurredAt),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: AppColors.border, height: 1, indent: 14, endIndent: 14),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
