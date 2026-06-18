import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_provider.dart';
import '../../games/domain/games_provider.dart';
import '../../snapshots/data/models/snapshot_model.dart';
import '../../snapshots/domain/snapshots_provider.dart';

class PlanLimits {
  final String planName;
  final int maxGames;
  final double maxStorageGb;
  final int maxBackupsPerMonth;

  const PlanLimits({
    required this.planName,
    required this.maxGames,
    required this.maxStorageGb,
    required this.maxBackupsPerMonth,
  });
}

class PlanUsage {
  final int gamesUsed;
  final double storageUsedGb;
  final int backupsThisMonth;
  final int totalKeys;
  final PlanLimits limits;

  const PlanUsage({
    required this.gamesUsed,
    required this.storageUsedGb,
    required this.backupsThisMonth,
    required this.totalKeys,
    required this.limits,
  });
}

PlanLimits _limitsForPlan(String plan) {
  switch (plan.toLowerCase()) {
    case 'studio':
      return const PlanLimits(planName: 'Studio', maxGames: 999, maxStorageGb: 500, maxBackupsPerMonth: 99999);
    case 'pro':
      return const PlanLimits(planName: 'Pro', maxGames: 10, maxStorageGb: 50, maxBackupsPerMonth: 500);
    default:
      return const PlanLimits(planName: 'Básico', maxGames: 10, maxStorageGb: 5, maxBackupsPerMonth: 99999);
  }
}

final planUsageProvider = FutureProvider.autoDispose<PlanUsage>((ref) async {
  final user = ref.watch(authProvider).user;
  final plan = user?.plan ?? 'free';
  final limits = _limitsForPlan(plan);

  final gamesAsync = ref.watch(gamesProvider);
  final games = gamesAsync.valueOrNull ?? [];

  if (games.isEmpty) {
    return PlanUsage(
      gamesUsed: 0,
      storageUsedGb: 0,
      backupsThisMonth: 0,
      totalKeys: 0,
      limits: limits,
    );
  }

  final repo = ref.read(snapshotsRepositoryProvider);

  final now = DateTime.now();
  int backupsThisMonth = 0;
  double totalBytes = 0;
  int totalKeys = 0;

  final allSnapshots = await Future.wait(
    games.map((g) async {
      try {
        return await repo.getSnapshots(g.id);
      } catch (_) {
        return <SnapshotModel>[];
      }
    }),
  );

  for (final snapshots in allSnapshots) {
    for (final s in snapshots) {
      if (s.createdAt.year == now.year && s.createdAt.month == now.month) {
        backupsThisMonth++;
      }
      if (s.status == 'completed') {
        totalBytes += s.sizeBytes ?? 0;
        totalKeys += s.keyCount ?? 0;
      }
    }
  }

  return PlanUsage(
    gamesUsed: games.length,
    storageUsedGb: totalBytes / (1024 * 1024 * 1024),
    backupsThisMonth: backupsThisMonth,
    totalKeys: totalKeys,
    limits: limits,
  );
});
