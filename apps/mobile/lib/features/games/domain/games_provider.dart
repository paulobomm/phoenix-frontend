import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/games_repository.dart';
import '../data/models/game_model.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.read(apiClientProvider));
});

final gamesProvider = StateNotifierProvider<GamesNotifier, AsyncValue<List<GameModel>>>((ref) {
  return GamesNotifier(ref.read(gamesRepositoryProvider));
});

class GamesNotifier extends StateNotifier<AsyncValue<List<GameModel>>> {
  final GamesRepository _repository;

  GamesNotifier(this._repository) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final games = await _repository.getGames();
      state = AsyncData(games);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addGame(String name, String universeId, String apiKey) async {
    try {
      final newGame = await _repository.addGame(name, universeId, apiKey);
      final current = state.valueOrNull ?? [];
      state = AsyncData([...current, newGame]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteGame(String id) async {
    await _repository.deleteGame(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((g) => g.id != id).toList());
  }
}
