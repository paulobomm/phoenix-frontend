// Entries are not exposed by the discovery API. This stub prevents import errors.
class EntryModel {
  final String key;
  final dynamic value;
  const EntryModel({required this.key, this.value});
  factory EntryModel.fromJson(Map<String, dynamic> json) =>
      EntryModel(key: json['key'] as String? ?? '', value: json['value']);
}
