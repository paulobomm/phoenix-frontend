class LogModel {
  final String id;
  final String action;
  final String status;
  final String details;
  final DateTime timestamp;
  final String? gameId;

  const LogModel({
    required this.id,
    required this.action,
    required this.status,
    required this.details,
    required this.timestamp,
    this.gameId,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] as String,
      action: json['action'] as String? ?? '',
      status: json['status'] as String? ?? 'success',
      details: _parseDetails(json['details']),
      timestamp: DateTime.parse(json['createdAt'] as String),
      gameId: json['gameId'] as String?,
    );
  }

  static String _parseDetails(dynamic details) {
    if (details == null) return '';
    if (details is String) return details;
    if (details is Map) {
      return details.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    return details.toString();
  }
}
