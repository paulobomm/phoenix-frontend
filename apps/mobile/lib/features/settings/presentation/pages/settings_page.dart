import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';
import '../../../../shared/widgets/phoenix_text_field.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../domain/plan_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _selectedTab = 0;

  static const _tabs = [
    (Icons.person_outline_rounded, 'Perfil'),
    (Icons.lock_outline_rounded, 'Segurança'),
    (Icons.notifications_none_rounded, 'Notificações'),
    (Icons.key_rounded, 'API'),
    (Icons.star_outline_rounded, 'Plano'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Configurações',
                            style: TextStyle(
                                color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Gerencie sua conta Phoenix',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(authProvider.notifier).logout(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.error, size: 16),
                          SizedBox(width: 6),
                          Text('Sair',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isWide ? _WideLayout(selectedTab: _selectedTab, onTabChanged: (i) => setState(() => _selectedTab = i)) : _NarrowLayout(selectedTab: _selectedTab, onTabChanged: (i) => setState(() => _selectedTab = i)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _WideLayout({required this.selectedTab, required this.onTabChanged});

  static const _tabs = [
    (Icons.person_outline_rounded, 'Perfil'),
    (Icons.lock_outline_rounded, 'Segurança'),
    (Icons.notifications_none_rounded, 'Notificações'),
    (Icons.key_rounded, 'API'),
    (Icons.star_outline_rounded, 'Plano'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          margin: const EdgeInsets.only(left: 16, bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(_tabs.length, (i) {
              final isActive = i == selectedTab;
              return GestureDetector(
                onTap: () => onTabChanged(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_tabs[i].$1,
                          size: 17,
                          color: isActive ? AppColors.primary : AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(_tabs[i].$2,
                          style: TextStyle(
                            color: isActive ? AppColors.primary : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _tabContent(selectedTab),
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const _NarrowLayout({required this.selectedTab, required this.onTabChanged});

  static const _tabs = [
    (Icons.person_outline_rounded, 'Perfil'),
    (Icons.lock_outline_rounded, 'Segurança'),
    (Icons.notifications_none_rounded, 'Notificações'),
    (Icons.key_rounded, 'API'),
    (Icons.star_outline_rounded, 'Plano'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (_, i) {
              final isActive = i == selectedTab;
              return GestureDetector(
                onTap: () => onTabChanged(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(
                    _tabs[i].$2,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _tabContent(selectedTab),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

Widget _tabContent(int index) {
  switch (index) {
    case 0:
      return const _ProfileTab();
    case 1:
      return const _SecurityTab();
    case 2:
      return const _NotificationsTab();
    case 3:
      return const _ApiTab();
    case 4:
      return const _PlanTab();
    default:
      return const _ProfileTab();
  }
}

class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();

  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  final _nameCtrl = TextEditingController(text: 'Paulo Roberto');
  final _emailCtrl = TextEditingController(text: 'paulobomm@gmail.com');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 40),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Plano Pro',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 24),
        PhoenixTextField(label: 'Nome', controller: _nameCtrl),
        const SizedBox(height: 16),
        PhoenixTextField(label: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 24),
        PhoenixButton(
          label: 'Salvar Alterações',
          isLoading: _saving,
          onPressed: () async {
            setState(() => _saving = true);
            await Future.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil atualizado!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          width: double.infinity,
        ),
      ],
    );
  }
}

class _SecurityTab extends StatefulWidget {
  const _SecurityTab();

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Alterar Senha',
            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        PhoenixTextField(label: 'Senha Atual', controller: _currentCtrl, obscureText: true),
        const SizedBox(height: 16),
        PhoenixTextField(label: 'Nova Senha', controller: _newCtrl, obscureText: true),
        const SizedBox(height: 16),
        PhoenixTextField(label: 'Confirmar Nova Senha', controller: _confirmCtrl, obscureText: true),
        const SizedBox(height: 24),
        PhoenixButton(
          label: 'Alterar Senha',
          isLoading: _saving,
          onPressed: () async {
            setState(() => _saving = true);
            await Future.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Senha alterada com sucesso!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          width: double.infinity,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Autenticação de 2 Fatores',
                        style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Adicione uma camada extra de segurança',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Desativado',
                    style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab();

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _backupSuccess = true;
  bool _backupFailed = true;
  bool _corruptionAlert = true;
  bool _storageWarning = true;
  bool _emailNotif = true;
  bool _pushNotif = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Alertas',
            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _SwitchTile(
            label: 'Backup concluído',
            subtitle: 'Notificar quando backups terminarem',
            value: _backupSuccess,
            onChanged: (v) => setState(() => _backupSuccess = v)),
        _SwitchTile(
            label: 'Backup falhou',
            subtitle: 'Alertar sobre backups com erro',
            value: _backupFailed,
            onChanged: (v) => setState(() => _backupFailed = v)),
        _SwitchTile(
            label: 'Corrupção detectada',
            subtitle: 'Alertas de integridade de dados',
            value: _corruptionAlert,
            onChanged: (v) => setState(() => _corruptionAlert = v)),
        _SwitchTile(
            label: 'Aviso de storage',
            subtitle: 'Quando armazenamento estiver quase cheio',
            value: _storageWarning,
            onChanged: (v) => setState(() => _storageWarning = v)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.border),
        const SizedBox(height: 8),
        const Text('Canais',
            style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _SwitchTile(
            label: 'Email',
            subtitle: 'Receber notificações por email',
            value: _emailNotif,
            onChanged: (v) => setState(() => _emailNotif = v)),
        _SwitchTile(
            label: 'Push',
            subtitle: 'Notificações push no celular',
            value: _pushNotif,
            onChanged: (v) => setState(() => _pushNotif = v)),
      ],
    );
  }
}

class _ApiTab extends StatefulWidget {
  const _ApiTab();

  @override
  State<_ApiTab> createState() => _ApiTabState();
}

class _ApiTabState extends State<_ApiTab> {
  bool _obscureKey = true;
  bool _generating = false;
  static const _apiKey = 'rbxp_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('API Key Pessoal',
            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Use esta chave para integrar com o Phoenix API',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _obscureKey ? '••••••••••••••••••••••••••••••••' : _apiKey,
                  style: const TextStyle(
                      color: AppColors.text, fontSize: 12, fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _obscureKey = !_obscureKey),
                child: Icon(
                  _obscureKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chave copiada!'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: const Text('Copiar',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nunca compartilhe sua API Key. Qualquer pessoa com acesso a ela pode gerenciar seus jogos.',
                  style: TextStyle(color: AppColors.warning, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PhoenixButton(
          label: 'Gerar nova key',
          isLoading: _generating,
          onPressed: () async {
            setState(() => _generating = true);
            await Future.delayed(const Duration(milliseconds: 1000));
            if (!mounted) return;
            setState(() => _generating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nova API Key gerada!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error, width: 0.8),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Revogar key'),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _PlanTab extends ConsumerWidget {
  const _PlanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(planUsageProvider);
    return usageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Erro ao carregar plano: $e', style: const TextStyle(color: AppColors.error))),
      data: (usage) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PlanCurrentCard(usage: usage),
          const SizedBox(height: 16),
          _PlanUsageCard(usage: usage),
          const SizedBox(height: 16),
          const _PlanUpgradeSection(),
          const SizedBox(height: 16),
          const _PlanInvoiceTable(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlanCurrentCard extends StatelessWidget {
  final PlanUsage usage;
  const _PlanCurrentCard({required this.usage});

  String _planPrice(String planName) {
    switch (planName.toLowerCase()) {
      case 'pro': return 'R\$ 29,00 / mês';
      case 'studio': return 'R\$ 99,00 / mês';
      default: return 'Gratuito';
    }
  }

  @override
  Widget build(BuildContext context) {
    final limits = usage.limits;
    final planName = limits.planName;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.18), AppColors.primary.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planName, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(_planPrice(planName), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Text('ATIVO', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PlanBar(
            label: 'Storage',
            used: usage.storageUsedGb,
            total: limits.maxStorageGb,
            unit: 'GB',
          ),
          const SizedBox(height: 10),
          _PlanBar(
            label: 'Jogos',
            used: usage.gamesUsed.toDouble(),
            total: limits.maxGames.toDouble(),
            unit: '',
          ),
          const SizedBox(height: 10),
          _PlanBar(
            label: 'Backups este mês',
            used: usage.backupsThisMonth.toDouble(),
            total: limits.maxBackupsPerMonth.toDouble(),
            unit: '',
          ),
        ],
      ),
    );
  }
}

class _PlanBar extends StatelessWidget {
  final String label;
  final double used;
  final double total;
  final String unit;
  const _PlanBar({required this.label, required this.used, required this.total, required this.unit});

  @override
  Widget build(BuildContext context) {
    final ratio = (used / total).clamp(0.0, 1.0);
    final color = ratio > 0.7 ? AppColors.warning : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.text, fontSize: 12)),
            Text(
              unit.isEmpty ? '${used.toInt()} / ${total.toInt()}' : '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(0)} $unit',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _PlanUsageCard extends StatelessWidget {
  final PlanUsage usage;
  const _PlanUsageCard({required this.usage});

  String _formatStorage(double gb) {
    if (gb < 0.001) return '0 / ${usage.limits.maxStorageGb.toStringAsFixed(0)} GB';
    if (gb < 1) return '${(gb * 1024).toStringAsFixed(0)} MB / ${usage.limits.maxStorageGb.toStringAsFixed(0)} GB';
    return '${gb.toStringAsFixed(2)} / ${usage.limits.maxStorageGb.toStringAsFixed(0)} GB';
  }

  String _formatKeys(int keys) {
    if (keys >= 1000000) return '${(keys / 1000000).toStringAsFixed(1)}M';
    if (keys >= 1000) {
      final thousands = keys ~/ 1000;
      final remainder = (keys % 1000).toString().padLeft(3, '0');
      return '$thousands.$remainder';
    }
    return '$keys';
  }

  @override
  Widget build(BuildContext context) {
    final limits = usage.limits;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Uso Atual', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _PlanStat('Jogos conectados', '${usage.gamesUsed} / ${limits.maxGames}', AppColors.primary),
          const SizedBox(height: 12),
          _PlanStat('Storage utilizado', _formatStorage(usage.storageUsedGb), AppColors.warning),
          const SizedBox(height: 12),
          _PlanStat('Backups este mês', '${usage.backupsThisMonth} / ${limits.maxBackupsPerMonth}', AppColors.success),
          const SizedBox(height: 12),
          _PlanStat('Keys protegidas', _formatKeys(usage.totalKeys), AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PlanStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PlanStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PlanUpgradeSection extends StatelessWidget {
  const _PlanUpgradeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fazer Upgrade', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Desbloqueie recursos avançados com o plano Studio',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Color(0xFFA78BFA), size: 20),
                    SizedBox(width: 8),
                    Text('Studio', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 16, fontWeight: FontWeight.w800)),
                    Spacer(),
                    Text('R\$ 99/mês', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...['Jogos ilimitados', '500 GB storage', 'Backups ilimitados', 'Sync em tempo real', 'API personalizada', 'SLA garantido'].map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded, color: Color(0xFFA78BFA), size: 14),
                        const SizedBox(width: 8),
                        Text(f, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PhoenixButton(
                  label: 'Fazer Upgrade para Studio',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upgrade em breve!'), behavior: SnackBarBehavior.floating),
                  ),
                  backgroundColor: const Color(0xFFA78BFA),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanInvoiceTable extends StatelessWidget {
  const _PlanInvoiceTable();

  static const _invoices = [
    ('Mai 2026', 'R\$ 29,00', 'Pago'),
    ('Abr 2026', 'R\$ 29,00', 'Pago'),
    ('Mar 2026', 'R\$ 29,00', 'Pago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Histórico de Faturas', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          ..._invoices.map((inv) => Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_outlined, color: AppColors.textSecondary, size: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(inv.$1, style: const TextStyle(color: AppColors.text, fontSize: 13))),
                Text(inv.$2, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(inv.$3, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Icon(Icons.download_outlined, color: AppColors.primary, size: 15),
                      SizedBox(width: 4),
                      Text('PDF', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
