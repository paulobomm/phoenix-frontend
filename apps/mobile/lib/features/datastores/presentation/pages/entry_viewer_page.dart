import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/datastores_provider.dart';
import '../widgets/json_viewer_widget.dart';

class EntryViewerPage extends ConsumerStatefulWidget {
  final String datastoreId;

  const EntryViewerPage({
    super.key,
    required this.datastoreId,
  });

  @override
  ConsumerState<EntryViewerPage> createState() => _EntryViewerPageState();
}

class _EntryViewerPageState extends ConsumerState<EntryViewerPage> {
  String? _selectedKey;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String get datastoreId => widget.datastoreId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(entriesProvider(widget.datastoreId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.watch(datastoresProvider).valueOrNull
                  ?.where((d) => d.id == datastoreId)
                  .firstOrNull
                  ?.name ?? 'DataStore',
              style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
            const Text('Entry Viewer', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
      body: entriesAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonCard(),
          ),
        ),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
        data: (entries) {
          final filtered = entries
              .where((e) => e.key.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return Row(
            children: [
              SizedBox(
                width: 180,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Buscar key...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('Nenhuma entry', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final entry = filtered[index];
                                final isSelected = entry.key == _selectedKey;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedKey = entry.key),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : AppColors.card,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.primary : AppColors.text,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: AppColors.border),
              Expanded(
                child: _selectedKey == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded, size: 36, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('Selecione uma entry', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      )
                    : Builder(builder: (context) {
                        final entry = entries.firstWhere((e) => e.key == _selectedKey);
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: AppColors.card,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 18),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: entry.value.toString()));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copiado!'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: JsonViewerWidget(data: entry.value),
                              ),
                            ),
                          ],
                        );
                      }),
              ),
            ],
          );
        },
      ),
    );
  }
}
