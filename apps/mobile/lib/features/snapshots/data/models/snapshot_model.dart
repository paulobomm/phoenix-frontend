class SnapshotModel {
  final String id;
  final String name;
  final String status;
  final int keyCount;
  final int sizeBytes;
  final int durationMs;
  final DateTime createdAt;
  final String gameId;
  final String? datastoreId;

  const SnapshotModel({
    required this.id,
    required this.name,
    required this.status,
    required this.keyCount,
    required this.sizeBytes,
    required this.durationMs,
    required this.createdAt,
    this.gameId = '',
    this.datastoreId,
  });

  factory SnapshotModel.fromJson(Map<String, dynamic> json) {
    return SnapshotModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Snapshot',
      status: json['status'] as String? ?? 'pending',
      keyCount: json['keyCount'] as int? ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      durationMs: json['durationMs'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      gameId: json['gameId'] as String? ?? '',
      datastoreId: json['datastoreId'] as String?,
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDuration {
    if (durationMs < 1000) return '${durationMs}ms';
    return '${(durationMs / 1000).toStringAsFixed(1)}s';
  }
}
