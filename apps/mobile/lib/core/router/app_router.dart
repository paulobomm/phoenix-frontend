import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/games/presentation/pages/games_page.dart';
import '../../features/games/presentation/pages/add_game_wizard_page.dart';
import '../../features/games/presentation/pages/game_detail_page.dart';
import '../../features/datastores/presentation/pages/datastores_page.dart';
import '../../features/datastores/presentation/pages/entry_viewer_page.dart';
import '../../features/datastores/presentation/pages/player_search_page.dart';
import '../../features/snapshots/presentation/pages/snapshots_page.dart';
import '../../features/snapshots/presentation/pages/snapshot_detail_page.dart';
import '../../features/snapshots/presentation/pages/compare_snapshots_page.dart';
import '../../features/snapshots/presentation/pages/restore_wizard_page.dart';
import '../../features/audit/presentation/pages/logs_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/billing_page.dart';
import 'main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  final authStateListenable = ValueNotifier<bool>(false);

  ref.listen<AuthState>(authProvider, (prev, next) {
    authStateListenable.value = next.isAuthenticated;
  });

  return GoRouter(
    initialLocation: '/auth/login',
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isAuthenticated;
      final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordPage()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/games', builder: (_, __) => const GamesPage()),
          GoRoute(path: '/games/add', builder: (_, __) => const AddGameWizardPage()),
          GoRoute(
            path: '/games/:id',
            builder: (context, state) => GameDetailPage(gameId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/datastores', builder: (_, __) => const DataStoresPage()),
          GoRoute(
            path: '/datastores/:id/entries',
            builder: (context, state) => EntryViewerPage(datastoreId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/player-search', builder: (_, __) => const PlayerSearchPage()),
          GoRoute(path: '/snapshots', builder: (_, __) => const SnapshotsPage()),
          GoRoute(
            path: '/snapshots/:id',
            builder: (context, state) => SnapshotDetailPage(snapshotId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/snapshots/:id/restore',
            builder: (context, state) => RestoreWizardPage(snapshotId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/compare', builder: (_, __) => const CompareSnapshotsPage()),
          GoRoute(path: '/restore', builder: (_, __) => const RestoreWizardPage()),
          GoRoute(path: '/logs', builder: (_, __) => const LogsPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/billing', builder: (_, __) => const BillingPage()),
        ],
      ),
    ],
  );
});
