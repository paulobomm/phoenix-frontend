import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/backup_chart_model.dart';
import '../data/models/insight_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

// Global stats — no game filter
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStatsModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(null);
});

// Global chart — no game filter
final chartDataProvider = FutureProvider.autoDispose<List<BackupChartPoint>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getChartData(null);
});

// Global insights — no game filter
final insightsProvider = FutureProvider.autoDispose<List<InsightModel>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getInsights(null);
});
