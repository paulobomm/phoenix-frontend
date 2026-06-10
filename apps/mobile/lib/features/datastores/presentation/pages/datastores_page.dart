import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../games/presentation/widgets/game_selector_widget.dart';
import '../../data/models/datastore_model.dart';
import '../../domain/datastores_provider.dart';
import '../widgets/datastore_card.dart';

class DataStoresPage extends ConsumerStatefulWidget {
  const DataStoresPage({super.key});

  @override
  ConsumerState<DataStoresPage> createState() => _DataStoresPageState();
}

class _DataStoresPageState extends ConsumerState<DataStoresPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datastoresAsync = ref.watch(datastoresProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DataStores', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('Gerencie seus dados Roblox', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/player-search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.person_search_rounded, color: AppColors.textSecondary, size: 16),
                          SizedBox(width: 4),
                          Text('Player', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const GameSelectorWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar datastore...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: AppColors.border,
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Standard'),
                Tab(text: 'Ordered'),
              ],
            ),
            Expanded(
              child: datastoresAsync.when(
                loading: () => ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [SkeletonCard(), SkeletonCard(), SkeletonCard()],
                ),
                error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
                data: (stores) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _DataStoreList(
                        stores: stores.where((s) => _search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase())).toList(),
                      ),
                      _DataStoreList(
                        stores: stores.where((s) => s.type == 'standard' && (_search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase()))).toList(),
                      ),
                      _DataStoreList(
                        stores: stores.where((s) => s.type == 'ordered' && (_search.isEmpty || s.name.toLowerCase().contains(_search.toLowerCase()))).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataStoreList extends StatelessWidget {
  final List<DataStoreModel> stores;

  const _DataStoreList({required this.stores});

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.storage_outlined,
        title: 'Nenhum DataStore',
        description: 'Nenhum datastore encontrado para este filtro.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, i) {
        final ds = stores[i];
        return DataStoreCard(
          datastore: ds,
          onTap: () => context.push('/datastores/${ds.id}/entries'),
        );
      },
    );
  }
}
