import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../audit/domain/audit_provider.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/backup_chart_model.dart';
import '../data/models/insight_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStatsModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(null);
});

final chartDataProvider = FutureProvider.autoDispose<List<BackupChartPoint>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final apiPoints = await repo.getChartData(null);
  if (apiPoints.isNotEmpty) return apiPoints;

  // Fallback: build from audit logs
  final auditRepo = ref.read(auditRepositoryProvider);
  final logs = await auditRepo.getLogs(null, limit: 200);
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));
  final countByDay = <String, int>{};

  for (int i = 0; i < 30; i++) {
    final d = now.subtract(Duration(days: 29 - i));
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    countByDay[key] = 0;
  }

  for (final log in logs) {
    if (log.occurredAt.isBefore(cutoff)) continue;
    final d = log.occurredAt;
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    countByDay[key] = (countByDay[key] ?? 0) + 1;
  }

  final sorted = countByDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return sorted.map((e) {
    final parts = e.key.split('-');
    return BackupChartPoint(
      date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      count: e.value,
    );
  }).toList();
});

final insightsProvider = FutureProvider.autoDispose<List<InsightModel>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getInsights(null);
});
