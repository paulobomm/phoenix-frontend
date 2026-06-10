import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../../../shared/widgets/phoenix_text_field.dart';
import '../../domain/games_provider.dart';

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
  final _placeIdCtrl = TextEditingController(); // UI only
  final _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _isFinishing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _universeIdCtrl.dispose();
    _placeIdCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _isFinishing = true);
    try {
      await ref.read(gamesProvider.notifier).addGame(
        _nameCtrl.text.trim(),
        _universeIdCtrl.text.trim(),
        _apiKeyCtrl.text.trim(),
      );
      if (!mounted) return;
      if (widget.isDialog) {
        Navigator.of(context).pop();
      } else {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
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
                    style:
                        TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
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
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                ['Informações Básicas', 'API Key', 'Integração'][_currentStep],
                style: const TextStyle(
                    color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
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
                const SnackBar(
                    content: Text('Preencha Nome e Universe ID'),
                    behavior: SnackBarBehavior.floating),
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como obter sua API Key:',
                  style:
                      TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text(
                  '1. Acesse o Roblox Creator Hub\n2. Vá em Credenciais → API Keys\n3. Crie com permissão de DataStore API',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PhoenixTextField(
          label: 'Open Cloud API Key',
          hint: 'opencloud_...',
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
        const SizedBox(height: 8),
        const Text(
          'A API Key é criptografada em repouso e nunca é retornada pela API.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 20),
        PhoenixButton(
          label: 'Próximo →',
          onPressed: () {
            if (_apiKeyCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Informe a API Key'),
                    behavior: SnackBarBehavior.floating),
              );
              return;
            }
            setState(() => _currentStep = 2);
          },
          width: double.infinity,
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
    const luaCode =
        '''local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Phoenix DataStore Hook
local function onDataChanged(store, key, value)
  -- Phoenix will automatically detect changes
end''';

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Integração com Luau',
            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
            'Adicione este código ao seu jogo para monitoramento em tempo real',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Script Luau',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: luaCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Código copiado!'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, color: AppColors.primary, size: 14),
                        SizedBox(width: 4),
                        Text('Copiar',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                luaCode,
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PhoenixButton(
          label: 'Finalizar',
          onPressed: _finish,
          isLoading: _isFinishing,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _currentStep = 1),
          child: const Text('← Voltar', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
