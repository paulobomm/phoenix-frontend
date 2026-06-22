import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/providers.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/domain/auth_provider.dart';
import 'features/auth/domain/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF09090B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // --- Restauração de sessão a partir do armazenamento local ---
  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final savedToken = await secureStorage.read(key: 'auth_token');

  final apiClient = ApiClient();
  AuthState? bootstrapAuth;
  if (savedToken != null && savedToken.isNotEmpty) {
    final user = UserModel.fromJwt(savedToken);
    if (user != null) {
      apiClient.setAuthToken(savedToken); // reinjeta o token nos headers HTTP
      bootstrapAuth = AuthState(isAuthenticated: true, user: user);
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(apiClient),
        bootstrapAuthStateProvider.overrideWithValue(bootstrapAuth),
      ],
      child: const PhoenixApp(),
    ),
  );
}

class PhoenixApp extends ConsumerWidget {
  const PhoenixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Phoenix',
      theme: AppTheme.dark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
