class GameModel {
  final String id;
  final String ownerUserId;
  final String name;
  final String universeId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.universeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      name: json['name'] as String,
      universeId: json['universeId'] as String,
      status: json['status'] as String? ?? 'inactive',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'universeId': universeId,
    'status': status,
  };

  GameModel copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? universeId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameModel(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      universeId: universeId ?? this.universeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
