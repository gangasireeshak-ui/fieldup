import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/command_center_screen.dart';
import 'screens/venue_approvals_screen.dart';
import 'screens/tournament_control_screen.dart';
import 'screens/banner_studio_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/notifications_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(adminAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final onShell = state.matchedLocation != '/login';
      if (!auth && onShell) return '/login';
      if (auth && state.matchedLocation == '/login') return '/command';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AdminLoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/command',     builder: (_, __) => const CommandCenterScreen()),
          GoRoute(path: '/approvals',   builder: (_, __) => const VenueApprovalsScreen()),
          GoRoute(path: '/tournaments', builder: (_, __) => const TournamentControlScreen()),
          GoRoute(path: '/banners',     builder: (_, __) => const BannerStudioScreen()),
          GoRoute(path: '/analytics',   builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/rewards',     builder: (_, __) => const RewardsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      ),
    ],
  );
});

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    '/command', '/approvals', '/tournaments',
    '/banners', '/analytics', '/rewards', '/notifications',
  ];
  static const _icons = [
    Icons.hub_outlined, Icons.verified_outlined, Icons.emoji_events_outlined,
    Icons.campaign_outlined, Icons.analytics_outlined,
    Icons.stars_outlined, Icons.notifications_outlined,
  ];
  static const _labels = [
    'Command', 'Approvals', 'Tournaments',
    'Banners', 'Analytics', 'Rewards', 'Push',
  ];

  // Badge counts — non-zero values show a red dot
  static const _badges = [0, 5, 1, 0, 0, 0, 0];

  int _idx(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _idx(context);
    const kLime = Color(0xFFC8F23A);
    return Scaffold(
      backgroundColor: Colors.black,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = idx == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(_tabs[i]),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_icons[i], size: 20,
                                color: active ? kLime : Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(height: 2),
                            Text(_labels[i],
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 9,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  color: active ? kLime : Colors.white.withValues(alpha: 0.3),
                                )),
                          ],
                        ),
                        if (_badges[i] > 0)
                          Positioned(
                            top: 6, right: 8,
                            child: Container(
                              width: 14, height: 14,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE34B34),
                              ),
                              child: Text(
                                '${_badges[i]}',
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 8,
                                  fontWeight: FontWeight.w700, color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
