import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/backup_chart_model.dart';
import '../data/models/insight_model.dart';
import '../../games/domain/selected_game_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStatsModel>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(selectedGame?.id);
});

final chartDataProvider = FutureProvider.autoDispose<List<BackupChartPoint>>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getChartData(selectedGame?.id);
});

final insightsProvider = FutureProvider.autoDispose<List<InsightModel>>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getInsights(selectedGame?.id);
});
