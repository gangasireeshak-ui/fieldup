import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../../auth/presentation/auth_provider.dart';

class CoachesScreen extends ConsumerStatefulWidget {
  const CoachesScreen({super.key});

  @override
  ConsumerState<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends ConsumerState<CoachesScreen> {
  String? _selectedSport;

  static const _categories = [
    'Cricket', 'Football', 'Badminton', 'Basketball', 'Tennis', 'Yoga',
  ];

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(
      coachesListProvider(sport: _selectedSport?.toLowerCase()),
    );
    final city = ref.watch(currentUserProfileProvider).asData?.value?.city ?? 'Bangalore';

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
          Row(children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.neutral600),
            const SizedBox(width: 2),
            Text(city, style: AppTextStyles.label.copyWith(color: AppColors.neutral700)),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.neutral600),
          ]),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.neutral200),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Register banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.brandGreen400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Are you a coach or trainer?', style: AppTextStyles.headingMD),
                    const SizedBox(height: 2),
                    Text('Register with us and grow your business',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neutral900,
                  side: const BorderSide(color: AppColors.neutral900, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: AppTextStyles.label,
                ),
                child: const Text('+ Register with Us'),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Sport filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedSport == null,
                  onTap: () => setState(() => _selectedSport = null),
                ),
                const SizedBox(width: 8),
                ..._categories.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: c,
                    isSelected: _selectedSport == c,
                    onTap: () => setState(
                        () => _selectedSport = _selectedSport == c ? null : c),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Coach grid — real DB data
          coachesAsync.when(
            loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )),
            error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Failed to load coaches: $e',
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral600)),
                )),
            data: (coaches) {
              if (coaches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No coaches available yet.\nCheck back soon!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral600),
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemCount: coaches.length,
                itemBuilder: (_, i) => _CoachCard(
                  coach: coaches[i],
                  onTap: () => context.go('/coaches/${coaches[i].id}'),
                ),
              );
            },
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
          child: Text(label,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.neutral900 : AppColors.neutral700)),
        ),
      ),
    );
  }
}

// ── Coach card ────────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach, required this.onTap});
  final Coach coach;
  final VoidCallback onTap;

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final sportsLabel = coach.sports.map(_cap).join(' • ');
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
            // Photo / avatar
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: coach.avatarUrl != null
                    ? Image.network(
                        coach.avatarUrl!,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderAvatar(),
                      )
                    : _placeholderAvatar(),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    coach.isVerified ? 'Verified' : 'Coach',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.teal600,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ]),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name ?? 'Coach',
                    style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sportsLabel.isNotEmpty ? sportsLabel : 'Multi-sport',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on,
                        size: 13, color: AppColors.neutral500),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        coach.city ?? 'Bangalore',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.neutral500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  if (coach.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star,
                          size: 13, color: AppColors.orange500),
                      const SizedBox(width: 2),
                      Text(
                        coach.rating!.toStringAsFixed(1),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.neutral700),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderAvatar() => Container(
        height: 130,
        width: double.infinity,
        color: AppColors.neutral300,
        child: const Icon(Icons.person, size: 48, color: AppColors.neutral600),
      );
}
