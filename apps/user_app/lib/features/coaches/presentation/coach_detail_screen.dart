import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

class CoachDetailScreen extends ConsumerStatefulWidget {
  const CoachDetailScreen({super.key, required this.coachId});
  final String coachId;

  @override
  ConsumerState<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends ConsumerState<CoachDetailScreen> {
  int? _expandedSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // Hero
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.neutral900),
                onPressed: () => context.go('/coaches'),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.neutral900,
                  ),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: AppColors.neutral900,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo placeholder
                  Container(color: AppColors.neutral300),

                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x4D161B1D), // neutral900 30%
                          Colors.transparent,
                          Color(0x99161B1D), // neutral900 60%
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),

                  // Verified badge — top right below action buttons
                  Positioned(
                    top: 72,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pagination dots
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity
                  const Text('Suresh Phogat', style: AppTextStyles.headingLG),
                  const SizedBox(height: 4),
                  Text(
                    'Certified Cricket Coach | 10+ Years Experience | Batting & Strategy',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sessions card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessions',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.neutral900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _InfoRow(
                          icon: Icons.calendar_month_outlined,
                          text: 'Monday – Sunday',
                        ),
                        const SizedBox(height: 10),
                        const _InfoRow(
                          icon: Icons.person_outline,
                          text: 'Adult',
                        ),
                        const SizedBox(height: 10),
                        const _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: 'Main Stadium Pitch, Sector 4, Sports Complex, City Center, 400012',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expandable sections — single card with dividers
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Column(
                      children: [
                        _SectionRow(
                          title: 'About',
                          isExpanded: _expandedSection == 0,
                          isFirst: true,
                          isLast: false,
                          onTap: () => setState(
                            () => _expandedSection =
                                _expandedSection == 0 ? null : 0,
                          ),
                          content: _AboutContent(),
                        ),
                        _SectionRow(
                          title: 'Testimonials',
                          isExpanded: _expandedSection == 1,
                          isFirst: false,
                          isLast: false,
                          onTap: () => setState(
                            () => _expandedSection =
                                _expandedSection == 1 ? null : 1,
                          ),
                          content: _TestimonialsContent(),
                        ),
                        _SectionRow(
                          title: 'Training Formats',
                          isExpanded: _expandedSection == 2,
                          isFirst: false,
                          isLast: false,
                          onTap: () => setState(
                            () => _expandedSection =
                                _expandedSection == 2 ? null : 2,
                          ),
                          content: _TrainingFormatsContent(),
                        ),
                        _SectionRow(
                          title: 'Coaching Focus',
                          isExpanded: _expandedSection == 3,
                          isFirst: false,
                          isLast: false,
                          onTap: () => setState(
                            () => _expandedSection =
                                _expandedSection == 3 ? null : 3,
                          ),
                          content: _CoachingFocusContent(),
                        ),
                        _SectionRow(
                          title: 'Experience & Background',
                          isExpanded: _expandedSection == 4,
                          isFirst: false,
                          isLast: true,
                          onTap: () => setState(
                            () => _expandedSection =
                                _expandedSection == 4 ? null : 4,
                          ),
                          content: _ExperienceContent(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutral200)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen400,
                      foregroundColor: AppColors.brandGreen700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.headingMD,
                    ),
                    child: const Text('BOOK'),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Bowling Training ~ ₹800/hour',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                      Text(
                        '• Tactical Session ~ ₹1200/hour',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GST and platform fees applicable at checkout.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral500,
                          fontStyle: FontStyle.italic,
                        ),
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

// ── Section row (expandable) ──────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.title,
    required this.isExpanded,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.content,
  });

  final String title;
  final bool isExpanded;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst)
          const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast && !isExpanded ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.bodyLG),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.neutral500,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: content,
          ),
        ],
      ],
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.neutral500),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700),
          ),
        ),
      ],
    );
  }
}

// ── Bullet item ───────────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  const _BulletItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppColors.neutral600),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section content widgets ───────────────────────────────────────────────────

class _AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Focused on developing strong fundamentals, match awareness, and confident shot selection.\n\nWith over 10 years of coaching experience, I work with players across age groups — from beginners learning the basics to competitive cricketers preparing for tournaments.',
      style: AppTextStyles.bodyMD.copyWith(
        color: AppColors.neutral700,
        height: 1.6,
      ),
    );
  }
}

class _TestimonialsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"My batting technique improved significantly after just a few sessions."',
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.neutral700,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— U16 Player',
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}

class _TrainingFormatsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BulletItem('1-on-1 Batting Sessions'),
        _BulletItem('Bowling Action Correction'),
        _BulletItem('Nets Practice Sessions'),
        _BulletItem('Team Coaching'),
      ],
    );
  }
}

class _CoachingFocusContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BulletItem('Batting Technique'),
        _BulletItem('Bowling Accuracy & Speed'),
        _BulletItem('Fielding & Reflex Training'),
        _BulletItem('Match Strategy & Game Awareness'),
        _BulletItem('Fitness & Endurance'),
        _BulletItem('Youth Skill Development'),
      ],
    );
  }
}

class _ExperienceContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BulletItem('Certified Cricket Coaching License'),
        _BulletItem('Former District / State-Level Player'),
        _BulletItem('10+ Years Playing Experience'),
        _BulletItem('Trained 100+ Youth Cricketers'),
        _BulletItem('Specialized in Batting Technique & Bowling Mechanics'),
        _BulletItem('Tournament Preparation Coach'),
      ],
    );
  }
}
