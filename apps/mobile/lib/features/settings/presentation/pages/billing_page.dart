import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/phoenix_button.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (!isWide && Navigator.of(context).canPop())
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plano & Faturamento',
                            style: TextStyle(
                                color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Gerencie seu plano e histórico de pagamentos',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isWide
                  ? _WideLayout()
                  : _NarrowLayout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.only(left: 20, right: 10, bottom: 20),
            children: const [
              _CurrentPlanCard(),
              SizedBox(height: 16),
              _UpgradeSection(),
              SizedBox(height: 16),
              _InvoiceTable(),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.only(left: 10, right: 20, bottom: 20),
            children: const [
              _UsageCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: const [
        _CurrentPlanCard(),
        SizedBox(height: 16),
        _UsageCard(),
        SizedBox(height: 16),
        _UpgradeSection(),
        SizedBox(height: 16),
        _InvoiceTable(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard();

  @override
  Widget build(BuildContext context) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pro',
                        style: TextStyle(
                            color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('R\$ 29,00 / mês',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                child: const Text('ATIVO',
                    style: TextStyle(
                        color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _PlanProgress(label: 'Storage', used: 8.5, total: 50, unit: 'GB'),
          const SizedBox(height: 10),
          const _PlanProgress(label: 'Jogos', used: 3, total: 10, unit: ''),
          const SizedBox(height: 10),
          const _PlanProgress(label: 'Backups este mês', used: 47, total: 500, unit: ''),
          const SizedBox(height: 16),
          const Text('Válido até 15/02/2026',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _PlanProgress extends StatelessWidget {
  final String label;
  final double used;
  final double total;
  final String unit;

  const _PlanProgress({
    required this.label,
    required this.used,
    required this.total,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (used / total).clamp(0.0, 1.0);
    final isWarning = ratio > 0.7;
    final color = isWarning ? AppColors.warning : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.text, fontSize: 12)),
            Text(
              unit.isEmpty
                  ? '${used.toInt()} / ${total.toInt()}'
                  : '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(0)} $unit',
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

class _UsageCard extends StatelessWidget {
  const _UsageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uso Atual',
              style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          _UsageStat('Jogos conectados', '3 / 10', AppColors.primary),
          SizedBox(height: 12),
          _UsageStat('Storage utilizado', '8.5 / 50 GB', AppColors.warning),
          SizedBox(height: 12),
          _UsageStat('Backups este mês', '47 / 500', AppColors.success),
          SizedBox(height: 12),
          _UsageStat('Keys protegidas', '4.269', AppColors.textSecondary),
          SizedBox(height: 12),
          _UsageStat('Dados protegidos', '8.5 MB', AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _UsageStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _UpgradeSection extends StatelessWidget {
  const _UpgradeSection();

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
          const Text('Fazer Upgrade',
              style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
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
                    Text('Studio',
                        style: TextStyle(
                            color: Color(0xFFA78BFA),
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Spacer(),
                    Text('R\$ 99/mês',
                        style: TextStyle(
                            color: Color(0xFFA78BFA),
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ...[
                  'Jogos ilimitados',
                  '500 GB storage',
                  'Backups ilimitados',
                  'Sync em tempo real',
                  'API personalizada',
                  'SLA garantido + Gerente dedicado',
                ].map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_rounded,
                              color: Color(0xFFA78BFA), size: 14),
                          const SizedBox(width: 8),
                          Text(f,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                PhoenixButton(
                  label: 'Fazer Upgrade para Studio',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upgrade em breve!'),
                      behavior: SnackBarBehavior.floating,
                    ),
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

class _InvoiceTable extends StatelessWidget {
  const _InvoiceTable();

  static const _invoices = [
    ('Mai 2026', 'R\$ 29,00', 'Pago'),
    ('Abr 2026', 'R\$ 29,00', 'Pago'),
    ('Mar 2026', 'R\$ 29,00', 'Pago'),
    ('Fev 2026', 'R\$ 29,00', 'Pago'),
    ('Jan 2026', 'R\$ 29,00', 'Pago'),
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
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('Histórico de Faturas',
                style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderCell('DATA')),
                Expanded(flex: 2, child: _HeaderCell('VALOR')),
                Expanded(flex: 2, child: _HeaderCell('STATUS')),
                Expanded(flex: 2, child: _HeaderCell('AÇÃO')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._invoices.map(
            (inv) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_outlined,
                            color: AppColors.textSecondary, size: 15),
                        const SizedBox(width: 8),
                        Text(inv.$1,
                            style: const TextStyle(color: AppColors.text, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(inv.$2,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(inv.$3,
                          style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Row(
                        children: [
                          Icon(Icons.download_outlined,
                              color: AppColors.primary, size: 15),
                          SizedBox(width: 4),
                          Text('PDF',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
