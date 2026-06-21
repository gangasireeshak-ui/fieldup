import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import '../presentation/auth_provider.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selected = {};
  bool _isLoading = false;

  static const _sports = [
    _Sport('Basketball', Color(0xFFE65100)),
    _Sport('Soccer', Color(0xFF1B5E20)),
    _Sport('Tennis', Color(0xFFF57F17)),
    _Sport('Cricket', Color(0xFFB71C1C)),
    _Sport('Football', Color(0xFF37474F)),
    _Sport('Padel', Color(0xFF0D47A1)),
    _Sport('Badminton', Color(0xFF004D40)),
    _Sport('Box Cricket', Color(0xFF4E342E)),
    _Sport('Volleyball', Color(0xFFBF360C)),
    _Sport('Swimming', Color(0xFF006064)),
    _Sport('Boxing', Color(0xFF4A148C)),
    _Sport('Kabaddi', Color(0xFF33691E)),
    _Sport('Table Tennis', Color(0xFF1A237E)),
    _Sport('Shooting', Color(0xFF546E7A)),
  ];

  List<_Sport> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _sports;
    return _sports.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _confirm() async {
    if (_selected.isEmpty) {
      _skip();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uid = ref.read(authRepositoryProvider).currentUser?.id;
      if (uid != null) {
        await ref.read(authRepositoryProvider).saveSportInterests(
          userId: uid,
          sports: _selected.map((s) => s.toLowerCase().replaceAll(' ', '_')).toList(),
        );
      }
    } catch (_) {
      // Non-fatal — proceed regardless
    }
    if (mounted) context.go('/home');
  }

  void _skip() => context.go('/home');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative glow orb
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen400.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Header + search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHOOSE YOUR\nINTERESTS',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandGreen400,
                            height: 1.06,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Select the sports you play or follow to personalise your FieldUp experience.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: AppColors.neutral700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Glassmorphic search bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14),
                                    child: Icon(
                                      Icons.search,
                                      color: AppColors.neutral700,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: AppColors.neutral900,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search sports...',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        hintStyle: TextStyle(
                                          fontFamily: 'Inter',
                                          color: AppColors.neutral700
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sport grid
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20, 0, 20, bottomPad + 100,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _SportCard(
                        sport: filtered[i],
                        isSelected: _selected.contains(filtered[i].name),
                        onTap: () => setState(() {
                          if (_selected.contains(filtered[i].name)) {
                            _selected.remove(filtered[i].name);
                          } else {
                            _selected.add(filtered[i].name);
                          }
                        }),
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.85),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.neutral500.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _skip,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neutral900,
                              side: const BorderSide(
                                  color: AppColors.neutral500),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGreen400,
                              foregroundColor: AppColors.brandGreen700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'CONFIRM',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  const _SportCard({
    required this.sport,
    required this.isSelected,
    required this.onTap,
  });

  final _Sport sport;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.brandGreen400.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandGreen400.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Sport colour background
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 0.65 : 0.3,
                child: Container(color: sport.color),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.88),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // Sport name + check icon
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sport.name,
                        style: TextStyle(
                          fontFamily: 'Barlow Condensed',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.brandGreen400
                              : AppColors.neutral900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background.withValues(alpha: 0.5),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.brandGreen400,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sport {
  const _Sport(this.name, this.color);
  final String name;
  final Color color;
}
