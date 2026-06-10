import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/games_provider.dart';
import '../widgets/game_card.dart';
import 'add_game_wizard_page.dart';

class GamesPage extends ConsumerWidget {
  const GamesPage({super.key});

  void _showAddGame(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: const AddGameWizardPage(isDialog: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meus Jogos',
                            style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Gerencie seus jogos Roblox',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddGame(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('Adicionar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: gamesAsync.when(
                loading: () => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [SkeletonCard(), SkeletonCard(), SkeletonCard()],
                ),
                error: (e, _) => Center(
                  child: Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
                ),
                data: (games) {
                  if (games.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.videogame_asset_outlined,
                      title: 'Nenhum jogo cadastrado',
                      description: 'Adicione seu primeiro jogo Roblox para começar a gerenciar os DataStores.',
                      buttonLabel: 'Adicionar Jogo',
                      onButtonPressed: () => _showAddGame(context),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.card,
                    onRefresh: () => ref.read(gamesProvider.notifier).load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: games.length,
                      itemBuilder: (context, index) => GameCard(game: games[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
