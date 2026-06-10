abstract class ApiConstants {
  // Local dev: http://<machine-ip> (nginx on port 80)
  // Android emulator: http://10.0.2.2
  // Production: https://api.phoenix.gg
  static const String baseUrl = 'http://10.200.72.207';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
