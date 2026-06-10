import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/snapshot_model.dart';
import 'models/compare_result_model.dart';

class SnapshotsRepository {
  final ApiClient _apiClient;

  SnapshotsRepository(this._apiClient);

  Future<List<SnapshotModel>> getSnapshots(String gameId) async {
    try {
      final res = await _apiClient.dio.get('/v1/snapshots', queryParameters: {'gameId': gameId});
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list.map((e) => SnapshotModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<SnapshotModel?> getSnapshot(String id) async {
    try {
      final res = await _apiClient.dio.get('/v1/snapshots/$id');
      return SnapshotModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(_parseError(e));
    }
  }

  Future<CompareResultModel> compareSnapshots(String aId, String bId) async {
    try {
      final res = await _apiClient.dio.post('/v1/snapshots/compare', data: {
        'snapshotAId': aId,
        'snapshotBId': bId,
      });
      return CompareResultModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> restore(
    String snapshotId,
    String? destinationDatastore,
    List<String>? keys,
  ) async {
    try {
      await _apiClient.dio.post('/v1/snapshots/$snapshotId/restore', data: {
        if (destinationDatastore != null) 'destination': destinationDatastore,
        if (keys != null) 'keys': keys,
      });
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
