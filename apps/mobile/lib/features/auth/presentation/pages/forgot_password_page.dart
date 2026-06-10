import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../../../shared/widgets/phoenix_text_field.dart';
import '../../domain/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
    if (mounted) {
      setState(() => _success = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recuperar Senha'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _success ? _buildSuccess() : _buildForm(authState.isLoading),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 20),
          const Text(
            'Esqueceu sua senha?',
            style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Digite seu email e enviaremos um link para redefinir sua senha.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          PhoenixTextField(
            label: 'Email',
            hint: 'seu@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email obrigatório';
              if (!v.contains('@')) return 'Email inválido';
              return null;
            },
          ),
          const SizedBox(height: 24),
          PhoenixButton(
            label: 'Enviar Link',
            onPressed: _handleSend,
            isLoading: isLoading,
            width: double.infinity,
            icon: Icons.send_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3), width: 2),
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Enviado!',
          style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos um link para ${_emailController.text}\nVerifique sua caixa de entrada.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PhoenixButton(
          label: 'Voltar ao Login',
          onPressed: () => context.go('/auth/login'),
          width: double.infinity,
        ),
      ],
    );
  }
}
