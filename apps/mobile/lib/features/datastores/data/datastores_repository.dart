import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/datastore_model.dart';

class DataStoresRepository {
  final ApiClient _apiClient;

  DataStoresRepository(this._apiClient);

  Future<List<DataStoreModel>> getDataStores(String projectId) async {
    try {
      final res = await _apiClient.discoveryDio
          .get('/v1/projects/$projectId/datastores');
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) {
            try { return DataStoreModel.fromJson(e); } catch (_) { return null; }
          })
          .whereType<DataStoreModel>()
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
