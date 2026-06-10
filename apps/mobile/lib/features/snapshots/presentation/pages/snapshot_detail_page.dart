import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_badge.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../../datastores/presentation/widgets/json_viewer_widget.dart';
import '../../domain/snapshots_provider.dart';

class SnapshotDetailPage extends ConsumerWidget {
  final String snapshotId;
  const SnapshotDetailPage({super.key, required this.snapshotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(snapshotDetailProvider(snapshotId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalhe do Snapshot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
        data: (snapshot) {
          final snap = snapshot ?? (() {
            // Fallback mock
            return null;
          })();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snap?.name ?? 'Backup Automático',
                                    style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                const PhoenixBadge(label: 'Completo', status: BadgeStatus.success),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),
                      _row('Keys', snap != null ? '${snap.keyCount}' : '1.423'),
                      const SizedBox(height: 10),
                      _row('Tamanho', snap?.formattedSize ?? '8.54 MB'),
                      const SizedBox(height: 10),
                      _row('Duração', snap?.formattedDuration ?? '12.4s'),
                      const SizedBox(height: 10),
                      _row('Criado em', snap != null ? _formatDate(snap.createdAt) : '15 Jan 2024, 14:30'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PhoenixButton(
                        label: 'Restaurar',
                        icon: Icons.restore_rounded,
                        onPressed: () => context.push('/snapshots/$snapshotId/restore'),
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PhoenixButton(
                        label: 'Comparar',
                        icon: Icons.compare_arrows_rounded,
                        onPressed: () => context.push('/compare'),
                        width: double.infinity,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Amostra dos Dados',
                    style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const JsonViewerWidget(data: {
                    'Player_12345678': {
                      'userId': 12345678,
                      'username': 'CoolPlayer123',
                      'level': 42,
                      'coins': 8750,
                      'isPremium': true,
                    },
                    'Player_87654321': {
                      'userId': 87654321,
                      'username': 'ProGamer99',
                      'level': 78,
                      'coins': 25100,
                      'isPremium': false,
                    },
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
