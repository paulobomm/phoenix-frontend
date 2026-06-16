import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  final _filters = const {
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

  Future<void> _showDownloadSheet(BuildContext context, SnapshotModel snapshot) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _DownloadSheet(
        snapshot: snapshot,
        isAuto: _isAuto(snapshot),
        formattedDate: _formatDate(snapshot.createdAt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshotsAsync = ref.watch(snapshotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                              onView: () => context.push('/snapshots/${s.id}'),
                              onRestore: () =>
                                  context.push('/snapshots/${s.id}/restore'),
                              onDownload: () =>
                                  _showDownloadSheet(context, s),
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

// ---------------------------------------------------------------------------
// Download bottom sheet
// ---------------------------------------------------------------------------

class _DownloadSheet extends StatefulWidget {
  final SnapshotModel snapshot;
  final bool isAuto;
  final String formattedDate;

  const _DownloadSheet({
    required this.snapshot,
    required this.isAuto,
    required this.formattedDate,
  });

  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet> {
  bool _loading = false;

  Map<String, dynamic> _toMap() => {
        'id': widget.snapshot.id,
        'projectId': widget.snapshot.projectId,
        'scheduleId': widget.snapshot.scheduleId,
        'name': widget.snapshot.name,
        'status': widget.snapshot.status,
        'type': widget.isAuto ? 'automatic' : 'manual',
        'keyCount': widget.snapshot.keyCount,
        'sizeBytes': widget.snapshot.sizeBytes,
        'formattedSize': widget.snapshot.formattedSize,
        'startedAt': widget.snapshot.startedAt?.toIso8601String(),
        'completedAt': widget.snapshot.completedAt?.toIso8601String(),
        'createdAt': widget.snapshot.createdAt.toIso8601String(),
        'error': widget.snapshot.error,
      };

  String _toJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_toMap());
  }

  String _toCsv() {
    final m = _toMap();
    final headers = m.keys.join(',');
    final values = m.values.map((v) {
      final s = (v ?? '').toString();
      return s.contains(',') || s.contains('"') || s.contains('\n')
          ? '"${s.replaceAll('"', '""')}"'
          : s;
    }).join(',');
    return '$headers\n$values';
  }

  Future<void> _download(String format) async {
    setState(() => _loading = true);
    try {
      final content = format == 'json' ? _toJson() : _toCsv();
      final mimeType = format == 'json' ? 'application/json' : 'text/csv';
      final fileName =
          'snapshot_${widget.snapshot.id.substring(0, 8)}_${DateTime.now().millisecondsSinceEpoch}.$format';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);

      if (!mounted) return;
      Navigator.pop(context);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: 'Phoenix Backup - ${widget.snapshot.name}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.download_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Exportar Backup',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.snapshot.name} · ${widget.formattedDate}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ..._formatOptions(),
        ],
      ),
    );
  }

  List<Widget> _formatOptions() => [
        _FormatTile(
          icon: Icons.data_object_rounded,
          label: 'JSON',
          description: 'Formato estruturado, ideal para integração',
          color: const Color(0xFF3b82f6),
          onTap: () => _download('json'),
        ),
        const SizedBox(height: 10),
        _FormatTile(
          icon: Icons.table_chart_rounded,
          label: 'CSV',
          description: 'Planilha compatível com Excel / Google Sheets',
          color: const Color(0xFF22c55e),
          onTap: () => _download('csv'),
        ),
      ];
}

class _FormatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FormatTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Baixar como .$label',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Table
// ---------------------------------------------------------------------------

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
  final VoidCallback onDownload;

  const _BackupRow({
    required this.snapshot,
    required this.isAuto,
    required this.formattedDate,
    required this.onView,
    required this.onRestore,
    required this.onDownload,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAuto
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isAuto ? 'Automático' : 'Manual',
                style: TextStyle(
                  color: isAuto ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              snapshot.formattedSize,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${snapshot.keyCount ?? "—"}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                _IconBtn(Icons.visibility_outlined,
                    AppColors.textSecondary, onView),
                const SizedBox(width: 6),
                _IconBtn(Icons.restore_rounded, AppColors.primary, onRestore),
                const SizedBox(width: 6),
                _IconBtn(
                    Icons.download_outlined, AppColors.primary, onDownload),
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
