import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _iamDio;
  late final Dio _projectsDio;

  ApiClient() {
    _iamDio = _buildDio(ApiConstants.iamBaseUrl);
    _projectsDio = _buildDio(ApiConstants.projectsBaseUrl);
  }

  Dio get iamDio => _iamDio;
  Dio get projectsDio => _projectsDio;

  void setAuthToken(String token) {
    _iamDio.options.headers['Authorization'] = 'Bearer $token';
    _projectsDio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _iamDio.options.headers.remove('Authorization');
    _projectsDio.options.headers.remove('Authorization');
  }

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
