import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/domain/auth_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _navRoutes = ['/dashboard', '/games', '/snapshots', '/restore', '/settings'];
  static const _navIcons = [
    Icons.home_outlined,
    Icons.videogame_asset_outlined,
    Icons.cloud_outlined,
    Icons.restore_rounded,
    Icons.settings_outlined,
  ];
  static const _navActiveIcons = [
    Icons.home_rounded,
    Icons.videogame_asset_rounded,
    Icons.cloud_rounded,
    Icons.restore_rounded,
    Icons.settings_rounded,
  ];
  static const _navLabels = ['Visão Geral', 'Jogos', 'Backups', 'Restore', 'Config.'];

  int _currentIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/games')) return 1;
    if (path.startsWith('/snapshots') || path.startsWith('/compare')) return 2;
    if (path.startsWith('/restore')) return 3;
    if (path.startsWith('/logs')) return 4;
    if (path.startsWith('/settings')) return 4;
    if (path.startsWith('/billing')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final idx = _currentIndex(path);
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _Sidebar(currentIndex: idx),
            Container(width: 1, color: AppColors.border),
            Expanded(child: child),
          ],
        ),
      );
    }

    final showBottomNav = idx < 5;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: BottomNavigationBar(
                currentIndex: idx,
                onTap: (i) => context.go(_navRoutes[i]),
                backgroundColor: Colors.transparent,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: List.generate(
                  5,
                  (i) => BottomNavigationBarItem(
                    icon: Icon(_navIcons[i]),
                    activeIcon: Icon(_navActiveIcons[i]),
                    label: _navLabels[i],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final int currentIndex;
  const _Sidebar({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Container(
      width: 220,
      color: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/phoenix_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                const Text(
                  'PHOENIX',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SideItem(Icons.home_outlined, Icons.home_rounded, 'Visão Geral', '/dashboard', currentIndex == 0),
          _SideItem(Icons.videogame_asset_outlined, Icons.videogame_asset_rounded, 'Meus Jogos', '/games', currentIndex == 1),
          _SideItem(Icons.cloud_outlined, Icons.cloud_rounded, 'Backups', '/snapshots', currentIndex == 2),
          _SideItem(Icons.restore_rounded, Icons.restore_rounded, 'Restore', '/restore', currentIndex == 3),
          _SideItem(Icons.history_rounded, Icons.history_rounded, 'Histórico', '/logs', currentIndex == 4),
          const Spacer(),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _SideItem(Icons.settings_outlined, Icons.settings_rounded, 'Configurações', '/settings', currentIndex == 5),
          _SideItem(Icons.star_outline_rounded, Icons.star_rounded, 'Plano', '/billing', currentIndex == 6),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Usuário',
                        style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Plano ${(user?.plan ?? 'free').toUpperCase()}',
                          style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(authProvider.notifier).logout(),
                  child: const Tooltip(
                    message: 'Sair',
                    child: Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isActive;

  const _SideItem(this.icon, this.activeIcon, this.label, this.route, this.isActive);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
