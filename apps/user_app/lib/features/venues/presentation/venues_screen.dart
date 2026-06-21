import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'package:fieldup_core/fieldup_core.dart';
import 'venue_provider.dart';
class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;

  static const _sportFilters = [
    'Football', 'Cricket', 'Badminton', 'Basketball', 'Tennis',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(
      venuesListProvider(sport: _selectedSport?.toLowerCase()),
    );

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Venues', style: AppTextStyles.headingLG),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.teal600),
                const SizedBox(width: 2),
                Text(
                  'Phase 5, JP Nagar',
                  style: AppTextStyles.label.copyWith(color: AppColors.teal600),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.teal600,
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
          // Search + filters — sticky section
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: AppTextStyles.bodyMD,
                            decoration: const InputDecoration(
                              hintText: 'Search for venues...',
                              hintStyle: TextStyle(color: AppColors.neutral600),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    children: [
                      _FilterChip(
                        label: 'Filter',
                        icon: Icons.tune,
                        isSelected: false,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      ..._sportFilters.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _FilterChip(
                            label: s,
                            isSelected: _selectedSport == s,
                            onTap: () => setState(() {
                              _selectedSport = _selectedSport == s ? null : s;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.neutral200),

          Expanded(
            child: venuesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load venues: $e')),
              data: (venues) {
                final q = _searchController.text.toLowerCase();
                final filtered = venues.where((v) {
                  final matchSearch = q.isEmpty ||
                      v.name.toLowerCase().contains(q) ||
                      v.address.toLowerCase().contains(q);
                  return matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No venues found. Check back soon!'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _VenueCard(
                    venue: filtered[i],
                    onTap: () => context.go('/venues/${filtered[i].id}'),
                  ),
                );
              },
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
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.brandGreen700
                    : AppColors.neutral900,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isSelected
                    ? AppColors.brandGreen700
                    : AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Venue card ────────────────────────────────────────────────────────────────

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onTap});
  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sportsLabel = venue.sports.map((s) => _capitalize(s)).join(' • ');
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
            // Image / photo area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // Photo or colour fallback
                  venue.photos.isNotEmpty
                      ? Image.network(
                          venue.photos.first,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            width: double.infinity,
                            color: AppColors.teal600,
                          ),
                        )
                      : Container(
                          height: 130,
                          width: double.infinity,
                          color: AppColors.teal600,
                        ),
                  if (venue.isVerified)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teal500,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Verified', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(venue.name, style: AppTextStyles.headingMD),
                      if (venue.rating != null)
                        Row(children: [
                          const Icon(Icons.star, size: 14, color: AppColors.orange500),
                          const SizedBox(width: 2),
                          Text(venue.rating!.toStringAsFixed(1),
                              style: AppTextStyles.label.copyWith(color: AppColors.neutral700)),
                        ]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sportsLabel.isNotEmpty ? sportsLabel : 'Multi-sport',
                      style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral600)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.neutral700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${venue.address}, ${venue.city}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.neutral700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
