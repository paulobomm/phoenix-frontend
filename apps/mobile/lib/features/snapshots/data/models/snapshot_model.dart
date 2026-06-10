class SnapshotModel {
  final String id;
  final String projectId;
  final String? scheduleId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? error;
  final DateTime createdAt;

  const SnapshotModel({
    required this.id,
    required this.projectId,
    this.scheduleId,
    required this.status,
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
