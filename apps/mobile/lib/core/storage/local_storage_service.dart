import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Facade sobre os dois mecanismos de persistência local do app:
///
/// - [FlutterSecureStorage]: dados sensíveis (token JWT), cifrados em repouso.
/// - [SharedPreferences]: cache leve de dados de domínio (lista de jogos e
///   jogo selecionado) para exibição imediata no cold start / offline.
///
/// Centralizar aqui mantém as chaves e a escolha de mecanismo num único lugar,
/// fora dos ViewModels.
class LocalStorageService {
  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  LocalStorageService(this._secure, this._prefs);

  static const _kToken = 'auth_token';
  static const _kGames = 'cache_games';
  static const _kSelectedGameId = 'cache_selected_game_id';

  // --- Sessão (seguro / cifrado) ---------------------------------------------

  Future<void> saveToken(String token) => _secure.write(key: _kToken, value: token);

  Future<String?> readToken() => _secure.read(key: _kToken);

  Future<void> deleteToken() => _secure.delete(key: _kToken);

  // --- Cache de jogos (preferences) ------------------------------------------

  Future<void> saveGames(String gamesJson) => _prefs.setString(_kGames, gamesJson);

  String? readGames() => _prefs.getString(_kGames);

  Future<void> saveSelectedGameId(String id) => _prefs.setString(_kSelectedGameId, id);

  String? readSelectedGameId() => _prefs.getString(_kSelectedGameId);

  /// Limpa apenas o cache de domínio (usado no logout). O token é removido à
  /// parte via [deleteToken].
  Future<void> clearCache() async {
    await _prefs.remove(_kGames);
    await _prefs.remove(_kSelectedGameId);
  }
}
