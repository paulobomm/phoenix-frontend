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
  final repo = ref.read(snapshotsRepositoryProvider);
  return repo.getSnapshots(selectedGame?.id ?? '');
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
