abstract class ApiConstants {
  // Android emulator uses 10.0.2.2 to reach the host machine.
  // For a physical device on the same network, replace with your machine's LAN IP.
  // Production: https://api.phoenix.gg
  static const String _host = '10.0.2.2';

  static const String iamBaseUrl = 'http://$_host:5001';
  static const String projectsBaseUrl = 'http://$_host:5002';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
