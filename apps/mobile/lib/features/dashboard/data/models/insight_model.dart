class InsightModel {
  final String title;
  final String description;
  final String type;
  final String icon;

  const InsightModel({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'info';
    final iconMap = {
      'warning': 'warning',
      'error': 'error',
      'success': 'check_circle',
      'info': 'info',
    };
    return InsightModel(
      title: json['title'] as String? ?? '',
      description: json['message'] as String? ?? '',
      type: type,
      icon: iconMap[type] ?? 'info',
    );
  }
}
