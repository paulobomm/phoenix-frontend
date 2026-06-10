class EntryModel {
  final String key;
  final dynamic value;
  final DateTime? updatedAt;
  final int? version;

  const EntryModel({
    required this.key,
    required this.value,
    this.updatedAt,
    this.version,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      key: json['key'] as String,
      value: json['value'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      version: int.tryParse(json['version']?.toString() ?? ''),
    );
  }
}
