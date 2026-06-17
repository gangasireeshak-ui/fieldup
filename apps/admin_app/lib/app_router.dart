import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/command_center_screen.dart';
import 'screens/venue_approvals_screen.dart';
import 'screens/tournament_control_screen.dart';
import 'screens/banner_studio_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/notifications_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AdminLoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/command', builder: (_, __) => const CommandCenterScreen()),
          GoRoute(path: '/approvals', builder: (_, __) => const VenueApprovalsScreen()),
          GoRoute(path: '/tournaments', builder: (_, __) => const TournamentControlScreen()),
          GoRoute(path: '/banners', builder: (_, __) => const BannerStudioScreen()),
          GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        ],
      ),
    ],
  );
});

class AdminShell extends StatelessWidget {
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

  int _idx(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _idx(context);
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icons[i], size: 20,
                            color: active ? const Color(0xFFC8F23A) : Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 2),
                        Text(_labels[i],
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 9,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? const Color(0xFFC8F23A) : Colors.white.withValues(alpha: 0.3),
                            )),
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
