import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../data/models/snapshot_model.dart';
import '../../domain/snapshots_provider.dart';

class RestoreWizardPage extends ConsumerStatefulWidget {
  final String? snapshotId;
  const RestoreWizardPage({super.key, this.snapshotId});

  @override
  ConsumerState<RestoreWizardPage> createState() => _RestoreWizardPageState();
}

class _RestoreWizardPageState extends ConsumerState<RestoreWizardPage> {
  int _step = 0;
  SnapshotModel? _selectedSnapshot;
  String _scope = 'full';
  String _destino = 'same';
  double _progress = 0;
  final List<String> _logs = [];

  static const _steps = ['Origem', 'Destino', 'Confirmação', 'Progresso', 'Conclusão'];

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _snapshotLabel(SnapshotModel s) {
    return '${s.name} — ${_formatDate(s.createdAt)}';
  }

  String _formatSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '—';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _startRestore() async {
    setState(() {
      _step = 3;
      _progress = 0;
      _logs.clear();
    });

    final logLines = [
      'Iniciando restore...',
      'Conectando ao Roblox Open Cloud...',
      'Validando snapshot selecionado...',
      'Restaurando PlayerData (1/3)...',
      'Restaurando Leaderboards (2/3)...',
      'Restaurando Inventory (3/3)...',
      'Verificando integridade dos dados...',
      'Restore concluído com sucesso!',
    ];

    for (int i = 0; i < logLines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _logs.add(logLines[i]);
        _progress = (i + 1) / logLines.length;
      });
    }

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _step = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _step < 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.text, size: 20),
                onPressed: () => _step > 0 ? setState(() => _step--) : context.pop(),
              )
            : const SizedBox.shrink(),
        title: const Text(
          'Restaurar Backup',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _HorizontalStepper(currentStep: _step, steps: _steps),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildOrigem();
      case 1: return _buildDestino();
      case 2: return _buildConfirmacao();
      case 3: return _buildProgresso();
      case 4: return _buildConclusao();
      default: return _buildOrigem();
    }
  }

  Widget _buildOrigem() {
    final snapshotsAsync = ref.watch(snapshotsProvider);

    return SingleChildScrollView(
      key: const ValueKey('s0'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Selecione o snapshot de origem', 'Escolha o backup que deseja restaurar'),
          const SizedBox(height: 24),
          snapshotsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Text('Erro ao carregar snapshots: $e', style: const TextStyle(color: AppColors.error)),
            data: (snapshots) {
              final completed = snapshots.where((s) => s.status == 'completed').toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              if (completed.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Nenhum snapshot disponível para restauração.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        const Text('Snapshot', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<SnapshotModel>(
                          value: _selectedSnapshot,
                          hint: const Text('Selecionar snapshot...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          dropdownColor: AppColors.card,
                          style: const TextStyle(color: AppColors.text, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: completed.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(_snapshotLabel(s), style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedSnapshot = v),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedSnapshot != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _infoRow('Criado em', _formatDate(_selectedSnapshot!.createdAt)),
                          const SizedBox(height: 10),
                          _infoRow('Tamanho', _formatSize(_selectedSnapshot!.sizeBytes)),
                          const SizedBox(height: 10),
                          _infoRow('Keys', _selectedSnapshot!.keyCount != null ? '${_selectedSnapshot!.keyCount}' : '—'),
                          const SizedBox(height: 10),
                          _infoRow('Status', 'Completo'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Escopo do Restore', style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _radioOption('full', 'Restore Completo', 'Restaurar todas as keys do snapshot'),
                    const SizedBox(height: 10),
                    _radioOption('selective', 'Restore Seletivo', 'Selecionar keys específicas para restaurar'),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          PhoenixButton(
            label: 'Próximo →',
            onPressed: _selectedSnapshot == null ? null : () => setState(() => _step = 1),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildDestino() {
    return SingleChildScrollView(
      key: const ValueKey('s1'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Selecione o destino', 'Escolha onde os dados serão restaurados'),
          const SizedBox(height: 24),
          _destinoOption('same', 'Mesmo DataStore', 'Restaurar diretamente no datastore original', Icons.sync_rounded),
          const SizedBox(height: 12),
          _destinoOption('new', 'Novo DataStore', 'Criar uma cópia em um datastore separado', Icons.add_circle_outline_rounded),
          const SizedBox(height: 32),
          _navButtons(() => setState(() => _step = 0), () => setState(() => _step = 2)),
        ],
      ),
    );
  }

  Widget _buildConfirmacao() {
    final s = _selectedSnapshot;
    return SingleChildScrollView(
      key: const ValueKey('s2'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Confirmação', 'Revise os detalhes antes de prosseguir'),
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
                _infoRow('Snapshot', s != null ? _snapshotLabel(s).split(' — ').first : '—'),
                const SizedBox(height: 10),
                _infoRow('Criado em', s != null ? _formatDate(s.createdAt) : '—'),
                const SizedBox(height: 10),
                _infoRow('Escopo', _scope == 'full' ? 'Restore Completo' : 'Restore Seletivo'),
                const SizedBox(height: 10),
                _infoRow('Destino', _destino == 'same' ? 'Mesmo DataStore' : 'Novo DataStore'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta operação irá substituir os dados atuais. Todos os dados serão restaurados para o estado deste snapshot.',
                    style: TextStyle(color: AppColors.warning, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _navButtons(() => setState(() => _step = 1), _startRestore),
        ],
      ),
    );
  }

  Widget _buildProgresso() {
    return Padding(
      key: const ValueKey('s3'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Restaurando...', 'Aguarde enquanto os dados são restaurados'),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(_progress * 100).toInt()}% concluído',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, i) {
                  final isLast = i == _logs.length - 1;
                  final isSuccess = _logs[i].contains('sucesso');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle_rounded : Icons.arrow_right_rounded,
                          size: 16,
                          color: isSuccess ? AppColors.success : isLast ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _logs[i],
                          style: TextStyle(
                            color: isSuccess ? AppColors.success : isLast ? AppColors.text : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusao() {
    return Center(
      key: const ValueKey('s4'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 44),
            ),
            const SizedBox(height: 24),
            const Text('Restore Concluído!',
                style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
              'Os dados foram restaurados com sucesso para o estado do snapshot selecionado.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PhoenixButton(
              label: 'Ver Backups',
              onPressed: () => context.go('/snapshots'),
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text('Ir para Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioOption(String value, String title, String subtitle) {
    final selected = _scope == value;
    return GestureDetector(
      onTap: () => setState(() => _scope = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _scope,
              onChanged: (v) => setState(() => _scope = v!),
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? AppColors.primary : AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destinoOption(String value, String title, String subtitle, IconData icon) {
    final selected = _destino == value;
    return GestureDetector(
      onTap: () => setState(() => _destino = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (selected ? AppColors.primary : AppColors.textSecondary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? AppColors.primary : AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _destino,
              onChanged: (v) => setState(() => _destino = v!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButtons(VoidCallback onBack, VoidCallback onNext) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('← Voltar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: PhoenixButton(label: 'Próximo →', onPressed: onNext, width: double.infinity),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _HorizontalStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _HorizontalStepper({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIdx < currentStep ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final isDone = stepIdx < currentStep;
          final isActive = stepIdx == currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone || isActive ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone || isActive ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
