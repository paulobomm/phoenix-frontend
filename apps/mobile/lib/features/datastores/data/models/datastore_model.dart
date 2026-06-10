class DataStoreModel {
  final String id;
  final String name;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  const DataStoreModel({
    required this.id,
    required this.name,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });

  factory DataStoreModel.fromJson(Map<String, dynamic> json) {
    return DataStoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
    );
  }
}
