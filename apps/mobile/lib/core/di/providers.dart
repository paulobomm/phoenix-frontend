import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Sobrescrito em `main()` com a instância já inicializada
/// (`await SharedPreferences.getInstance()`).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider deve ser sobrescrito em main()');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(
    ref.read(secureStorageProvider),
    ref.read(sharedPreferencesProvider),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
