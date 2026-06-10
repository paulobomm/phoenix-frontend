class BackupChartPoint {
  final DateTime date;
  final int count;

  const BackupChartPoint({required this.date, required this.count});

  factory BackupChartPoint.fromJson(Map<String, dynamic> json) {
    return BackupChartPoint(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      count: (json['backups'] as int? ?? 0) + (json['restores'] as int? ?? 0),
    );
  }
}
