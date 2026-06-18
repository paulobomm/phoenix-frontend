import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/backup_chart_model.dart';
import '../data/models/insight_model.dart';
import '../../audit/domain/audit_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

// Global stats — no game filter
final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStatsModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(null);
});

// Chart built from audit logs grouped by day (last 30 days)
final chartDataProvider =
    FutureProvider.autoDispose<List<BackupChartPoint>>((ref) async {
  // Try analytics API first
  final repo = ref.read(dashboardRepositoryProvider);
  final apiPoints = await repo.getChartData(null);
  if (apiPoints.isNotEmpty) return apiPoints;

  // Fallback: build from audit logs
  final logs = await ref.read(auditRepositoryProvider).getLogs(null);

  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));
  final countByDay = <String, int>{};

  // Pre-fill 30 days with 0
  for (int i = 0; i < 30; i++) {
    final d = now.subtract(Duration(days: 29 - i));
    countByDay['${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'] = 0;
  }

  for (final log in logs) {
    if (log.occurredAt.isBefore(cutoff)) continue;
    final key =
        '${log.occurredAt.year}-${log.occurredAt.month.toString().padLeft(2, '0')}-${log.occurredAt.day.toString().padLeft(2, '0')}';
    countByDay[key] = (countByDay[key] ?? 0) + 1;
  }

  return countByDay.entries.map((e) {
    final parts = e.key.split('-');
    return BackupChartPoint(
      date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      count: e.value,
    );
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

// Global insights — no game filter
final insightsProvider =
    FutureProvider.autoDispose<List<InsightModel>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getInsights(null);
});
