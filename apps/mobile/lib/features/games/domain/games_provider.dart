import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/storage/local_storage_service.dart';
import '../data/games_repository.dart';
import '../data/models/game_model.dart';
import 'selected_game_provider.dart';

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(ref.read(apiClientProvider));
});

final gamesProvider = StateNotifierProvider<GamesNotifier, AsyncValue<List<GameModel>>>((ref) {
  return GamesNotifier(
    ref.read(gamesRepositoryProvider),
    ref.read(localStorageProvider),
    ref,
  );
});

class GamesNotifier extends StateNotifier<AsyncValue<List<GameModel>>> {
  final GamesRepository _repository;
  final LocalStorageService _storage;
  final Ref _ref;

  GamesNotifier(this._repository, this._storage, this._ref)
      : super(const AsyncLoading()) {
    // Persiste a seleção sempre que o jogo selecionado mudar (default ou manual).
    _ref.listen<GameModel?>(selectedGameProvider, (_, next) {
      if (next != null) _storage.saveSelectedGameId(next.id);
    });
    _loadFromCache(); // exibe cache imediatamente (cold start / offline)
    load();           // recarrega da API em segundo plano
  }

  /// Carrega a lista de jogos do cache local, se existir, para exibição
  /// imediata enquanto a API responde.
  void _loadFromCache() {
    final cached = _storage.readGames();
    if (cached == null) return;
    try {
      final list = (jsonDecode(cached) as List)
          .map((e) => GameModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) {
        state = AsyncData(list);
        _syncSelectedGame(list);
      }
    } catch (_) {
      // cache corrompido → ignora, a API recarrega
    }
  }

  Future<void> load() async {
    // Só mostra loading se ainda não há nada (cache) em tela.
    if (!state.hasValue) state = const AsyncLoading();
    try {
      final games = await _repository.getGames();
      state = AsyncData(games);
      await _persistGames(games);
      _syncSelectedGame(games);
    } catch (e, st) {
      // Se há cache em tela, mantém-o em vez de quebrar a UI.
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }

  Future<GameModel?> addGame(String name, String universeId, String apiKey) async {
    try {
      final newGame = await _repository.addGame(name, universeId, apiKey);
      final current = state.valueOrNull ?? [];
      final updated = [...current, newGame];
      state = AsyncData(updated);
      await _persistGames(updated);
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
    await _persistGames(remaining);
    _syncSelectedGame(remaining);
  }

  Future<void> _persistGames(List<GameModel> games) {
    final encoded = jsonEncode(games.map((g) => g.toCacheJson()).toList());
    return _storage.saveGames(encoded);
  }

  void _syncSelectedGame(List<GameModel> games) {
    if (games.isEmpty) {
      _ref.read(selectedGameProvider.notifier).state = null;
      return;
    }
    // Ordena por createdAt asc → mais antigo é o padrão.
    final sorted = [...games]..sort((a, b) {
      final aDate = a.createdAt ?? DateTime(0);
      final bDate = b.createdAt ?? DateTime(0);
      return aDate.compareTo(bDate);
    });
    final selected = _ref.read(selectedGameProvider);
    // Se nada selecionado ou o selecionado não existe mais → escolhe.
    if (selected == null || !games.any((g) => g.id == selected.id)) {
      // Tenta restaurar a última seleção persistida; senão, o mais antigo.
      final savedId = _storage.readSelectedGameId();
      final restored = savedId == null
          ? null
          : games.where((g) => g.id == savedId).cast<GameModel?>().firstWhere(
                (g) => g != null,
                orElse: () => null,
              );
      _ref.read(selectedGameProvider.notifier).state = restored ?? sorted.first;
    }
  }
}
