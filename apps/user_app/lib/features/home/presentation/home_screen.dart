import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import '../../../features/auth/presentation/auth_provider.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────

const _kLime = AppColors.primary;
const _kBg = Colors.black;

TextStyle _display(double sz, {Color c = Colors.white, double tracking = -0.5}) =>
    TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
        color: c, letterSpacing: tracking, height: 1.0);

TextStyle _mono(double sz, {Color c = const Color(0xFF9E9E9E)}) =>
    TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

// ─── Mock live data ───────────────────────────────────────────────────────────


class _VenueOccupancy {
  const _VenueOccupancy({required this.name, required this.sport,
      required this.pct, required this.distance, required this.color});
  final String name, sport, distance;
  final double pct;
  final Color color;
}

class _ActivityItem {
  const _ActivityItem({required this.text, required this.sub,
      required this.icon, required this.color, required this.ago});
  final String text, sub, ago;
  final IconData icon;
  final Color color;
}

const _venueOccupancy = [
  _VenueOccupancy(name: 'Feather Touch Arena', sport: 'Badminton',
    pct: 0.88, distance: '1.2 km', color: Color(0xFF00B4B4)),
  _VenueOccupancy(name: 'Central Turf', sport: 'Football',
    pct: 0.95, distance: '2.4 km', color: Color(0xFF1B5E20)),
  _VenueOccupancy(name: 'JSS Courts', sport: 'Basketball',
    pct: 0.40, distance: '0.8 km', color: Color(0xFFE65100)),
  _VenueOccupancy(name: 'BTM Sports Hub', sport: 'Cricket',
    pct: 0.65, distance: '3.1 km', color: Color(0xFFC8F23A)),
];

const _activityFeed = [
  _ActivityItem(text: 'Rahul S. joined your game', sub: 'Football 5v5 · Tonight 8 PM',
    icon: Icons.person_add_outlined, color: Color(0xFF58B48F), ago: '2m'),
  _ActivityItem(text: 'Feather Touch Arena — 2 courts free',
    sub: 'Badminton · Book before 6 PM', icon: Icons.stadium_outlined,
    color: Color(0xFF00B4B4), ago: '5m'),
  _ActivityItem(text: 'You earned 50 Karma Points', sub: 'From last booking',
    icon: Icons.bolt, color: Color(0xFFC8F23A), ago: '12m'),
  _ActivityItem(text: 'Bangalore Badminton Open', sub: 'Registration closes in 48h',
    icon: Icons.emoji_events_outlined, color: Color(0xFFF2AD25), ago: '1h'),
  _ActivityItem(text: 'Priya K. challenged you', sub: 'Badminton singles · accept?',
    icon: Icons.sports_tennis, color: Color(0xFF3A8DCC), ago: '2h'),
  _ActivityItem(text: 'New coach in your area', sub: 'Suresh Phogat — Badminton',
    icon: Icons.fitness_center_outlined, color: Color(0xFF9C27B0), ago: '3h'),
];

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final user = ref.watch(currentUserProfileProvider).asData?.value;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Pinned app bar ──────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _OSAppBarDelegate(
              topPad: topPad,
              pulseCtrl: _pulseCtrl,
              userName: user?.name?.split(' ').first ?? 'Player',
              karmaPoints: user?.karmaPoints ?? 0,
              city: user?.city ?? 'Bangalore',
            ),
          ),

          // ── Announcement banner ─────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _AnnouncementBanner()),
          ),

          // ── Quick Launch Hub ────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _QuickLaunchHub()),
          ),

          // ── Nearby Action Discovery ─────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _NearbyActionSection()),

          // ── Dynamic Occupancy Visualization ─────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _OccupancySection(venues: _venueOccupancy)),

          // ── Real-Time Activity Feed ─────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _ActivityFeed(items: _activityFeed)),
          ),

          SliverToBoxAdapter(child: SizedBox(height: bottomPad + 24)),
        ],
      ),
    );
  }
}

// ─── OS App Bar ───────────────────────────────────────────────────────────────

class _OSAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _OSAppBarDelegate({
    required this.topPad,
    required this.pulseCtrl,
    required this.userName,
    required this.karmaPoints,
    required this.city,
  });
  final double topPad;
  final AnimationController pulseCtrl;
  final String userName;
  final int karmaPoints;
  final String city;

  @override
  double get minExtent => topPad + 60;
  @override
  double get maxExtent => topPad + 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _kBg,
      child: Column(
        children: [
          SizedBox(height: topPad),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _kBg,
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A4A1A),
                    border: Border.all(color: _kLime.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: _kLime, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: _mono(13, c: Colors.white)),
                    Row(children: [
                      const Icon(Icons.location_on, color: _kLime, size: 11),
                      const SizedBox(width: 3),
                      Text(city, style: _mono(11)),
                      const Icon(Icons.expand_more, color: Color(0xFF9E9E9E), size: 12),
                    ]),
                  ],
                ),
                const Spacer(),
                // FIELDUP wordmark
                Text('FIELDUP', style: _display(24, c: _kLime, tracking: -0.5)),
                const Spacer(),
                // Karma score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _kLime.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.bolt, color: _kLime, size: 13),
                    const SizedBox(width: 3),
                    Text('$karmaPoints', style: _mono(11, c: _kLime)),
                  ]),
                ),
                const SizedBox(width: 8),
                // Notification bell
                Stack(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          color: Colors.white.withValues(alpha: 0.7), size: 18),
                    ),
                    Positioned(
                      top: 6, right: 6,
                      child: AnimatedBuilder(
                        animation: pulseCtrl,
                        builder: (_, __) => Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kLime,
                            boxShadow: [BoxShadow(
                              color: _kLime.withValues(alpha: 0.6 + pulseCtrl.value * 0.4),
                              blurRadius: 4 + pulseCtrl.value * 4,
                            )],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_OSAppBarDelegate old) => false;
}

// ─── Announcement Banner ──────────────────────────────────────────────────────

class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1500), Color(0xFF1A3000), Color(0xFF0A0A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background glow orb
            Positioned(
              left: -40, bottom: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kLime.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Watermark icon
            Positioned(
              right: -10, top: -10,
              child: Icon(Icons.sports_soccer, size: 140,
                  color: Colors.white.withValues(alpha: 0.03)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kLime,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [BoxShadow(
                        color: _kLime.withValues(alpha: 0.5), blurRadius: 12)],
                    ),
                    child: Text('LAUNCH OFFER',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary, letterSpacing: 1.0,
                        )),
                  ),
                  // Title + CTA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PLAY FOR\nFREE TODAY',
                          style: _display(30, c: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/venues'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                              decoration: BoxDecoration(
                                color: _kLime,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(
                                  color: _kLime.withValues(alpha: 0.4),
                                  blurRadius: 16, offset: const Offset(0, 4))],
                              ),
                              child: Text('BOOK NOW →',
                                  style: TextStyle(
                                    fontFamily: 'Barlow Condensed', fontSize: 13,
                                    fontWeight: FontWeight.w800, color: AppColors.onPrimary,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('100% free · No card needed',
                              style: _mono(11, c: Colors.white.withValues(alpha: 0.35))),
                        ],
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

// ─── Quick Launch Hub ─────────────────────────────────────────────────────────

class _QuickLaunchHub extends StatelessWidget {
  static const _actions = [
    (label: 'JOIN GAME', icon: Icons.sports_soccer, route: '/community', color: Color(0xFF1B5E20), desc: 'Find players'),
    (label: 'BOOK VENUE', icon: Icons.stadium_outlined, route: '/venues', color: Color(0xFF003D5C), desc: 'Free slots'),
    (label: 'FIND COACH', icon: Icons.fitness_center_outlined, route: '/coaches', color: Color(0xFF2A004A), desc: 'Near you'),
    (label: 'SCORING', icon: Icons.scoreboard_outlined, route: '/scoring', color: Color(0xFF3A2000), desc: 'Go live'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('QUICK LAUNCH', style: _display(18, c: Colors.white)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _kLime.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('HUB', style: _mono(9, c: _kLime)),
          ),
        ]),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: _actions.map((a) => GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go(a.route);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [a.color.withValues(alpha: 0.8), a.color.withValues(alpha: 0.4)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Stack(
                children: [
                  // Watermark
                  Positioned(
                    right: -8, bottom: -8,
                    child: Icon(a.icon, size: 44, color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(a.icon, size: 20, color: _kLime),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.label, style: _display(15, c: Colors.white)),
                            Text(a.desc, style: _mono(10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// ─── Nearby Action Discovery ──────────────────────────────────────────────────

class _NearbyActionSection extends StatelessWidget {
  static const _sports = [
    (name: 'All', active: true),
    (name: 'Football', active: false),
    (name: 'Badminton', active: false),
    (name: 'Cricket', active: false),
    (name: 'Basketball', active: false),
  ];

  static const _games = [
    (sport: 'Football 5v5', time: 'Tonight 8 PM', venue: 'Central Turf',
      spots: '2 spots left', price: '₹49/person', color: Color(0xFF1B5E20),
      icon: Icons.sports_soccer, urgent: true),
    (sport: 'Badminton Singles', time: 'Tomorrow 7 AM', venue: 'Feather Touch',
      spots: '1 spot left', price: '₹30/person', color: Color(0xFF00B4B4),
      icon: Icons.sports_tennis, urgent: true),
    (sport: 'Basketball 3v3', time: 'Tomorrow 6 PM', venue: 'JSS Courts',
      spots: '4 spots', price: 'Free', color: Color(0xFFE65100),
      icon: Icons.sports_basketball, urgent: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Text('NEARBY ACTION', style: _display(18, c: Colors.white)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/community'),
              child: Row(children: [
                Text('View All', style: _mono(12, c: _kLime)),
                const Icon(Icons.chevron_right, color: _kLime, size: 14),
              ]),
            ),
          ]),
        ),
        // Sport filter chips
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _sports.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _sports[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: s.active ? _kLime.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: s.active ? _kLime.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(s.name, style: _mono(12, c: s.active ? _kLime : Colors.white.withValues(alpha: 0.5))),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Game cards
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _games.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final g = _games[i];
              return GestureDetector(
                onTap: () => context.go('/community'),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: g.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: g.color.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(g.icon, color: g.color, size: 14),
                        const SizedBox(width: 5),
                        Text(g.sport, style: _mono(11, c: g.color)),
                        const Spacer(),
                        if (g.urgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A0A00),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                            ),
                            child: Text(g.spots, style: _mono(9, c: Colors.red)),
                          )
                        else
                          Text(g.spots, style: _mono(10)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(g.time, style: _display(20, c: Colors.white)),
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(Icons.location_on, size: 11, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(width: 3),
                          Text(g.venue, style: _mono(11)),
                        ]),
                      ]),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _kLime,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 10)],
                          ),
                          child: Text('JOIN →', style: _display(12, c: const Color(0xFF1A2800))),
                        ),
                        const Spacer(),
                        Text(g.price, style: _display(16, c: _kLime)),
                      ]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Dynamic Occupancy Visualization ─────────────────────────────────────────

class _OccupancySection extends StatelessWidget {
  const _OccupancySection({required this.venues});
  final List<_VenueOccupancy> venues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Text('VENUE OCCUPANCY', style: _display(18, c: Colors.white)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('LIVE', style: _mono(9, c: Colors.white.withValues(alpha: 0.4))),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/venues'),
              child: Row(children: [
                Text('Book Now', style: _mono(12, c: _kLime)),
                const Icon(Icons.chevron_right, color: _kLime, size: 14),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: venues.map((v) {
              final isHigh = v.pct > 0.8;
              final isMed = v.pct > 0.5;
              final barColor = isHigh
                  ? Colors.red
                  : isMed
                      ? const Color(0xFFF2AD25)
                      : const Color(0xFF58B48F);

              return GestureDetector(
                onTap: () => context.go('/venues'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Row(children: [
                    // Color dot
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: v.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(v.name, style: _mono(13, c: Colors.white.withValues(alpha: 0.9)))),
                          Text(v.distance, style: _mono(11)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: v.pct,
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [barColor, barColor.withValues(alpha: 0.6)],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(v.pct * 100).round()}%',
                              style: _mono(11, c: barColor)),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          isHigh ? 'Almost full — book fast' : isMed ? 'Filling up' : 'Available now',
                          style: _mono(10, c: barColor.withValues(alpha: 0.8)),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHigh
                            ? Colors.white.withValues(alpha: 0.04)
                            : _kLime.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isHigh
                              ? Colors.white.withValues(alpha: 0.08)
                              : _kLime.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        isHigh ? 'Full' : 'Book →',
                        style: _mono(11, c: isHigh ? Colors.white.withValues(alpha: 0.3) : _kLime),
                      ),
                    ),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Real-Time Activity Feed ──────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.items});
  final List<_ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('ACTIVITY FEED', style: _display(18, c: Colors.white)),
          const SizedBox(width: 8),
          _PulseDot(),
          const SizedBox(width: 5),
          Text('Real-time', style: _mono(11)),
        ]),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Timeline line
                Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: item.color.withValues(alpha: 0.25)),
                      ),
                      child: Icon(item.icon, color: item.color, size: 16),
                    ),
                    if (i < items.length - 1)
                      Container(
                        width: 1,
                        height: 8,
                        color: Colors.white.withValues(alpha: 0.06),
                        margin: const EdgeInsets.symmetric(vertical: 1),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.text, style: _mono(13, c: Colors.white.withValues(alpha: 0.9))),
                        const SizedBox(height: 2),
                        Text(item.sub, style: _mono(11)),
                      ])),
                      Text(item.ago, style: _mono(10, c: Colors.white.withValues(alpha: 0.3))),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text('Load More Activity', style: _mono(13, c: Colors.white.withValues(alpha: 0.4))),
          ),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.7, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kLime,
          boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.7), blurRadius: 8)],
        ),
      ),
    );
  }
}
