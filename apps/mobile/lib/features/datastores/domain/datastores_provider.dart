import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/datastores_repository.dart';
import '../data/models/datastore_model.dart';
import '../data/models/entry_model.dart';
import '../../games/domain/selected_game_provider.dart';

final datastoresRepositoryProvider = Provider<DataStoresRepository>((ref) {
  return DataStoresRepository(ref.read(apiClientProvider));
});

final datastoresProvider =
    FutureProvider.autoDispose<List<DataStoreModel>>((ref) async {
  final selectedGame = ref.watch(selectedGameProvider);
  final repo = ref.read(datastoresRepositoryProvider);
  return repo.getDataStores(selectedGame?.id ?? '');
});

// Per-project datastore count — used by game cards
final datastoreCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, projectId) async {
  if (projectId.isEmpty) return 0;
  final repo = ref.read(datastoresRepositoryProvider);
  try {
    final list = await repo.getDataStores(projectId);
    return list.length;
  } catch (_) {
    return 0;
  }
});

final entriesProvider =
    FutureProvider.autoDispose.family<List<EntryModel>, String>((ref, datastoreId) async {
  return [];
});
