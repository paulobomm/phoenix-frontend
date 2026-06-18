class DataStoreModel {
  final String id;
  final String name;
  final String type;
  final int entryCount;
  final int sizeBytes;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  const DataStoreModel({
    required this.id,
    required this.name,
    this.type = 'standard',
    this.entryCount = 0,
    this.sizeBytes = 0,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });

  factory DataStoreModel.fromJson(Map<String, dynamic> json) {
    return DataStoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'standard',
      entryCount: (json['entryCount'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  DateTime get lastSync => lastSeenAt;
}
