import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../../../core/constants/auth0_config.dart';
import '../../../core/di/providers.dart';
import '../data/auth_remote_datasource.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(AuthRemoteDataSource(apiClient));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(name, email, password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loginWithAuth0() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth0 = Auth0(Auth0Config.domain, Auth0Config.clientId);
      final credentials = await auth0.webAuthentication(scheme: 'https').login();
      final response = await _repository.loginWithAuth0(credentials.accessToken);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void logout() {
    _repository.clearToken();
    state = const AuthState();
  }
}
