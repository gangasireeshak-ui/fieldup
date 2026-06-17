import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/auth/presentation/create_account_screen.dart';
import 'features/auth/presentation/interests_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/venues/presentation/venues_screen.dart';
import 'features/venues/presentation/venue_detail_screen.dart';
import 'features/venues/presentation/slot_picker_screen.dart';
import 'features/venues/presentation/booking_summary_screen.dart';
import 'features/coaches/presentation/coaches_screen.dart';
import 'features/coaches/presentation/coach_detail_screen.dart';
import 'features/scoring/presentation/scoring_screen.dart';
import 'features/games/presentation/games_screen.dart';
import 'features/games/presentation/game_detail_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'shared/providers/auth_provider.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final hasCompletedOnboarding = ref.watch(onboardingDoneProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final onAuth = state.matchedLocation.startsWith('/auth');
      final onOnboarding = state.matchedLocation == '/';

      if (isAuthenticated && hasCompletedOnboarding) {
        if (onAuth || onOnboarding) return '/home';
        return null;
      }

      if (isAuthenticated && !hasCompletedOnboarding) {
        if (onAuth) return '/home';
        return null;
      }

      // Unauthenticated: show onboarding first, then login
      if (!hasCompletedOnboarding && !onOnboarding) return '/';
      if (hasCompletedOnboarding && !onAuth) return '/auth/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) {
          final phone = state.extra as String;
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/auth/create-account',
        builder: (_, __) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/auth/interests',
        builder: (_, __) => const InterestsScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/coaches',
            builder: (_, __) => const CoachesScreen(),
            routes: [
              GoRoute(
                path: ':coachId',
                builder: (_, state) => CoachDetailScreen(
                  coachId: state.pathParameters['coachId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/venues',
            builder: (_, __) => const VenuesScreen(),
            routes: [
              GoRoute(
                path: ':venueId',
                builder: (_, state) => VenueDetailScreen(
                  venueId: state.pathParameters['venueId']!,
                ),
              ),
              GoRoute(
                path: ':venueId/slots',
                builder: (_, state) => SlotPickerScreen(
                  venueId: state.pathParameters['venueId']!,
                ),
              ),
              GoRoute(
                path: ':venueId/booking-summary',
                builder: (_, state) => BookingSummaryScreen(
                  venueId: state.pathParameters['venueId']!,
                  extra: state.extra as Map<String, dynamic>,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/community',
            builder: (_, __) => const GamesScreen(),
            routes: [
              GoRoute(
                path: ':gameId',
                builder: (_, state) => GameDetailScreen(
                  gameId: state.pathParameters['gameId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/account',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/scoring',
            builder: (_, __) => const ScoringScreen(),
          ),
        ],
      ),
    ],
  );
}

// ── Bottom navigation shell ───────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = ['/home', '/coaches', '/venues', '/community', '/account'];

  static const _navItems = [
    (icon: Icons.home_outlined,             activeIcon: Icons.home,              label: 'Home'),
    (icon: Icons.fitness_center_outlined,   activeIcon: Icons.fitness_center,    label: 'Coaches'),
    (icon: Icons.stadium_outlined,          activeIcon: Icons.stadium,           label: 'Venues'),
    (icon: Icons.groups_outlined,           activeIcon: Icons.groups,            label: 'Community'),
    (icon: Icons.account_circle_outlined,   activeIcon: Icons.account_circle,    label: 'Account'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.neutral200.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: AppColors.neutral500.withValues(alpha: 0.3),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen400.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (i) {
                    final item = _navItems[i];
                    final isActive = currentIndex == i;
                    return _NavItem(
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      label: item.label,
                      isActive: isActive,
                      onTap: () => context.go(_tabs[i]),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.brandGreen400.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brandGreen400.withValues(alpha: 0.5),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? AppColors.brandGreen400
                  : AppColors.neutral600,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.brandGreen400
                    : AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
