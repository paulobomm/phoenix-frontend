import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static final _mockNotifications = [
    const _MockNotif(title: 'Backup Concluído', body: 'PlayerData - 1.423 keys em 12.4s', type: 'success', isRead: false, ago: Duration(minutes: 23)),
    const _MockNotif(title: 'Corrupção Detectada', body: 'Possível corrupção em Player_99999999', type: 'error', isRead: false, ago: Duration(hours: 2)),
    const _MockNotif(title: 'Aviso de Storage', body: 'Você usou 85% do seu armazenamento', type: 'warning', isRead: true, ago: Duration(hours: 5)),
    const _MockNotif(title: 'Backup Concluído', body: 'Leaderboards - 1.423 entries em 8.2s', type: 'success', isRead: true, ago: Duration(hours: 6)),
    const _MockNotif(title: 'Crescimento Acelerado', body: 'Inventory crescendo 45%/dia', type: 'warning', isRead: true, ago: Duration(days: 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Marcar tudo', style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = _mockNotifications[i];
          final typeColor = n.type == 'error' ? AppColors.error : n.type == 'warning' ? AppColors.warning : n.type == 'success' ? AppColors.success : AppColors.primary;
          final typeIcon = n.type == 'error' ? Icons.error_outline_rounded : n.type == 'warning' ? Icons.warning_amber_rounded : n.type == 'success' ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded;
          final diffStr = n.ago.inMinutes < 60 ? 'Há ${n.ago.inMinutes}min' : n.ago.inHours < 24 ? 'Há ${n.ago.inHours}h' : 'Há ${n.ago.inDays}d';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.isRead ? AppColors.card : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: n.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(n.title, style: TextStyle(color: AppColors.text, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14))),
                          if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(diffStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MockNotif {
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final Duration ago;
  const _MockNotif({required this.title, required this.body, required this.type, required this.isRead, required this.ago});
}
