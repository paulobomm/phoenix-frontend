class DataStoreModel {
  final String id;
  final String name;
  final String type;
  final int entryCount;
  final int sizeBytes;
  final DateTime? lastSync;
  final String gameId;

  const DataStoreModel({
    required this.id,
    required this.name,
    required this.type,
    required this.entryCount,
    required this.sizeBytes,
    this.lastSync,
    this.gameId = '',
  });

  factory DataStoreModel.fromJson(Map<String, dynamic> json) {
    return DataStoreModel(
      id: json['id'] as String,
      gameId: json['gameId'] as String? ?? '',
      name: json['name'] as String,
      type: json['type'] as String? ?? 'standard',
      entryCount: json['entryCount'] as int? ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      lastSync: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
