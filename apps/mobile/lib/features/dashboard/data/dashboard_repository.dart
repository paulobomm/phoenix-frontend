import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/dashboard_stats_model.dart';
import 'models/backup_chart_model.dart';
import 'models/insight_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardStatsModel> getStats(String? gameId) async {
    try {
      final res = await _apiClient.dio.get('/v1/analytics/dashboard');
      return DashboardStatsModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      return const DashboardStatsModel(
        totalGames: 0,
        totalBackups: 0,
        storageUsedGb: 0,
        successRate: 100,
      );
    }
  }

  Future<List<BackupChartPoint>> getChartData(String? gameId) async {
    try {
      final params = <String, dynamic>{'days': '30'};
      if (gameId != null) params['gameId'] = gameId;
      final res = await _apiClient.dio.get('/v1/analytics/chart', queryParameters: params);
      final list = res.data as List;
      return list.map((e) => BackupChartPoint.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException {
      return [];
    }
  }

  Future<List<InsightModel>> getInsights(String? gameId) async {
    try {
      final params = <String, dynamic>{};
      if (gameId != null) params['gameId'] = gameId;
      final res = await _apiClient.dio.get('/v1/analytics/insights', queryParameters: params);
      final list = res.data as List;
      return list.map((e) => InsightModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException {
      return [];
    }
  }
}
