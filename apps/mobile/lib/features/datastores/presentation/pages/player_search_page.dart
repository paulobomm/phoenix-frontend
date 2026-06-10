import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/json_viewer_widget.dart';

class PlayerSearchPage extends StatefulWidget {
  const PlayerSearchPage({super.key});

  @override
  State<PlayerSearchPage> createState() => _PlayerSearchPageState();
}

class _PlayerSearchPageState extends State<PlayerSearchPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>>? _results;

  final _mockResults = [
    {
      'datastore': 'PlayerData',
      'key': 'Player_12345678',
      'value': {
        'userId': 12345678,
        'username': 'CoolPlayer123',
        'level': 42,
        'xp': 15430,
        'coins': 8750,
        'gems': 120,
        'isPremium': true,
        'badges': ['FirstBlood', 'Veteran', 'TopPlayer'],
      },
    },
    {
      'datastore': 'Inventory',
      'key': 'Player_12345678',
      'value': {
        'items': ['Sword_Epic', 'Shield_Rare', 'Potion_x10'],
        'equipped': 'Sword_Epic',
        'capacity': 50,
        'used': 3,
      },
    },
    {
      'datastore': 'Leaderboards',
      'key': 'Player_12345678',
      'value': {
        'rank': 142,
        'score': 15430,
        'wins': 234,
        'losses': 89,
      },
    },
  ];

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;
    setState(() { _isSearching = true; _results = null; });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _isSearching = false; _results = _mockResults; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Buscar Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Player ID ou Username...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      prefixIcon: const Icon(Icons.person_search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _search,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: _isSearching
                        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                        : const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _results == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_search_rounded, color: AppColors.textSecondary, size: 48),
                            SizedBox(height: 12),
                            Text('Busque por um player', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Digite Player ID ou Username', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : _results!.isEmpty
                        ? const Center(child: Text('Nenhum resultado', style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _results!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final result = _results![index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.storage_rounded, color: AppColors.primary, size: 18),
                                    ),
                                    title: Text(result['datastore'] as String, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
                                    subtitle: Text(result['key'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    iconColor: AppColors.textSecondary,
                                    collapsedIconColor: AppColors.textSecondary,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: JsonViewerWidget(data: result['value']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
