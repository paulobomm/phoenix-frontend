class SnapshotModel {
  final String id;
  final String projectId;
  final String? scheduleId;
  final String status;
  final String? snapshotName;
  final int? keyCount;
  final int? sizeBytes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? error;
  final DateTime createdAt;

  const SnapshotModel({
    required this.id,
    required this.projectId,
    this.scheduleId,
    required this.status,
    this.snapshotName,
    this.keyCount,
    this.sizeBytes,
    this.startedAt,
    this.completedAt,
    this.error,
    required this.createdAt,
  });

  factory SnapshotModel.fromJson(Map<String, dynamic> json) {
    return SnapshotModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? '',
      scheduleId: json['scheduleId'] as String?,
      status: json['status'] as String? ?? 'pending',
      snapshotName: json['name'] as String?,
      keyCount: (json['keyCount'] as num?)?.toInt(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get name =>
      snapshotName ??
      (scheduleId != null ? 'Backup Automático' : 'Backup Manual');

  String get formattedSize {
    final bytes = sizeBytes;
    if (bytes == null) return '—';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  String get formattedDuration {
    if (startedAt == null || completedAt == null) return '—';
    final seconds = completedAt!.difference(startedAt!).inSeconds;
    return '${seconds}s';
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isRunning => status == 'running';
}

class SnapshotScheduleModel {
  final String id;
  final String projectId;
  final String cronExpr;
  final bool enabled;
  final DateTime createdAt;

  const SnapshotScheduleModel({
    required this.id,
    required this.projectId,
    required this.cronExpr,
    required this.enabled,
    required this.createdAt,
  });

  factory SnapshotScheduleModel.fromJson(Map<String, dynamic> json) {
    return SnapshotScheduleModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? '',
      cronExpr: json['cronExpr'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
