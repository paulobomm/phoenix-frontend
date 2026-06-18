import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../audit/domain/audit_provider.dart';
import '../../../audit/data/models/log_model.dart';
import '../../../games/domain/games_provider.dart';
import '../../domain/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/backup_chart_widget.dart';
import '../widgets/insights_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final chartAsync = ref.watch(chartDataProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final logsAsync = ref.watch(logsProvider);
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        Text('Visão geral da plataforma',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/phoenix_logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.card,
                onRefresh: () async {
                  ref.invalidate(dashboardStatsProvider);
                  ref.invalidate(chartDataProvider);
                  ref.invalidate(insightsProvider);
                  ref.invalidate(logsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // --- Stats cards ---
                    statsAsync.when(
                      loading: () => const Column(children: [
                        Row(children: [
                          Expanded(child: SkeletonCard()),
                          SizedBox(width: 8),
                          Expanded(child: SkeletonCard()),
                        ]),
                        SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: SkeletonCard()),
                          SizedBox(width: 8),
                          Expanded(child: SkeletonCard()),
                        ]),
                      ]),
                      error: (e, _) => Text('Erro: $e',
                          style: const TextStyle(color: AppColors.error)),
                      data: (stats) {
                        final gameCount = gamesAsync.valueOrNull?.length ?? stats.totalGames;
                        return Column(children: [
                          Row(children: [
                            Expanded(child: StatsCard(
                              title: 'Total de Jogos',
                              value: '$gameCount',
                              icon: Icons.videogame_asset_rounded,
                              iconColor: AppColors.primary,
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: StatsCard(
                              title: 'Total de Backups',
                              value: '${stats.totalBackups}',
                              icon: Icons.cloud_done_rounded,
                              iconColor: const Color(0xFF60A5FA),
                            )),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(child: StatsCard(
                              title: 'Storage Usado',
                              value: '${stats.storageUsedGb.toStringAsFixed(1)} GB',
                              subtitle: 'de 50 GB',
                              icon: Icons.storage_rounded,
                              iconColor: AppColors.warning,
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: StatsCard(
                              title: 'Taxa de Sucesso',
                              value: '${stats.successRate.toStringAsFixed(0)}%',
                              subtitle: 'últimos 30 dias',
                              icon: Icons.verified_rounded,
                              iconColor: AppColors.success,
                              valueColor: AppColors.success,
                            )),
                          ]),
                        ]);
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Backup chart ---
                    chartAsync.when(
                      loading: () => const SkeletonCard(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (points) => BackupChartWidget(points: points),
                    ),
                    const SizedBox(height: 16),

                    // --- Insights ---
                    insightsAsync.when(
                      loading: () => const SkeletonCard(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (insights) => InsightsWidget(insights: insights),
                    ),
                    const SizedBox(height: 16),

                    // --- Atividade Recente ---
                    _RecentActivity(
                      logs: logsAsync.valueOrNull?.take(5).toList() ?? [],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Atividade Recente
// ---------------------------------------------------------------------------

class _RecentActivity extends StatelessWidget {
  final List<LogModel> logs;
  const _RecentActivity({required this.logs});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  Color _dotColor(LogModel log) {
    final key = log.routingKey.toLowerCase();
    if (key.contains('fail') || key.contains('error') || key.contains('corrupt')) {
      return AppColors.error;
    }
    if (key.contains('warn') || key.contains('anomal') || key.contains('excess')) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  IconData _icon(LogModel log) {
    final key = log.routingKey.toLowerCase();
    if (key.contains('fail') || key.contains('error') || key.contains('corrupt')) {
      return Icons.cancel_outlined;
    }
    if (key.contains('warn') || key.contains('anomal') || key.contains('excess')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text('Atividade Recente',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < logs.length; i++) ...
                [
                  _LogTile(log: logs[i], dotColor: _dotColor(logs[i]), icon: _icon(logs[i]), timeAgo: _timeAgo(logs[i].occurredAt)),
                  if (i < logs.length - 1)
                    const Divider(height: 1, color: AppColors.border, indent: 14, endIndent: 14),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogModel log;
  final Color dotColor;
  final IconData icon;
  final String timeAgo;

  const _LogTile({
    required this.log,
    required this.dotColor,
    required this.icon,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: dotColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.eventType,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  log.exchange.isNotEmpty ? log.exchange : log.routingKey,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeAgo,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
