import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_badge.dart';
import '../../domain/games_provider.dart';

class GameDetailPage extends ConsumerWidget {
  final String gameId;

  const GameDetailPage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return gamesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
      ),
      data: (games) {
        final game = games.where((g) => g.id == gameId).isNotEmpty
            ? games.firstWhere((g) => g.id == gameId)
            : null;

        if (game == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('Jogo não encontrado', style: TextStyle(color: AppColors.textSecondary))),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(game.name),
            actions: [
              PhoenixBadge(
                label: game.isSyncPaused ? 'Pausado' : 'Ativo',
                status: game.isSyncPaused ? BadgeStatus.warning : BadgeStatus.success,
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: const Icon(Icons.videogame_asset_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(game.name, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Universe ID', value: game.universeId),
                    _DetailRow(label: 'Place ID', value: game.placeId),
                    _DetailRow(label: 'DataStores', value: '${game.datastoreCount}'),
                    _DetailRow(label: 'Intervalo de Sync', value: '${game.syncInterval} minutos'),
                    _DetailRow(label: 'Status', value: game.isSyncPaused ? 'Pausado' : 'Ativo'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ações Rápidas', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _QuickAction(
                icon: Icons.cloud_upload_outlined,
                label: 'Backup Manual',
                description: 'Criar um backup agora',
                color: AppColors.primary,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup iniciado!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
                ),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                icon: Icons.storage_outlined,
                label: 'Ver DataStores',
                description: '${game.datastoreCount} datastores disponíveis',
                color: const Color(0xFF60A5FA),
                onTap: () => context.go('/datastores'),
              ),
              const SizedBox(height: 8),
              _QuickAction(
                icon: Icons.cloud_outlined,
                label: 'Ver Snapshots',
                description: 'Histórico de backups',
                color: AppColors.success,
                onTap: () => context.go('/snapshots'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
