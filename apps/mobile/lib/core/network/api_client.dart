import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _iamDio;
  late final Dio _projectsDio;
  late final Dio _discoveryDio;
  late final Dio _snapshotsDio;
  late final Dio _restoreDio;
  late final Dio _auditDio;
  late final Dio _analyticsDio;

  ApiClient() {
    _iamDio = _buildDio(ApiConstants.iamBaseUrl);
    _projectsDio = _buildDio(ApiConstants.projectsBaseUrl);
    _discoveryDio = _buildDio(ApiConstants.discoveryBaseUrl);
    _snapshotsDio = _buildDio(ApiConstants.snapshotsBaseUrl);
    _restoreDio = _buildDio(ApiConstants.restoreBaseUrl);
    _auditDio = _buildDio(ApiConstants.auditBaseUrl);
    _analyticsDio = _buildDio(ApiConstants.analyticsBaseUrl);
  }

  Dio get iamDio => _iamDio;
  Dio get projectsDio => _projectsDio;
  Dio get discoveryDio => _discoveryDio;
  Dio get snapshotsDio => _snapshotsDio;
  Dio get restoreDio => _restoreDio;
  Dio get auditDio => _auditDio;
  Dio get analyticsDio => _analyticsDio;

  void setAuthToken(String token) {
    for (final dio in _allDios) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void clearAuthToken() {
    for (final dio in _allDios) {
      dio.options.headers.remove('Authorization');
    }
  }

  List<Dio> get _allDios =>
      [_iamDio, _projectsDio, _discoveryDio, _snapshotsDio, _restoreDio, _auditDio];

  Dio _buildDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
}
