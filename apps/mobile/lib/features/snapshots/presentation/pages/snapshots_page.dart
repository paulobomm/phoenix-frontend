import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../games/presentation/widgets/game_selector_widget.dart';
import '../../domain/snapshots_provider.dart';
import '../../data/models/snapshot_model.dart';

class SnapshotsPage extends ConsumerStatefulWidget {
  const SnapshotsPage({super.key});

  @override
  ConsumerState<SnapshotsPage> createState() => _SnapshotsPageState();
}

class _SnapshotsPageState extends ConsumerState<SnapshotsPage> {
  String _filter = 'all';

  final _filters = {
    'all': 'Todos',
    'auto': 'Automático',
    'manual': 'Manual',
    'completed': 'Completos',
    'failed': 'Falhos',
  };

  bool _isAuto(SnapshotModel s) => s.name.toLowerCase().contains('auto');

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final snapshotsAsync = ref.watch(snapshotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Backups',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list_rounded,
                        color: AppColors.textSecondary),
                    tooltip: 'Filtrar',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const GameSelectorWidget(),
            // Filter pills
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
              child: snapshotsAsync.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SkeletonCard(),
                  ),
                ),
                error: (e, _) => Center(
                    child: Text('Erro: $e',
                        style: const TextStyle(color: AppColors.error))),
                data: (snapshots) {
                  final filtered = snapshots.where((s) {
                    if (_filter == 'auto') return _isAuto(s);
                    if (_filter == 'manual') return !_isAuto(s);
                    if (_filter == 'completed') return s.status == 'completed';
                    if (_filter == 'failed') return s.status == 'failed';
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.backup_rounded,
                      title: 'Nenhum backup encontrado',
                      description:
                          'Execute um backup para começar a proteger seus dados',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.invalidate(snapshotsProvider),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _TableHeader(),
                        const SizedBox(height: 4),
                        ...filtered.map((s) => _BackupRow(
                              snapshot: s,
                              isAuto: _isAuto(s),
                              formattedDate: _formatDate(s.createdAt),
                              onView: () =>
                                  context.push('/snapshots/${s.id}'),
                              onRestore: () =>
                                  context.push('/snapshots/${s.id}/restore'),
                            )),
                        const SizedBox(height: 16),
                      ],
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

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell('DATA')),
          Expanded(flex: 2, child: _HeaderCell('TIPO')),
          Expanded(flex: 2, child: _HeaderCell('TAMANHO')),
          Expanded(flex: 1, child: _HeaderCell('KEYS')),
          Expanded(flex: 2, child: _HeaderCell('STATUS')),
          SizedBox(width: 72, child: _HeaderCell('AÇÕES')),
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

class _BackupRow extends StatelessWidget {
  final SnapshotModel snapshot;
  final bool isAuto;
  final String formattedDate;
  final VoidCallback onView;
  final VoidCallback onRestore;

  const _BackupRow({
    required this.snapshot,
    required this.isAuto,
    required this.formattedDate,
    required this.onView,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final status = snapshot.status;
    final isComplete = status == 'completed';
    final isFailed = status == 'failed';
    final isRunning = status == 'running' || status == 'pending';

    Color statusColor;
    String statusLabel;
    if (isComplete) {
      statusColor = AppColors.success;
      statusLabel = 'Completo';
    } else if (isFailed) {
      statusColor = AppColors.error;
      statusLabel = 'Falhou';
    } else if (isRunning) {
      statusColor = AppColors.warning;
      statusLabel = 'Em progresso';
    } else {
      statusColor = AppColors.textSecondary;
      statusLabel = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              formattedDate,
              style: const TextStyle(color: AppColors.text, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAuto
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isAuto ? 'Automático' : 'Manual',
                style: TextStyle(
                  color:
                      isAuto ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              '—',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${snapshot.keyCount}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconBtn(Icons.visibility_outlined, AppColors.textSecondary,
                    onView),
                const SizedBox(width: 6),
                _IconBtn(Icons.restore_rounded, AppColors.primary, onRestore),
                const SizedBox(width: 6),
                _IconBtn(Icons.download_outlined, AppColors.textSecondary,
                    () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 16, color: color),
    );
  }
}
