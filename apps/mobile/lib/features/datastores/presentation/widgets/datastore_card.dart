import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_badge.dart';
import '../../data/models/datastore_model.dart';

class DataStoreCard extends StatelessWidget {
  final DataStoreModel datastore;
  final VoidCallback? onTap;

  const DataStoreCard({super.key, required this.datastore, this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Nunca';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storage_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(datastore.name, style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      PhoenixBadge(
                        label: datastore.type.toUpperCase(),
                        status: datastore.type == 'ordered' ? BadgeStatus.info : BadgeStatus.pending,
                        small: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Stat(label: '${datastore.entryCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} entries'),
                      const SizedBox(width: 12),
                      _Stat(label: datastore.formattedSize),
                      const SizedBox(width: 12),
                      _Stat(label: _formatTime(datastore.lastSync)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;

  const _Stat({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11));
  }
}
