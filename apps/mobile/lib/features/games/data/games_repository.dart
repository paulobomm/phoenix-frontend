import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/game_model.dart';

class GamesRepository {
  final ApiClient _apiClient;

  GamesRepository(this._apiClient);

  Future<List<GameModel>> getGames() async {
    try {
      final res = await _apiClient.projectsDio.get('/v1/projects');
      // Backend returns HATEOAS paginated: { data: [...], meta: {...} }
      final list = (res.data['data'] ?? res.data) as List;
      return list.map((e) => GameModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<GameModel> addGame(String name, String universeId, String apiKey) async {
    try {
      final res = await _apiClient.projectsDio.post('/v1/projects', data: {
        'name': name,
        'universeId': universeId,
        'apiKey': apiKey,
      });
      return GameModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteGame(String id) async {
    try {
      await _apiClient.projectsDio.delete('/v1/projects/$id');
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
