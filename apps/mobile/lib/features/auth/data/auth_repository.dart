import 'auth_remote_datasource.dart';
import 'models/auth_response_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  Future<AuthResponseModel> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  Future<AuthResponseModel> register(String name, String email, String password) {
    return _remoteDataSource.register(name, email, password);
  }

  Future<AuthResponseModel> loginWithAuth0(String auth0Token) {
    return _remoteDataSource.loginWithAuth0(auth0Token);
  }

  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(email);
  }

  void clearToken() => _remoteDataSource.clearToken();
}
