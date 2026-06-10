class CompareResultModel {
  final List<String> addedKeys;
  final List<String> removedKeys;
  final List<String> modifiedKeys;
  final String snapshotAId;
  final String snapshotBId;

  const CompareResultModel({
    required this.addedKeys,
    required this.removedKeys,
    required this.modifiedKeys,
    required this.snapshotAId,
    required this.snapshotBId,
  });

  factory CompareResultModel.fromJson(Map<String, dynamic> json) {
    return CompareResultModel(
      snapshotAId: json['snapshotAId'] as String? ?? '',
      snapshotBId: json['snapshotBId'] as String? ?? '',
      addedKeys: List<String>.from(json['addedKeys'] as List? ?? []),
      removedKeys: List<String>.from(json['removedKeys'] as List? ?? []),
      modifiedKeys: List<String>.from(json['modifiedKeys'] as List? ?? []),
    );
  }
}
