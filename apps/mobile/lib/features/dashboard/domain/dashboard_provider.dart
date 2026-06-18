import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/dashboard_repository.dart';
import '../data/models/dashboard_stats_model.dart';
import '../data/models/backup_chart_model.dart';
import '../data/models/insight_model.dart';
import '../../audit/domain/audit_provider.dart';
import '../../games/domain/games_provider.dart';
import '../../snapshots/domain/snapshots_provider.dart';
import '../../snapshots/data/models/snapshot_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

// Global stats — no game filter
final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStatsModel>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(null);
});

// Real snapshot stats aggregated across all games
class RealSnapshotStats {
  final int totalBackups;
  final double storageUsedGb;
  final double successRate;
  const RealSnapshotStats({
    required this.totalBackups,
    required this.storageUsedGb,
    required this.successRate,
  });

  String get formattedStorage {
    if (storageUsedGb <= 0) return '0 MB';
    if (storageUsedGb < 1) return '${(storageUsedGb * 1024).toStringAsFixed(0)} MB';
    return '${storageUsedGb.toStringAsFixed(2)} GB';
  }
}

final realSnapshotStatsProvider =
    FutureProvider.autoDispose<RealSnapshotStats>((ref) async {
  final games = ref.watch(gamesProvider).valueOrNull ?? [];
  if (games.isEmpty) {
    return const RealSnapshotStats(totalBackups: 0, storageUsedGb: 0, successRate: 100);
  }
  final repo = ref.read(snapshotsRepositoryProvider);
  int total = 0;
  int completed = 0;
  double totalBytes = 0;

  final allSnapshots = await Future.wait(
    games.map((g) async {
      try { return await repo.getSnapshots(g.id); } catch (_) { return <SnapshotModel>[]; }
    }),
  );
  int totalAll = 0;
  for (final snapshots in allSnapshots) {
    totalAll += snapshots.length;
    for (final s in snapshots) {
      if (s.status == 'completed') {
        completed++;
        totalBytes += s.sizeBytes ?? 0;
        total++;
      } else if (s.status == 'failed' || s.status == 'cancelled') {
        total++;
      }
      // pending/running are not counted in the success rate denominator
    }
  }
  final rate = total == 0 ? 100.0 : (completed / total * 100);
  return RealSnapshotStats(
    totalBackups: totalAll,
    storageUsedGb: totalBytes / (1024 * 1024 * 1024),
    successRate: rate,
  );
});

// Chart built from audit logs grouped by day (last 30 days)
final chartDataProvider =
    FutureProvider.autoDispose<List<BackupChartPoint>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final apiPoints = await repo.getChartData(null);
  if (apiPoints.isNotEmpty) return apiPoints;

  final logs = await ref.read(auditRepositoryProvider).getLogs(null);
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 30));
  final countByDay = <String, int>{};

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
