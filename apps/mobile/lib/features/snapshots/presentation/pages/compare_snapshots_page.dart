import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../data/models/snapshot_model.dart';
import '../../domain/snapshots_provider.dart';

class CompareSnapshotsPage extends ConsumerStatefulWidget {
  const CompareSnapshotsPage({super.key});

  @override
  ConsumerState<CompareSnapshotsPage> createState() => _CompareSnapshotsPageState();
}

class _CompareSnapshotsPageState extends ConsumerState<CompareSnapshotsPage> {
  SnapshotModel? _snapA;
  SnapshotModel? _snapB;
  bool _compared = false;
  bool _isComparing = false;

  String _label(SnapshotModel s) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final d = s.createdAt;
    return '${s.name} (${d.day} ${months[d.month - 1]})';
  }

  Future<void> _compare() async {
    setState(() => _isComparing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isComparing = false;
      _compared = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshotsAsync = ref.watch(snapshotsProvider);

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
      body: snapshotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppColors.error))),
        data: (snapshots) {
          final completed = snapshots.where((s) => s.status == 'completed').toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (completed.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum snapshot disponível para comparação.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (completed.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'São necessários pelo menos 2 snapshots para comparar.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Auto-select A and B on first load
          if (_snapA == null && _snapB == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() { _snapA = completed[0]; _snapB = completed[1]; });
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _snapshotDropdown('Snapshot A', _snapA, completed, (v) => setState(() { _snapA = v; _compared = false; })),
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
                      child: _snapshotDropdown('Snapshot B', _snapB, completed, (v) => setState(() { _snapB = v; _compared = false; })),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PhoenixButton(
                  label: 'Comparar',
                  isLoading: _isComparing,
                  onPressed: (_snapA != null && _snapB != null && _snapA!.id != _snapB!.id) ? _compare : null,
                  width: double.infinity,
                  icon: Icons.search_rounded,
                ),
                if (_compared && _snapA != null && _snapB != null) ...[
                  const SizedBox(height: 32),
                  _CompareResult(snapA: _snapA!, snapB: _snapB!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _snapshotDropdown(String label, SnapshotModel? value, List<SnapshotModel> options, ValueChanged<SnapshotModel?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<SnapshotModel>(
        value: value,
        isExpanded: true,
        hint: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        style: const TextStyle(color: AppColors.text, fontSize: 12),
        dropdownColor: AppColors.card,
        underline: const SizedBox(),
        icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 18),
        items: options.map((s) => DropdownMenuItem(
          value: s,
          child: Text(_label(s), overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _CompareResult extends StatelessWidget {
  final SnapshotModel snapA;
  final SnapshotModel snapB;

  const _CompareResult({required this.snapA, required this.snapB});

  @override
  Widget build(BuildContext context) {
    final keysA = snapA.keyCount ?? 0;
    final keysB = snapB.keyCount ?? 0;
    final diff = (keysA - keysB).abs();
    final added = keysA > keysB ? keysA - keysB : 0;
    final removed = keysB > keysA ? keysB - keysA : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (diff == 0)
          _infoBox(
            'Os snapshots possuem o mesmo número de keys ($keysA).',
            AppColors.primary,
            Icons.check_circle_outline_rounded,
          )
        else ...[
          if (added > 0)
            _diffSection('Adicionadas', '$added keys a mais em A', AppColors.success, Icons.add_circle_outline_rounded),
          if (removed > 0) ...[
            const SizedBox(height: 16),
            _diffSection('Removidas', '$removed keys a menos em A', AppColors.error, Icons.remove_circle_outline_rounded),
          ],
        ],
        const SizedBox(height: 16),
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
              _summaryRow('Keys em A', '$keysA', AppColors.primary),
              const SizedBox(height: 10),
              _summaryRow('Keys em B', '$keysB', AppColors.primary),
              const SizedBox(height: 10),
              _summaryRow('Diferença total', '$diff', diff == 0 ? AppColors.success : AppColors.warning),
              if (snapA.sizeBytes != null && snapB.sizeBytes != null) ...[
                const SizedBox(height: 10),
                _summaryRow('Tamanho A', snapA.formattedSize, AppColors.textSecondary),
                const SizedBox(height: 10),
                _summaryRow('Tamanho B', snapB.formattedSize, AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String msg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _diffSection(String title, String detail, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(detail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
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
