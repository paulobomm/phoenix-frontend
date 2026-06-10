import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/auth_response_model.dart';
import 'models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final res = await _apiClient.iamDio.post('/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      final accessToken = res.data['accessToken'] as String;
      _apiClient.setAuthToken(accessToken);
      final user = _userFromToken(accessToken);
      return AuthResponseModel(token: accessToken, user: user);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<AuthResponseModel> register(String name, String email, String password) async {
    // The backend does not expose a public self-registration endpoint.
    // User accounts are created by an administrator via POST /v1/users.
    throw Exception('Auto-cadastro não disponível. Contate o administrador do Phoenix.');
  }

  Future<AuthResponseModel> loginWithAuth0(String auth0Token) async {
    // Auth0 callback endpoint not yet implemented on the backend.
    throw Exception('Login via Auth0 não está disponível ainda.');
  }

  Future<void> forgotPassword(String email) async {
    // Forgot-password endpoint not yet implemented on the backend.
    throw Exception('Recuperação de senha não está disponível ainda.');
  }

  void clearToken() => _apiClient.clearAuthToken();

  /// Decodes the JWT payload to extract user info.
  /// The IAM signs tokens with: { sub, email, permissions }.
  UserModel _userFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Token inválido');
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return UserModel(
        id: json['sub'] as String,
        name: (json['email'] as String).split('@').first,
        email: json['email'] as String,
        plan: 'free',
        createdAt: DateTime.now(),
      );
    } catch (_) {
      throw Exception('Não foi possível ler os dados do token.');
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is List) return (msg as List).join(', ');
      if (msg is String) return msg;
    }
    return e.message ?? 'Erro de conexão';
  }
}
