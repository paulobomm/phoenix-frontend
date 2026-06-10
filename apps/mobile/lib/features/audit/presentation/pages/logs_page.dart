import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../data/models/log_model.dart';
import '../../domain/audit_provider.dart';

class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  String _filter = 'all';

  final _filters = const {
    'all': 'Todos',
    'backup': 'Backup',
    'restore': 'Restore',
    'error': 'Erros',
    'warning': 'Avisos',
  };

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsProvider);

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Histórico',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Registro de todas as atividades',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _filters.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _filter == e.key
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _filter == e.key
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: _filter == e.key
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: logsAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 8,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SkeletonCard(),
                  ),
                ),
                error: (e, _) => Center(
                    child: Text('Erro: $e',
                        style: const TextStyle(color: AppColors.error))),
                data: (logs) {
                  var filtered = logs;
                  if (_filter == 'error') {
                    filtered = logs
                        .where((l) =>
                            l.eventType.contains('failed') ||
                            l.eventType.contains('error'))
                        .toList();
                  } else if (_filter == 'warning') {
                    filtered = logs
                        .where((l) => l.eventType.contains('warning'))
                        .toList();
                  } else if (_filter == 'backup') {
                    filtered = logs
                        .where((l) =>
                            l.routingKey.contains('snapshot') ||
                            l.eventType.contains('snapshot'))
                        .toList();
                  } else if (_filter == 'restore') {
                    filtered = logs
                        .where((l) =>
                            l.routingKey.contains('restore') ||
                            l.eventType.contains('restore'))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.history_rounded,
                      title: 'Nenhum evento registrado',
                      description: 'As atividades aparecerão aqui',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(logsProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final log = filtered[i];
                        final isLast = i == filtered.length - 1;
                        return _TimelineItem(log: log, isLast: isLast);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final LogModel log;
  final bool isLast;

  const _TimelineItem({required this.log, required this.isLast});

  _LogMeta _getMeta() {
    final rk = log.routingKey.toLowerCase();
    final et = log.eventType.toLowerCase();

    if (rk.contains('snapshot') || et.contains('snapshot')) {
      return const _LogMeta(
        icon: Icons.cloud_upload_outlined,
        dotColor: AppColors.primary,
        iconColor: AppColors.primary,
        badge: 'Backup',
        badgeColor: AppColors.primary,
      );
    }
    if (rk.contains('restore') || et.contains('restore')) {
      return const _LogMeta(
        icon: Icons.restore_rounded,
        dotColor: AppColors.warning,
        iconColor: AppColors.warning,
        badge: 'Restore',
        badgeColor: AppColors.warning,
      );
    }
    if (et.contains('failed') || et.contains('error')) {
      return const _LogMeta(
        icon: Icons.error_outline_rounded,
        dotColor: AppColors.error,
        iconColor: AppColors.error,
        badge: 'Erro',
        badgeColor: AppColors.error,
      );
    }
    return const _LogMeta(
      icon: Icons.info_outline_rounded,
      dotColor: AppColors.textSecondary,
      iconColor: AppColors.textSecondary,
      badge: 'Info',
      badgeColor: AppColors.textSecondary,
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays}d';
  }

  String _formatTitle(String eventType) {
    return eventType
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getMeta();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: meta.dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: meta.dotColor.withValues(alpha: 0.4),
                          blurRadius: 6)
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: meta.iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(meta.icon, color: meta.iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTitle(log.eventType),
                          style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${log.exchange} · ${log.routingKey}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(log.occurredAt),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: meta.badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: meta.badgeColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      meta.badge,
                      style: TextStyle(
                          color: meta.badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogMeta {
  final IconData icon;
  final Color dotColor;
  final Color iconColor;
  final String badge;
  final Color badgeColor;

  const _LogMeta({
    required this.icon,
    required this.dotColor,
    required this.iconColor,
    required this.badge,
    required this.badgeColor,
  });
}
