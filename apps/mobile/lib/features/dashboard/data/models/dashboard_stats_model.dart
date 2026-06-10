class DashboardStatsModel {
  final int totalGames;
  final int totalBackups;
  final double storageUsedGb;
  final double successRate;

  const DashboardStatsModel({
    required this.totalGames,
    required this.totalBackups,
    required this.storageUsedGb,
    required this.successRate,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      totalBackups: json['totalBackups'] as int? ?? 0,
      storageUsedGb: (json['storageUsedGb'] as num?)?.toDouble() ?? 0.0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
