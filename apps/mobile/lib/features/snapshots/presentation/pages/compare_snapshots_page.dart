import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';

class CompareSnapshotsPage extends StatefulWidget {
  const CompareSnapshotsPage({super.key});

  @override
  State<CompareSnapshotsPage> createState() => _CompareSnapshotsPageState();
}

class _CompareSnapshotsPageState extends State<CompareSnapshotsPage> {
  String? _snapA = 'Backup Automático (15 Jan)';
  String? _snapB = 'Backup Manual (14 Jan)';
  bool _compared = false;
  bool _isComparing = false;

  final _snapshots = [
    'Backup Automático (15 Jan)',
    'Backup Manual (14 Jan)',
    'Backup Automático (13 Jan)',
    'Backup Automático (12 Jan)',
  ];

  final _mockDiff = {
    'added': ['Player_99123456', 'Player_77654321'],
    'removed': ['Player_00000001'],
    'modified': ['Player_12345678', 'Player_87654321', 'Player_55443322'],
  };

  Future<void> _compare() async {
    setState(() => _isComparing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isComparing = false;
      _compared = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Comparar Snapshots',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _snapshotDropdown('Snapshot A', _snapA, (v) => setState(() { _snapA = v; _compared = false; })),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.compare_arrows_rounded, color: AppColors.textSecondary, size: 16),
                  ),
                ),
                Expanded(
                  child: _snapshotDropdown('Snapshot B', _snapB, (v) => setState(() { _snapB = v; _compared = false; })),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PhoenixButton(
              label: 'Comparar',
              isLoading: _isComparing,
              onPressed: _compare,
              width: double.infinity,
              icon: Icons.search_rounded,
            ),
            if (_compared) ...[
              const SizedBox(height: 32),
              _diffSection('Adicionados', _mockDiff['added']!, AppColors.success, Icons.add_circle_outline_rounded),
              const SizedBox(height: 16),
              _diffSection('Removidos', _mockDiff['removed']!, AppColors.error, Icons.remove_circle_outline_rounded),
              const SizedBox(height: 16),
              _diffSection('Modificados', _mockDiff['modified']!, AppColors.warning, Icons.edit_outlined),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumo', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    _summaryRow('Total de mudanças', '6', AppColors.primary),
                    const SizedBox(height: 10),
                    _summaryRow('Adicionados', '${_mockDiff['added']!.length}', AppColors.success),
                    const SizedBox(height: 10),
                    _summaryRow('Removidos', '${_mockDiff['removed']!.length}', AppColors.error),
                    const SizedBox(height: 10),
                    _summaryRow('Modificados', '${_mockDiff['modified']!.length}', AppColors.warning),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _snapshotDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        style: const TextStyle(color: AppColors.text, fontSize: 12),
        dropdownColor: AppColors.card,
        underline: const SizedBox(),
        icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 18),
        items: _snapshots.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _diffSection(String title, List<String> items, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${items.length}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          ...items.map((key) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Text(key, style: const TextStyle(color: AppColors.text, fontSize: 13, fontFamily: 'monospace')),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
