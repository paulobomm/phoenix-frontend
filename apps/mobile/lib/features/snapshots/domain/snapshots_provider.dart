import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/snapshots_repository.dart';
import '../data/models/snapshot_model.dart';
import '../../games/domain/selected_game_provider.dart';

final snapshotsRepositoryProvider = Provider<SnapshotsRepository>((ref) {
  return SnapshotsRepository(ref.read(apiClientProvider));
});

final snapshotsProvider =
    FutureProvider.autoDispose<List<SnapshotModel>>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  if (selectedGame == null) return [];
  final repo = ref.read(snapshotsRepositoryProvider);
  return repo.getSnapshots(selectedGame.id);
});

// Per-project snapshot count — used by game cards
final snapshotCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, projectId) async {
  if (projectId.isEmpty) return 0;
  final repo = ref.read(snapshotsRepositoryProvider);
  final list = await repo.getSnapshots(projectId);
  return list.length;
});

final snapshotDetailProvider =
    FutureProvider.autoDispose.family<SnapshotModel?, String>((ref, id) async {
  final repo = ref.read(snapshotsRepositoryProvider);
  return repo.getSnapshot(id);
});

final schedulesProvider =
    FutureProvider.autoDispose<List<SnapshotScheduleModel>>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  final repo = ref.read(snapshotsRepositoryProvider);
  return repo.listSchedules(selectedGame?.id ?? '');
});

class ProjectStorageSummary {
  final int totalBackups;
  final double sizeGb;
  const ProjectStorageSummary({required this.totalBackups, required this.sizeGb});

  String get formattedSize {
    if (sizeGb <= 0) return '0 MB';
    if (sizeGb < 1) return '${(sizeGb * 1024).toStringAsFixed(1)} MB';
    return '${sizeGb.toStringAsFixed(2)} GB';
  }
}

final projectStorageSummaryProvider =
    FutureProvider.autoDispose.family<ProjectStorageSummary, String>((ref, projectId) async {
  if (projectId.isEmpty) return const ProjectStorageSummary(totalBackups: 0, sizeGb: 0);
  final repo = ref.read(snapshotsRepositoryProvider);
  final snapshots = await repo.getSnapshots(projectId);
  double totalBytes = 0;
  for (final s in snapshots) {
    if (s.status == 'completed') totalBytes += s.sizeBytes ?? 0;
  }
  return ProjectStorageSummary(
    totalBackups: snapshots.length,
    sizeGb: totalBytes / (1024 * 1024 * 1024),
  );
});
