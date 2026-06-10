class GameModel {
  final String id;
  final String name;
  final String universeId;
  final String placeId;
  final int syncInterval;
  final bool isSyncPaused;
  final int datastoreCount;
  final String? thumbnailUrl;
  final DateTime? lastSync;

  const GameModel({
    required this.id,
    required this.name,
    required this.universeId,
    required this.placeId,
    required this.syncInterval,
    required this.isSyncPaused,
    required this.datastoreCount,
    this.thumbnailUrl,
    this.lastSync,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      name: json['name'] as String,
      universeId: json['universeId'] as String,
      placeId: json['placeId'] as String,
      syncInterval: json['syncInterval'] as int? ?? 60,
      isSyncPaused: json['isSyncPaused'] as bool? ?? false,
      datastoreCount: 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      lastSync: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'universeId': universeId,
        'placeId': placeId,
        'syncInterval': syncInterval,
        'isSyncPaused': isSyncPaused,
        'thumbnailUrl': thumbnailUrl,
      };

  GameModel copyWith({
    String? id,
    String? name,
    String? universeId,
    String? placeId,
    int? syncInterval,
    bool? isSyncPaused,
    int? datastoreCount,
    String? thumbnailUrl,
    DateTime? lastSync,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      universeId: universeId ?? this.universeId,
      placeId: placeId ?? this.placeId,
      syncInterval: syncInterval ?? this.syncInterval,
      isSyncPaused: isSyncPaused ?? this.isSyncPaused,
      datastoreCount: datastoreCount ?? this.datastoreCount,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}
