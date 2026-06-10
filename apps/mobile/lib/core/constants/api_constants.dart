abstract class ApiConstants {
  // Android emulator uses 10.0.2.2 to reach the host machine.
  // For a physical device on the same network, replace with your machine's LAN IP.
  static const String _host = '10.0.2.2';

  static const String iamBaseUrl = 'http://$_host:5001';
  static const String projectsBaseUrl = 'http://$_host:5002';
  static const String discoveryBaseUrl = 'http://$_host:5003';
  static const String snapshotsBaseUrl = 'http://$_host:5004';
  static const String auditBaseUrl = 'http://$_host:5007';
  static const String analyticsBaseUrl = 'http://$_host:5005';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
