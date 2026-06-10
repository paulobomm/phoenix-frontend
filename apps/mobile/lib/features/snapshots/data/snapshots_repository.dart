import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/snapshot_model.dart';

class SnapshotsRepository {
  final ApiClient _apiClient;

  SnapshotsRepository(this._apiClient);

  Future<List<SnapshotModel>> getSnapshots(String projectId) async {
    try {
      final res = await _apiClient.snapshotsDio
          .get('/v1/projects/$projectId/snapshots');
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list
          .map((e) => SnapshotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<SnapshotModel?> getSnapshot(String jobId) async {
    try {
      final res = await _apiClient.snapshotsDio.get('/v1/snapshots/$jobId');
      return SnapshotModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(_parseError(e));
    }
  }

  Future<SnapshotModel> triggerManual(String projectId) async {
    try {
      final res = await _apiClient.snapshotsDio
          .post('/v1/projects/$projectId/snapshots');
      return SnapshotModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<SnapshotScheduleModel>> listSchedules(String projectId) async {
    try {
      final res = await _apiClient.snapshotsDio
          .get('/v1/projects/$projectId/snapshot-schedules');
      final data = res.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List);
      return list
          .map((e) => SnapshotScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<SnapshotScheduleModel> createSchedule(
      String projectId, String cronExpr) async {
    try {
      final res = await _apiClient.snapshotsDio.post(
        '/v1/projects/$projectId/snapshot-schedules',
        data: {'cronExpr': cronExpr},
      );
      return SnapshotScheduleModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _apiClient.snapshotsDio
          .delete('/v1/snapshot-schedules/$scheduleId');
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
