import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String? _selectedSport;

  static const _sports = ['Soccer', 'Basketball', 'Tennis', 'Cricket'];

  static const _games = [
    _GameData(
      id: '1',
      title: 'Urban Turf 7v7',
      time: 'Today, 8:00 PM',
      sport: 'Soccer',
      distance: '1.2 mi',
      priceUsd: 10,
      spotsTotal: 14,
      spotsFilled: 12,
      status: _GameStatus.open,
      gradientColors: [Color(0xFF1B4332), Color(0xFF0A1F16)],
      sportIcon: Icons.sports_soccer,
    ),
    _GameData(
      id: '2',
      title: 'Downtown Hoops',
      time: 'Tomorrow, 6:30 PM',
      sport: 'Basketball',
      distance: '3.5 mi',
      priceUsd: 5,
      spotsTotal: 10,
      spotsFilled: 10,
      status: _GameStatus.full,
      gradientColors: [Color(0xFF1A1A3E), Color(0xFF0D0D22)],
      sportIcon: Icons.sports_basketball,
    ),
    _GameData(
      id: '3',
      title: 'Singles Match',
      time: 'Thu, 7:00 AM',
      sport: 'Tennis',
      distance: '5.0 mi',
      priceUsd: 0,
      spotsTotal: 2,
      spotsFilled: 1,
      status: _GameStatus.open,
      gradientColors: [Color(0xFF0B3D2E), Color(0xFF071F18)],
      sportIcon: Icons.sports_tennis,
    ),
    _GameData(
      id: '4',
      title: 'Night Smash 2v2',
      time: '8:00 AM, 26th Jan',
      sport: 'Badminton',
      distance: '1.7 km',
      priceUsd: 8,
      spotsTotal: 4,
      spotsFilled: 3,
      status: _GameStatus.open,
      gradientColors: [Color(0xFF2D1B69), Color(0xFF160D35)],
      sportIcon: Icons.sports,
    ),
  ];

  List<_GameData> get _filtered => _selectedSport == null
      ? _games
      : _games.where((g) => g.sport == _selectedSport).toList();

  @override
  Widget build(BuildContext context) {
    final games = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Find Games',
                    style: AppTextStyles.displayLG.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  _GlassChip(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, size: 15,
                            color: AppColors.neutral700),
                        const SizedBox(width: 5),
                        Text(
                          'Filter',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Sport filter chips ─────────────────────────────────────────
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _SportChip(
                    label: 'All Sports',
                    isSelected: _selectedSport == null,
                    onTap: () => setState(() => _selectedSport = null),
                  ),
                  ..._sports.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _SportChip(
                      label: s,
                      isSelected: _selectedSport == s,
                      onTap: () => setState(
                          () => _selectedSport = _selectedSport == s ? null : s),
                    ),
                  )),
                ],
              ),
            ),

            // ── Create Game CTA ────────────────────────────────────────────
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _CreateGameBanner(
                onTap: () => _showCreateGameSheet(context),
              ),
            ),

            // ── Games list ─────────────────────────────────────────────────
            const SizedBox(height: 20),
            ...List.generate(games.length, (i) => Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, i == games.length - 1 ? 20 : 16),
              child: _GameCard(
                game: games[i],
                onTap: () => context.push('/community/${games[i].id}'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showCreateGameSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateGameSheet(),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

enum _GameStatus { open, full }

class _GameData {
  const _GameData({
    required this.id,
    required this.title,
    required this.time,
    required this.sport,
    required this.distance,
    required this.priceUsd,
    required this.spotsTotal,
    required this.spotsFilled,
    required this.status,
    required this.gradientColors,
    required this.sportIcon,
  });

  final String id;
  final String title;
  final String time;
  final String sport;
  final String distance;
  final int priceUsd;
  final int spotsTotal;
  final int spotsFilled;
  final _GameStatus status;
  final List<Color> gradientColors;
  final IconData sportIcon;

  int get spotsLeft => spotsTotal - spotsFilled;
}

// ── Glass chip ─────────────────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Sport chip ─────────────────────────────────────────────────────────────────

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.brandGreen400,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen400.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.brandGreen700,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.neutral800,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Create game banner ─────────────────────────────────────────────────────────

class _CreateGameBanner extends StatelessWidget {
  const _CreateGameBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.brandGreen400.withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandGreen400.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+ Create Game',
                            style: AppTextStyles.headingLG.copyWith(
                              color: AppColors.brandGreen400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Host your own match and invite players.',
                            style: AppTextStyles.bodyMD.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen400,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandGreen400.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.brandGreen700,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Game card ──────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});
  final _GameData game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spotsLeft = game.spotsLeft;
    final isFull = game.status == _GameStatus.full;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image / gradient header ──────────────────────────────
                SizedBox(
                  height: 112,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: game.gradientColors,
                          ),
                        ),
                      ),
                      // Sport icon watermark
                      Positioned(
                        right: -12,
                        bottom: -12,
                        child: Icon(
                          game.sportIcon,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      // Availability badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _AvailabilityBadge(isFull: isFull, spotsLeft: spotsLeft),
                      ),
                      // Distance badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3E50)
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.map_outlined,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    game.distance,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
                ),

                // ── Card body ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.title.toUpperCase(),
                                  style: AppTextStyles.headingMD.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        size: 14,
                                        color: AppColors.brandGreen400),
                                    const SizedBox(width: 4),
                                    Text(
                                      game.time,
                                      style: AppTextStyles.bodyMD.copyWith(
                                        color: AppColors.neutral700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            game.priceUsd == 0
                                ? 'Free'
                                : '\$${game.priceUsd}',
                            style: AppTextStyles.headingMD.copyWith(
                              color: AppColors.brandGreen400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: AppColors.neutral500.withValues(alpha: 0.3),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Player avatar stack
                          _AvatarStack(count: game.spotsFilled),
                          const Spacer(),
                          _ActionButton(game: game),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Availability badge ─────────────────────────────────────────────────────────

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isFull, required this.spotsLeft});
  final bool isFull;
  final int spotsLeft;

  @override
  Widget build(BuildContext context) {
    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF37485B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.neutral500.withValues(alpha: 0.4)),
        ),
        child: Text(
          'FULL',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.brandGreen400,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGreen400.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        '$spotsLeft ${spotsLeft == 1 ? 'Spot' : 'Spots'} Left'.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.brandGreen700,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Avatar stack ───────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final visible = count.clamp(0, 3);
    final overflow = count - visible;
    const size = 30.0;
    final total = visible + (overflow > 0 ? 1 : 0);

    return SizedBox(
      width: total * 18.0 + (size - 18),
      height: size,
      child: Stack(
        children: [
          ...List.generate(visible, (i) => Positioned(
            left: i * 18.0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neutral300,
                border: Border.all(
                  color: const Color(0xFF2D3E50),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, size: 16, color: AppColors.neutral700),
            ),
          )),
          if (overflow > 0)
            Positioned(
              left: visible * 18.0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutral300,
                  border: Border.all(color: const Color(0xFF2D3E50), width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
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

// ── Action button ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.game});
  final _GameData game;

  @override
  Widget build(BuildContext context) {
    final isFull = game.status == _GameStatus.full;
    final isLastSpot = game.spotsLeft == 1;

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.neutral400.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Waitlist',
          style: AppTextStyles.label.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (isLastSpot) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.brandGreen400,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen400.withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          'Join',
          style: AppTextStyles.label.copyWith(
            color: AppColors.brandGreen700,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF37485B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral500.withValues(alpha: 0.4)),
      ),
      child: Text(
        'View',
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Create Game bottom sheet ───────────────────────────────────────────────────

class _CreateGameSheet extends StatefulWidget {
  const _CreateGameSheet();

  @override
  State<_CreateGameSheet> createState() => _CreateGameSheetState();
}

class _CreateGameSheetState extends State<_CreateGameSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedSkill;

  static const _skillLevels = ['Rookie', 'Contender', 'Playmaker', 'Competitive', 'Elite'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'ADD PLAYERS',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: AppColors.neutral900,
                unselectedLabelColor: AppColors.neutral500,
                labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Add player'),
                  Tab(text: 'My Playpals'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Name', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'Player Name'),
                        ),
                        const SizedBox(height: 16),
                        const Text('WhatsApp Number', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: 'Mobile Number'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fieldup will send an invitation link on this number.',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.neutral500),
                        ),
                        const SizedBox(height: 16),
                        const Text('Select Skill level', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skillLevels.map((s) {
                            final isSelected = _selectedSkill == s;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSkill = s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brandGreen100
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.neutral300,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isSelected
                                        ? AppColors.brandGreen700
                                        : AppColors.neutral700,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text('Or',
                            style: AppTextStyles.bodyMD
                                .copyWith(color: AppColors.neutral500)),
                        const SizedBox(height: 12),
                        const Text('Copy Invite link:', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.neutral300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'fieldup.co.in/players/add',
                                  style: AppTextStyles.bodyMD
                                      .copyWith(color: AppColors.neutral700),
                                ),
                              ),
                              const Icon(Icons.copy_outlined,
                                  size: 20,
                                  color: AppColors.neutral600),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Scan the QR Code to Onboard Players:',
                            style: AppTextStyles.label),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppColors.neutral200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.qr_code,
                                  size: 100,
                                  color: AppColors.neutral600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed:
                              _nameController.text.isNotEmpty ? () {} : null,
                          child: const Text('SELECT'),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'No playpals yet',
                      style: AppTextStyles.bodyMD
                          .copyWith(color: AppColors.neutral500),
                    ),
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
