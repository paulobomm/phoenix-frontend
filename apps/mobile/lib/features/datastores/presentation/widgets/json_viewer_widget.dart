import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class JsonViewerWidget extends StatefulWidget {
  final dynamic data;
  final int indent;

  const JsonViewerWidget({super.key, required this.data, this.indent = 0});

  @override
  State<JsonViewerWidget> createState() => _JsonViewerWidgetState();
}

class _JsonViewerWidgetState extends State<JsonViewerWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final indentStr = '  ' * widget.indent;

    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.indent > 0)
                  Text(indentStr, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace', fontSize: 13)),
                Icon(
                  _expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  color: AppColors.typeObject,
                  size: 16,
                ),
                Text(
                  _expanded ? '{' : '{ ... }',
                  style: const TextStyle(color: AppColors.typeObject, fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (_expanded)
            ...data.entries.map((entry) => Padding(
              padding: EdgeInsets.only(left: 16.0 * (widget.indent + 1)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${entry.key}": ', style: const TextStyle(color: AppColors.typeString, fontFamily: 'monospace', fontSize: 13)),
                  Expanded(
                    child: JsonValueWidget(value: entry.value, indent: widget.indent + 1),
                  ),
                ],
              ),
            )),
          if (_expanded)
            Text('$indentStr}', style: const TextStyle(color: AppColors.typeObject, fontFamily: 'monospace', fontSize: 13)),
        ],
      );
    }

    return JsonValueWidget(value: data, indent: widget.indent);
  }
}

class JsonValueWidget extends StatefulWidget {
  final dynamic value;
  final int indent;

  const JsonValueWidget({super.key, required this.value, this.indent = 0});

  @override
  State<JsonValueWidget> createState() => _JsonValueWidgetState();
}

class _JsonValueWidgetState extends State<JsonValueWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final indentStr = '  ' * widget.indent;

    if (value is String) {
      return Text('"$value"', style: const TextStyle(color: AppColors.typeString, fontFamily: 'monospace', fontSize: 13));
    }
    if (value is num) {
      return Text('$value', style: const TextStyle(color: AppColors.typeNumber, fontFamily: 'monospace', fontSize: 13));
    }
    if (value is bool) {
      return Text('$value', style: const TextStyle(color: AppColors.typeBoolean, fontFamily: 'monospace', fontSize: 13));
    }
    if (value == null) {
      return const Text('null', style: TextStyle(color: AppColors.typeNull, fontFamily: 'monospace', fontSize: 13));
    }
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  color: AppColors.typeArray,
                  size: 16,
                ),
                Text(
                  _expanded ? '[ ${value.length} items' : '[ ... ]',
                  style: const TextStyle(color: AppColors.typeArray, fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
          if (_expanded)
            ...value.asMap().entries.map((e) => Padding(
              padding: EdgeInsets.only(left: 16.0 * (widget.indent + 1)),
              child: Row(
                children: [
                  Text('${e.key}: ', style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'monospace', fontSize: 12)),
                  Expanded(child: JsonValueWidget(value: e.value, indent: widget.indent + 1)),
                ],
              ),
            )),
          if (_expanded)
            Text('$indentStr]', style: const TextStyle(color: AppColors.typeArray, fontFamily: 'monospace', fontSize: 13)),
        ],
      );
    }
    if (value is Map) {
      return JsonViewerWidget(data: value, indent: widget.indent);
    }
    return Text('$value', style: const TextStyle(color: AppColors.text, fontFamily: 'monospace', fontSize: 13));
  }
}
