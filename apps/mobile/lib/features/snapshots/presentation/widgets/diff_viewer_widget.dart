import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DiffViewerWidget extends StatelessWidget {
  final List<String> addedKeys;
  final List<String> removedKeys;
  final List<String> modifiedKeys;

  const DiffViewerWidget({
    super.key,
    required this.addedKeys,
    required this.removedKeys,
    required this.modifiedKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addedKeys.isNotEmpty) ...[
          _SectionHeader(
            label: '${addedKeys.length} Adicionadas',
            color: AppColors.success,
            icon: Icons.add_circle_outline_rounded,
          ),
          const SizedBox(height: 8),
          ...addedKeys.map((k) => _DiffRow(key_: k, type: 'added')),
          const SizedBox(height: 16),
        ],
        if (removedKeys.isNotEmpty) ...[
          _SectionHeader(
            label: '${removedKeys.length} Removidas',
            color: AppColors.error,
            icon: Icons.remove_circle_outline_rounded,
          ),
          const SizedBox(height: 8),
          ...removedKeys.map((k) => _DiffRow(key_: k, type: 'removed')),
          const SizedBox(height: 16),
        ],
        if (modifiedKeys.isNotEmpty) ...[
          _SectionHeader(
            label: '${modifiedKeys.length} Modificadas',
            color: AppColors.warning,
            icon: Icons.edit_outlined,
          ),
          const SizedBox(height: 8),
          ...modifiedKeys.map((k) => _DiffRow(key_: k, type: 'modified')),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SectionHeader({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DiffRow extends StatelessWidget {
  final String key_;
  final String type;

  const _DiffRow({required this.key_, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    String prefix;
    switch (type) {
      case 'added':
        color = AppColors.success;
        prefix = '+';
        break;
      case 'removed':
        color = AppColors.error;
        prefix = '-';
        break;
      default:
        color = AppColors.warning;
        prefix = '~';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(prefix, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(key_, style: const TextStyle(color: AppColors.text, fontFamily: 'monospace', fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
