import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_badge.dart';
import '../../domain/games_provider.dart';
import '../../../snapshots/data/snapshots_repository.dart';
import '../../../snapshots/domain/snapshots_provider.dart';

class GameDetailPage extends ConsumerStatefulWidget {
  final String gameId;
  const GameDetailPage({super.key, required this.gameId});

  @override
  ConsumerState<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends ConsumerState<GameDetailPage> {
  bool _triggeringBackup = false;

  Future<void> _triggerManualBackup(String projectId) async {
    setState(() => _triggeringBackup = true);
    try {
      final repo = ref.read(snapshotsRepositoryProvider);
      await repo.triggerManual(projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Backup manual iniciado com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.invalidate(snapshotsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar backup: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _triggeringBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final game = games.where((g) => g.id == widget.gameId).isNotEmpty
            ? games.firstWhere((g) => g.id == widget.gameId)
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
            body: const Center(
              child: Text('Jogo não encontrado',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
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
                label: game.isActive ? 'Ativo' : game.status,
                status: game.isActive ? BadgeStatus.success : BadgeStatus.warning,
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
                      child: const Icon(Icons.videogame_asset_rounded,
                          color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(game.name,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Universe ID', value: game.universeId),
                    _DetailRow(
                        label: 'Status',
                        value: game.isActive ? 'Ativo' : game.status),
                    if (game.createdAt != null)
                      _DetailRow(
                        label: 'Conectado em',
                        value:
                            '${game.createdAt!.day.toString().padLeft(2, '0')}/${game.createdAt!.month.toString().padLeft(2, '0')}/${game.createdAt!.year}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ações Rápidas',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _triggeringBackup
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Iniciando backup...',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : _QuickAction(
                      icon: Icons.cloud_upload_outlined,
                      label: 'Backup Manual',
                      description: 'Criar um backup agora',
                      color: AppColors.primary,
                      onTap: () => _triggerManualBackup(game.id),
                    ),
              const SizedBox(height: 8),
              _QuickAction(
                icon: Icons.storage_outlined,
                label: 'Ver DataStores',
                description: 'Navegar pelos DataStores',
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
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
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
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
