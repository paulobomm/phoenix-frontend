import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_badge.dart';
import '../../data/models/snapshot_model.dart';

class SnapshotCard extends StatelessWidget {
  final SnapshotModel snapshot;
  final VoidCallback? onView;
  final VoidCallback? onRestore;
  final VoidCallback? onCompare;

  const SnapshotCard({
    super.key,
    required this.snapshot,
    this.onView,
    this.onRestore,
    this.onCompare,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  String _formatDuration(int? ms) {
    if (ms == null) return '--';
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  BadgeStatus get _badgeStatus {
    switch (snapshot.status) {
      case 'completed': return BadgeStatus.success;
      case 'failed': return BadgeStatus.error;
      default: return BadgeStatus.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (snapshot.status == 'completed' ? AppColors.success : snapshot.status == 'failed' ? AppColors.error : AppColors.warning).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    snapshot.status == 'completed' ? Icons.cloud_done_rounded : snapshot.status == 'failed' ? Icons.cloud_off_rounded : Icons.cloud_sync_rounded,
                    color: snapshot.status == 'completed' ? AppColors.success : snapshot.status == 'failed' ? AppColors.error : AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(snapshot.name,
                                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          PhoenixBadge(
                            label: snapshot.status == 'completed' ? 'Completo' : snapshot.status == 'failed' ? 'Falhou' : 'Pendente',
                            status: _badgeStatus,
                            small: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _metaItem(Icons.vpn_key_rounded, '${snapshot.keyCount} keys'),
                          const SizedBox(width: 16),
                          _metaItem(Icons.data_usage_rounded, _formatSize(snapshot.sizeBytes)),
                          const SizedBox(width: 16),
                          _metaItem(Icons.timer_outlined, _formatDuration(snapshot.durationMs)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (snapshot.status == 'completed') ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _actionBtn(Icons.visibility_outlined, 'Ver', onView),
                  _actionBtn(Icons.restore_rounded, 'Restaurar', onRestore),
                  _actionBtn(Icons.compare_arrows_rounded, 'Comparar', onCompare),
                  _actionBtn(Icons.download_outlined, 'Exportar', () {}),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback? onTap) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: AppColors.textSecondary),
        label: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
