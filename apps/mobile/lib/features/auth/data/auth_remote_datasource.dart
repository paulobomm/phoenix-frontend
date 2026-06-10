import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/auth_response_model.dart';
import 'models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final res = await _apiClient.dio.post('/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      final accessToken = res.data['accessToken'] as String;
      _apiClient.setAuthToken(accessToken);
      final user = await _fetchMe();
      return AuthResponseModel(token: accessToken, user: user);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<AuthResponseModel> register(String name, String email, String password) async {
    try {
      final res = await _apiClient.dio.post('/v1/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': password,
      });
      final accessToken = res.data['accessToken'] as String;
      _apiClient.setAuthToken(accessToken);
      final user = await _fetchMe();
      return AuthResponseModel(token: accessToken, user: user);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<AuthResponseModel> loginWithAuth0(String auth0Token) async {
    try {
      final res = await _apiClient.dio.post('/v1/auth/auth0/callback', data: {
        'token': auth0Token,
      });
      final accessToken = res.data['accessToken'] as String;
      _apiClient.setAuthToken(accessToken);
      final user = await _fetchMe();
      return AuthResponseModel(token: accessToken, user: user);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post('/v1/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  void clearToken() => _apiClient.clearAuthToken();

  Future<UserModel> _fetchMe() async {
    final res = await _apiClient.dio.get('/v1/users/me');
    final data = res.data as Map<String, dynamic>;
    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      plan: 'free',
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is List) return msg.join(', ');
      if (msg is String) return msg;
    }
    return e.message ?? 'Erro de conexão';
  }
}
