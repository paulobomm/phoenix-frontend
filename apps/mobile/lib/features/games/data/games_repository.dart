import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/game_model.dart';

class GamesRepository {
  final ApiClient _apiClient;

  GamesRepository(this._apiClient);

  Future<List<GameModel>> getGames() async {
    try {
      final res = await _apiClient.dio.get('/v1/games');
      final list = res.data as List;
      return list.map((e) => GameModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<GameModel> addGame(
    String universeId,
    String placeId,
    String name,
    String apiKey,
    int syncInterval,
  ) async {
    try {
      final res = await _apiClient.dio.post('/v1/games', data: {
        'name': name,
        'universeId': universeId,
        'placeId': placeId,
        'apiKey': apiKey,
        'syncInterval': syncInterval,
      });
      return GameModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteGame(String id) async {
    try {
      await _apiClient.dio.delete('/v1/games/$id');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<GameModel> toggleSync(String id, bool pause) async {
    try {
      final res = await _apiClient.dio.post('/v1/games/$id/toggle-sync');
      return GameModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    return e.message ?? 'Erro de conexão';
  }
}
