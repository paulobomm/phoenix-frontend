class LogModel {
  final String id;
  final DateTime occurredAt;
  final String exchange;
  final String routingKey;
  final String eventType;
  final String? projectId;
  final dynamic payload;
  final DateTime receivedAt;

  const LogModel({
    required this.id,
    required this.occurredAt,
    required this.exchange,
    required this.routingKey,
    required this.eventType,
    this.projectId,
    this.payload,
    required this.receivedAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      exchange: json['exchange'] as String? ?? '',
      routingKey: json['routingKey'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      projectId: json['projectId'] as String?,
      payload: json['payload'],
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }
}
