import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/games_provider.dart';
import '../../domain/selected_game_provider.dart';
import '../../data/models/game_model.dart';

class GameSelectorWidget extends ConsumerWidget {
  const GameSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGame = ref.watch(selectedGameProvider);
    final gamesAsync = ref.watch(gamesProvider);

    return GestureDetector(
      onTap: () => _showGameSelector(context, ref, gamesAsync.valueOrNull ?? []),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.videogame_asset_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedGame?.name ?? 'Selecionar Jogo',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedGame != null)
                    Text(
                      'Universe ID: ${selectedGame.universeId}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: selectedGame?.isSyncPaused == true
                    ? AppColors.warning.withValues(alpha: 0.15)
                    : AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedGame?.isSyncPaused == true ? 'Pausado' : 'Ativo',
                style: TextStyle(
                  color: selectedGame?.isSyncPaused == true ? AppColors.warning : AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showGameSelector(BuildContext context, WidgetRef ref, List<GameModel> games) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GameSelectorSheet(games: games, ref: ref),
    );
  }
}

class _GameSelectorSheet extends ConsumerWidget {
  final List<GameModel> games;
  final WidgetRef ref;

  const _GameSelectorSheet({required this.games, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final selectedGame = widgetRef.watch(selectedGameProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Selecionar Jogo',
                  style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          ...games.map((game) {
            final isSelected = game.id == selectedGame?.id;
            return InkWell(
              onTap: () {
                widgetRef.read(selectedGameProvider.notifier).state = game;
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                  border: isSelected
                      ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.videogame_asset_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${game.datastoreCount} datastores • ${game.syncInterval}min sync',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (game.isSyncPaused)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Pausado', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                      )
                    else if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
