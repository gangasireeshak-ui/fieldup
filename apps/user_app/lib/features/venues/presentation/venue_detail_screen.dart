import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});
  final String venueId;

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  String _selectedSport = 'Cricket';

  static const _sports = [
    _SportChip(label: 'Cricket', icon: Icons.sports_cricket),
    _SportChip(label: 'Badminton', icon: Icons.sports_tennis),
    _SportChip(label: 'Basketball', icon: Icons.sports_basketball),
    _SportChip(label: 'Football', icon: Icons.sports_soccer),
  ];

  static const _amenities = [
    _AmenityItem(label: 'Floodlights', icon: Icons.lightbulb_outline),
    _AmenityItem(label: 'Changing rooms', icon: Icons.checkroom),
    _AmenityItem(label: 'Parking', icon: Icons.local_parking),
    _AmenityItem(label: 'Drinking water', icon: Icons.water_drop),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // Hero image
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.teal600,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.neutral900,
                  size: 20,
                ),
                onPressed: () => context.go('/venues'),
              ),
            ),
            actions: [
              // Verified badge
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  color: AppColors.teal500,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Share button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.neutral900,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.teal600),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.neutral900.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Photo dot indicators
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == 0 ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue info header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Feather Touch Arena',
                          style: AppTextStyles.headingLG,
                        ),
                        const SizedBox(height: 8),
                        // Rating row
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: AppColors.orange500,
                            ),
                            const SizedBox(width: 4),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.neutral700,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '4.5',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' · 321 reviews · 245 Total Games',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Hours
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 20,
                              color: AppColors.teal600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '5:00 AM - 12:00 AM',
                              style: AppTextStyles.bodyMD.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: AppColors.teal600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '123 Sports Avenue, Active District, Cityville',
                                style: AppTextStyles.bodyMD.copyWith(
                                  color: AppColors.neutral700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action buttons — pill shape
                        Row(
                          children: [
                            Expanded(
                              child: _PillButton(
                                icon: Icons.map,
                                label: 'Show on Maps',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PillButton(
                                icon: Icons.rate_review,
                                label: 'Rate Venue',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  const _Divider(),

                  // Sports Available
                  Container(
                    color: AppColors.neutral50,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('SPORTS AVAILABLE'),
                        const SizedBox(height: 4),
                        Text(
                          'Click on your sport to view pricing',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _sports
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedSport = s.label,
                                      ),
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedSport == s.label
                                              ? AppColors.brandGreen100
                                              : AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: _selectedSport == s.label
                                                ? AppColors.brandGreen400
                                                : AppColors.neutral200,
                                            width: _selectedSport == s.label
                                                ? 2
                                                : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              s.icon,
                                              size: 18,
                                              color: _selectedSport == s.label
                                                  ? AppColors.brandGreen700
                                                  : AppColors.neutral500,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              s.label,
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                color:
                                                    _selectedSport == s.label
                                                        ? AppColors.neutral900
                                                        : AppColors.neutral700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CREATE GAME button
                  Container(
                    color: AppColors.neutral50,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.go('/venues/${widget.venueId}/slots'),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text('CREATE GAME'),
                      ),
                    ),
                  ),

                  const _Divider(),

                  // Amenities
                  Container(
                    color: AppColors.neutral50,
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('AMENITIES'),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 16,
                            children: _amenities
                                .map((a) => _AmenityTile(amenity: a))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const _Divider(),

                  // Nearby Games
                  Container(
                    color: AppColors.neutral50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('NEARBY GAMES'),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neutral200),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brandGreen100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.sports_tennis,
                                      color: AppColors.brandGreen700,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Badminton 2v2',
                                          style:
                                              AppTextStyles.bodyLG.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Today, 7:00 PM',
                                          style: AppTextStyles.caption
                                              .copyWith(
                                            color: AppColors.neutral600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Intermediate',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.teal600,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.only(top: 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.neutral100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: AppColors.neutral400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '2.5 km away',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.neutral600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const _Divider(),

                  // About Venue
                  Container(
                    color: AppColors.neutral50,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('ABOUT VENUE'),
                        const SizedBox(height: 12),
                        Text(
                          'Feather Touch Arena is a premium sports facility offering state-of-the-art courts for various sports. Whether you\'re looking for a casual hit or competitive play, our well-maintained surfaces and modern amenities provide the perfect environment for athletes of all levels. Features professional-grade lighting and ample parking.',
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.neutral700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOOK COURT sticky button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutral200)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/venues/${widget.venueId}/slots'),
            child: const Text('BOOK COURT'),
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Container(height: 8, color: AppColors.neutral50);
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.neutral900),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}

class _SportChip {
  const _SportChip({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _AmenityItem {
  const _AmenityItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _AmenityTile extends StatelessWidget {
  const _AmenityTile({required this.amenity});
  final _AmenityItem amenity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.teal50,
            shape: BoxShape.circle,
          ),
          child: Icon(amenity.icon, size: 16, color: AppColors.teal600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            amenity.label,
            style: AppTextStyles.bodyMD,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
