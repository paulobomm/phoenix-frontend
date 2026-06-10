import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/log_model.dart';

class AuditRepository {
  final ApiClient _apiClient;

  AuditRepository(this._apiClient);

  Future<List<LogModel>> getLogs(
    String? projectId, {
    String? eventType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _apiClient.auditDio.get('/v1/audit', queryParameters: {
        if (projectId != null) 'project_id': projectId,
        if (eventType != null) 'type': eventType,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        '_page': page,
        '_size': limit,
      });
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list
          .map((e) => LogModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
