import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/games_repository.dart';
import '../data/models/game_model.dart';
import 'selected_game_provider.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.read(apiClientProvider));
});

final gamesProvider = StateNotifierProvider<GamesNotifier, AsyncValue<List<GameModel>>>((ref) {
  return GamesNotifier(ref.read(gamesRepositoryProvider), ref);
});

class GamesNotifier extends StateNotifier<AsyncValue<List<GameModel>>> {
  final GamesRepository _repository;
  final Ref _ref;

  GamesNotifier(this._repository, this._ref) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final games = await _repository.getGames();
      state = AsyncData(games);
      _syncSelectedGame(games);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<GameModel?> addGame(String name, String universeId, String apiKey) async {
    try {
      final newGame = await _repository.addGame(name, universeId, apiKey);
      final current = state.valueOrNull ?? [];
      final updated = [...current, newGame];
      state = AsyncData(updated);
      _syncSelectedGame(updated);
      return newGame;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> deleteGame(String id) async {
    await _repository.deleteGame(id);
    final current = state.valueOrNull ?? [];
    final remaining = current.where((g) => g.id != id).toList();
    state = AsyncData(remaining);
    _syncSelectedGame(remaining);
  }

  void _syncSelectedGame(List<GameModel> games) {
    if (games.isEmpty) {
      _ref.read(selectedGameProvider.notifier).state = null;
      return;
    }
    // Sort ascending by createdAt so the oldest game is default
    final sorted = [...games]..sort((a, b) {
      final aDate = a.createdAt ?? DateTime(0);
      final bDate = b.createdAt ?? DateTime(0);
      return aDate.compareTo(bDate);
    });
    final oldest = sorted.first;
    final selected = _ref.read(selectedGameProvider);
    // If nothing selected, or selected game no longer in list → pick oldest
    if (selected == null || !games.any((g) => g.id == selected.id)) {
      _ref.read(selectedGameProvider.notifier).state = oldest;
    }
  }
}

