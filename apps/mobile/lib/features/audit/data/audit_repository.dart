import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/log_model.dart';

class AuditRepository {
  final ApiClient _apiClient;

  AuditRepository(this._apiClient);

  Future<List<LogModel>> getLogs(String? gameId) async {
    try {
      final res = await _apiClient.dio.get('/v1/logs', queryParameters: {
        if (gameId != null) 'gameId': gameId,
      });
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list.map((e) => LogModel.fromJson(e as Map<String, dynamic>)).toList();
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
