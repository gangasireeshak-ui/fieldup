import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

class CoachesScreen extends ConsumerStatefulWidget {
  const CoachesScreen({super.key});

  @override
  ConsumerState<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends ConsumerState<CoachesScreen> {
  String? _selectedCategory;

  static const _categories = [
    'Yoga',
    'Dance',
    'Workout',
    'Dietician',
    'Cricket',
    'Football',
  ];

  static const _coaches = [
    _CoachData(
      id: '1',
      name: 'Marcus Johnson',
      role: 'Trainer',
      specialty: 'Workout • Strength',
      category: 'Workout',
      location: '123 Fitness Ave, Central',
      imageColor: AppColors.neutral300,
    ),
    _CoachData(
      id: '2',
      name: 'Sarah Williams',
      role: 'Instructor',
      specialty: 'Yoga • Meditation',
      category: 'Yoga',
      location: 'Zen Studio, Northside',
      imageColor: AppColors.neutral300,
    ),
    _CoachData(
      id: '3',
      name: 'David Chen',
      role: 'Coach',
      specialty: 'Athletics • Sprinting',
      category: 'Football',
      location: 'City Stadium Track',
      imageColor: AppColors.neutral300,
    ),
    _CoachData(
      id: '4',
      name: 'Emma Davis',
      role: 'Dietician',
      specialty: 'Nutrition • Diet',
      category: 'Dietician',
      location: 'Online Consultation',
      imageColor: AppColors.neutral300,
    ),
  ];

  List<_CoachData> get _filtered {
    if (_selectedCategory == null) return _coaches;
    return _coaches.where((c) => c.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Coaches', style: AppTextStyles.headingMD),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 2),
                Text(
                  'London',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.neutral700,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.neutral600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.neutral200),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Registration banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Are you a coach or trainer?',
                              style: AppTextStyles.headingMD,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Register with us and grow your business',
                              style: AppTextStyles.bodyMD.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral900,
                          side: const BorderSide(
                            color: AppColors.neutral900,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: AppTextStyles.label,
                        ),
                        child: const Text('+ Register with Us'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Icon-only filter button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.neutral300),
                          ),
                          child: const Icon(
                            Icons.tune,
                            size: 18,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "All" chip
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: c,
                            isSelected: _selectedCategory == c,
                            onTap: () => setState(() {
                              _selectedCategory =
                                  _selectedCategory == c ? null : c;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Coach grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _CoachCard(
                    coach: filtered[i],
                    onTap: () => context.go('/coaches/${filtered[i].id}'),
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

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen100 : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandGreen400 : AppColors.neutral300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? AppColors.neutral900 : AppColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Coach data model ──────────────────────────────────────────────────────────

class _CoachData {
  const _CoachData({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    required this.category,
    required this.location,
    required this.imageColor,
  });

  final String id;
  final String name;
  final String role;
  final String specialty;
  final String category;
  final String location;
  final Color imageColor;
}

// ── Coach card ────────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onTap});
  final _CoachData coach;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: coach.imageColor,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      coach.role,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.teal600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coach.specialty,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: AppColors.neutral500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          coach.location,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.neutral500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
