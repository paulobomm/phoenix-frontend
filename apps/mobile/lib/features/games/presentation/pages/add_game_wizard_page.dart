import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../../../shared/widgets/phoenix_text_field.dart';
import '../../domain/games_provider.dart';
import '../../data/models/game_model.dart';
import '../../../snapshots/domain/snapshots_provider.dart';
import '../../../datastores/domain/datastores_provider.dart';
import '../../../datastores/data/models/datastore_model.dart';

class AddGameWizardPage extends ConsumerStatefulWidget {
  final bool isDialog;
  const AddGameWizardPage({super.key, this.isDialog = false});

  @override
  ConsumerState<AddGameWizardPage> createState() => _AddGameWizardPageState();
}

class _AddGameWizardPageState extends ConsumerState<AddGameWizardPage> {
  int _currentStep = 0;
  final _nameCtrl = TextEditingController();
  final _universeIdCtrl = TextEditingController();
  final _placeIdCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _isValidating = false;
  bool _apiKeyValid = false;

  // Step 3 state
  bool _isCreatingGame = false;
  GameModel? _createdGame;
  bool _loadingDatastores = false;
  List<DataStoreModel> _datastores = [];
  Set<String> _selectedDatastoreIds = {};
  bool _isFinishing = false;

  static const _intervalOptions = [
    (label: 'A cada 5 minutos',  cron: '*/5 * * * *'),
    (label: 'A cada 10 minutos', cron: '*/10 * * * *'),
    (label: 'A cada 15 minutos', cron: '*/15 * * * *'),
    (label: 'A cada 30 minutos', cron: '*/30 * * * *'),
    (label: 'A cada 1 hora',     cron: '0 * * * *'),
  ];
  int _selectedIntervalIndex = 2; // padrão: 15 min

  @override
  void dispose() {
    _nameCtrl.dispose();
    _universeIdCtrl.dispose();
    _placeIdCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateApiKey() async {
    if (_apiKeyCtrl.text.trim().isEmpty) return;
    setState(() { _isValidating = true; _apiKeyValid = false; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() { _isValidating = false; _apiKeyValid = true; });
  }

  // Called when advancing from step 2 → step 3: creates the game and loads datastores
  Future<void> _createGameAndAdvance() async {
    setState(() => _isCreatingGame = true);
    try {
      final game = await ref.read(gamesProvider.notifier).addGame(
        _nameCtrl.text.trim(),
        _universeIdCtrl.text.trim(),
        _apiKeyCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _createdGame = game;
        _currentStep = 2;
        _loadingDatastores = true;
      });
      // Load datastores in background
      if (game != null) {
        try {
          final repo = ref.read(datastoresRepositoryProvider);
          final ds = await repo.getDataStores(game.id);
          if (!mounted) return;
          setState(() {
            _datastores = ds;
            _selectedDatastoreIds = ds.map((d) => d.id).toSet();
          });
        } catch (_) {
          // Datastores not available yet — that's ok
        }
      }
      if (mounted) setState(() => _loadingDatastores = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingGame = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (mounted) setState(() => _isCreatingGame = false);
  }

  Future<void> _finish() async {
    final game = _createdGame;
    if (game == null) return;
    setState(() => _isFinishing = true);
    try {
      final cron = _intervalOptions[_selectedIntervalIndex].cron;
      final repo = ref.read(snapshotsRepositoryProvider);
      await repo.createSchedule(game.id, cron);
    } catch (_) {
      // schedule creation is best-effort
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
    if (!mounted) return;
    if (widget.isDialog) {
      Navigator.of(context).pop();
    } else {
      context.pop();
    }
  }

  void _close() {
    if (widget.isDialog) {
      Navigator.of(context).pop();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildHeader(),
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: [_buildStep1(), _buildStep2(), _buildStep3()][_currentStep],
            ),
          ),
        ),
      ],
    );

    if (widget.isDialog) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: content),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adicionar Jogo',
                    style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Conecte seu jogo Roblox ao Phoenix',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Etapa ${_currentStep + 1} de 3',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                ['Informações Básicas', 'API Key', 'Configuração'][_currentStep],
                style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhoenixTextField(
          label: 'Nome do Jogo',
          hint: 'Ex: CoolGame RPG',
          controller: _nameCtrl,
        ),
        const SizedBox(height: 16),
        PhoenixTextField(
          label: 'Universe ID',
          hint: 'Ex: 3924839',
          controller: _universeIdCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        PhoenixTextField(
          label: 'Place ID',
          hint: 'Ex: 9283745',
          controller: _placeIdCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        PhoenixButton(
          label: 'Próximo →',
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty || _universeIdCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preencha Nome e Universe ID'), behavior: SnackBarBehavior.floating),
              );
              return;
            }
            setState(() => _currentStep = 1);
          },
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Acesse o Creator Hub do Roblox, vá em Credenciais API e gere uma nova chave com permissões de DataStore.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Abrir Creator Hub 🔗',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PhoenixTextField(
          label: 'API KEY',
          hint: 'rbxp_...',
          controller: _apiKeyCtrl,
          obscureText: _obscureKey,
          suffix: IconButton(
            icon: Icon(
              _obscureKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureKey = !_obscureKey),
          ),
        ),
        if (_apiKeyValid) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                SizedBox(width: 8),
                Text('✅ API Key válida!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        PhoenixButton(
          label: _apiKeyValid ? 'Cadastrar e Configurar →' : 'Validar e Próximo →',
          onPressed: _apiKeyValid
              ? _createGameAndAdvance
              : (_apiKeyCtrl.text.isEmpty ? null : _validateApiKey),
          isLoading: _isValidating || _isCreatingGame,
          width: double.infinity,
          backgroundColor: _apiKeyValid ? AppColors.success : null,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0),
          child: const Text('← Voltar', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Backup interval ──────────────────────────────────────────────
        const Text('INTERVALO DE BACKUP',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedIntervalIndex,
              isExpanded: true,
              dropdownColor: AppColors.card,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              items: List.generate(_intervalOptions.length, (i) {
                return DropdownMenuItem(value: i, child: Text(_intervalOptions[i].label));
              }),
              onChanged: (i) {
                if (i != null) setState(() => _selectedIntervalIndex = i);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cron: ${_intervalOptions[_selectedIntervalIndex].cron}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Datastores ───────────────────────────────────────────────────
        Row(
          children: [
            const Text('DATASTORES ENCONTRADOS',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            if (_loadingDatastores) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (!_loadingDatastores && _datastores.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Os datastores serão descobertos automaticamente após o primeiro backup.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          )
        else if (_datastores.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Header with "select all"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Datastore', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const Text('Tipo', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedDatastoreIds.length == _datastores.length) {
                              _selectedDatastoreIds = {};
                            } else {
                              _selectedDatastoreIds = _datastores.map((d) => d.id).toSet();
                            }
                          });
                        },
                        child: Text(
                          _selectedDatastoreIds.length == _datastores.length ? 'Desm. todos' : 'Sel. todos',
                          style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),
                ..._datastores.map((ds) {
                  final isSelected = _selectedDatastoreIds.contains(ds.id);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDatastoreIds.remove(ds.id);
                        } else {
                          _selectedDatastoreIds.add(ds.id);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedDatastoreIds.add(ds.id);
                                  } else {
                                    _selectedDatastoreIds.remove(ds.id);
                                  }
                                });
                              },
                              activeColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ds.name,
                              style: const TextStyle(color: AppColors.text, fontSize: 13, fontFamily: 'monospace'),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ds.type,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

        const SizedBox(height: 24),
        PhoenixButton(
          label: 'Concluir Cadastro ✓',
          onPressed: _finish,
          isLoading: _isFinishing,
          width: double.infinity,
        ),
      ],
    );
  }
}
