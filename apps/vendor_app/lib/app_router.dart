import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/arena_management_screen.dart';
import 'screens/add_venue_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/availability_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/revenue_screen.dart';
import 'screens/customer_insights_screen.dart';

final vendorRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(vendorAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final onShell = state.matchedLocation != '/login';
      if (!auth && onShell) return '/login';
      if (auth && state.matchedLocation == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const VendorLoginScreen()),
      ShellRoute(
        builder: (context, state, child) => VendorShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const VendorDashboardScreen()),
          GoRoute(path: '/arena', builder: (_, __) => const ArenaManagementScreen()),
          GoRoute(
            path: '/arena/add-venue',
            builder: (_, __) => const AddVenueScreen(),
          ),
          GoRoute(path: '/pricing', builder: (_, __) => const PricingScreen()),
          GoRoute(path: '/availability', builder: (_, __) => const AvailabilityScreen()),
          GoRoute(path: '/bookings', builder: (_, __) => const BookingsScreen()),
          GoRoute(path: '/revenue', builder: (_, __) => const RevenueScreen()),
          GoRoute(path: '/insights', builder: (_, __) => const CustomerInsightsScreen()),
        ],
      ),
    ],
  );
});

class VendorShell extends ConsumerWidget {
  const VendorShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    '/dashboard', '/arena', '/pricing',
    '/availability', '/bookings', '/revenue', '/insights',
  ];
  static const _icons = [
    Icons.dashboard_outlined, Icons.stadium_outlined, Icons.price_change_outlined,
    Icons.calendar_month_outlined, Icons.book_online_outlined,
    Icons.bar_chart_outlined, Icons.people_outline,
  ];
  static const _labels = [
    'Dashboard', 'Arena', 'Pricing',
    'Schedule', 'Bookings', 'Revenue', 'Insights',
  ];

  int _idx(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            color: active ? const Color(0xFF3A8DCC) : Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 2),
                        Text(_labels[i],
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 9,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? const Color(0xFF3A8DCC) : Colors.white.withValues(alpha: 0.3),
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
