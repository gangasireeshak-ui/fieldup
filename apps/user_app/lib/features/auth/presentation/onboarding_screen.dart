import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  final _controller = PageController();

  static const _slides = [
    _Slide(
      title: 'BOOK & JOIN SPORTS\nVENUES INSTANTLY',
      body: 'Find and book arenas, join tournaments, and connect with players in your area.',
      gradientColors: [Color(0xFF0D2015), Color(0xFF1A4030)],
    ),
    _Slide(
      title: 'TRAIN WITH COACHES\nWHO KNOW THE GAME',
      body: 'Book trusted coaches across sports with flexible sessions and fair pricing.',
      gradientColors: [Color(0xFF0D1525), Color(0xFF1A3060)],
    ),
    _Slide(
      title: 'SURROUND YOURSELF\nWITH COMPETITION',
      body: 'Match with players at your level or higher to improve your game.',
      gradientColors: [Color(0xFF200D25), Color(0xFF4A1A60)],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) ref.read(onboardingDoneProvider.notifier).state = true;
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Slide pages
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Slide indicators
                    Row(
                      children: List.generate(_slides.length, (i) {
                        final isActive = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 8),
                          width: isActive ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.brandGreen400
                                : AppColors.neutral400,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.brandGreen400
                                          .withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started pill button
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGreen400,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandGreen400
                                  .withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _slides.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: AppColors.brandGreen700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: AppColors.brandGreen700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final heroHeight = height * 0.55;

    return Stack(
      children: [
        // Hero — photo + gradient tint
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB9Zg2n5HXMAtsR38ztBQLLa-ph_gnUGFWgzPZp907tXXVQ6FFB-pAbrVppi-QHvoobkkEbnZIlPqlC5we9mXgP7ilYgUD0-1kE8_tfIitcFHpItb2wzzgMSXQ4PUHVXfokK7XrO7iPgR12y7iNd8ytd8TIVQOfEEhqoSpbGSLzddYoAGK1ItC3pqm2SE1yVnq4VSptnMFOMhfXiXdYswrX8_XZZwZXjn-pZrpu-npDsOgdf19CKgIfNtEF-zKMLbPXKHlOxtkzDiE',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: slide.gradientColors
                        .map((c) => c.withValues(alpha: 0.72))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Decorative diagonal line accent
        Positioned(
          top: heroHeight * 0.3,
          right: -40,
          child: Transform.rotate(
            angle: -0.3,
            child: Container(
              width: 2,
              height: heroHeight * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.brandGreen400.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Gradient fade hero → background
        Positioned(
          top: heroHeight * 0.5,
          left: 0,
          right: 0,
          height: heroHeight * 0.55,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        // Text content
        Positioned(
          top: heroHeight * 0.6,
          left: 24,
          right: 24,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.title,
                style: const TextStyle(
                  fontFamily: 'Barlow Condensed',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.08,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide.body,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.gradientColors,
  });
  final String title;
  final String body;
  final List<Color> gradientColors;
}
