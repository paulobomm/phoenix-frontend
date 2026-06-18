import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../audit/domain/audit_provider.dart';
import '../../../games/domain/games_provider.dart';
import '../../domain/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/backup_chart_widget.dart';
import '../widgets/insights_widget.dart';
import '../widgets/recent_activity_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final chartAsync = ref.watch(chartDataProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final logsAsync = ref.watch(logsProvider);

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
                        Text('Dashboard', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w700)),
                        Text('Visão geral da plataforma', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 20),
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
                    const SizedBox(height: 4),
                    statsAsync.when(
                      loading: () => const Column(
                        children: [
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
                        ],
                      ),
                      error: (e, _) => Text('Erro: $e', style: const TextStyle(color: AppColors.error)),
                      data: (stats) => Column(
                        children: [
                          Row(children: [
                            Expanded(child: StatsCard(
                              title: 'Total de Jogos',
                              value: '${gamesAsync.valueOrNull?.length ?? stats.totalGames}',
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
                              value: '${stats.storageUsedGb} GB',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    chartAsync.when(
                      loading: () => const SkeletonCard(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (points) => BackupChartWidget(points: points),
                    ),
                    const SizedBox(height: 16),
                    insightsAsync.when(
                      loading: () => const SkeletonCard(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (insights) => insights.isEmpty ? const SizedBox.shrink() : InsightsWidget(insights: insights),
                    ),
                    const SizedBox(height: 16),
                    RecentActivityWidget(
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
