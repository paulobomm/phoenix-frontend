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

final entriesProvider =
    FutureProvider.autoDispose.family<List<EntryModel>, String>((ref, datastoreId) async {
  // Entries are not exposed by the discovery API — return empty list.
  return [];
});
