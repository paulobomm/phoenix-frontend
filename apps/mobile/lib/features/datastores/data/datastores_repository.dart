import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/datastore_model.dart';
import 'models/entry_model.dart';

class DataStoresRepository {
  final ApiClient _apiClient;

  DataStoresRepository(this._apiClient);

  Future<List<DataStoreModel>> getDataStores(String gameId) async {
    try {
      final res = await _apiClient.dio.get('/v1/datastores', queryParameters: {'gameId': gameId});
      final list = res.data as List;
      return list.map((e) => DataStoreModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<EntryModel>> getEntries(String datastoreId) async {
    try {
      final res = await _apiClient.dio.get('/v1/datastores/$datastoreId/entries');
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list.map((e) => EntryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<EntryModel?> searchEntry(String datastoreId, String key) async {
    try {
      final res = await _apiClient.dio.get('/v1/datastores/$datastoreId/entries/$key');
      return EntryModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
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
