import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/community')),
        title: const Text('Badminton 2v2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game meta info
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(Icons.schedule_outlined, '8:00 AM - 9:00 AM • 26th Jan, Mon'),
                  const SizedBox(height: 8),
                  _MetaRow(Icons.public_outlined, 'Public  •  ₹49/ player'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Playground Arena, HAL Rd, Indiranagar',
                          style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.map_outlined, size: 16, color: AppColors.neutral600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Skill level
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SKILL LEVEL', style: _sectionLabelStyle),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Game Skill  ', style: AppTextStyles.bodyMD),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teal50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Intermediate - Professional',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.teal600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Instructions
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INSTRUCTIONS', style: _sectionLabelStyle),
                  const SizedBox(height: 10),
                  _BulletItem(icon: Icons.sports_outlined, text: 'BYOE'),
                  _BulletItem(icon: Icons.paid_outlined, text: 'Cost Shared'),
                  const SizedBox(height: 8),
                  Text('Others', style: AppTextStyles.caption.copyWith(color: AppColors.neutral500)),
                  const SizedBox(height: 6),
                  Text(
                    '• UPI - loremipasum@okbla\n• Booked court #1,2,3 & 4\n  80 for 1 hr\n  120 for 1.5 hr\n• Cancellation is not available',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700, height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Players
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PLAYERS', style: _sectionLabelStyle),
                  const SizedBox(height: 12),
                  _PlayerRow(name: 'Ashish Chaudhary', skill: 'Intermediate', isHost: true),
                  _PlayerRow(name: 'Ajay', skill: 'Advance', isCoHost: true),
                  _PlayerRow(name: 'Lorem Ipsum', skill: 'Advance'),
                  _PlayerRow(name: 'Lorem Ipsum', skill: 'Intermediate'),
                  _PlayerRow(name: 'Lorem Ipsum', skill: 'Advance'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'SEE ALL >',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Locker Room
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCKER-ROOM',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any doubts, ask them here for quick clarification.',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('ASK DOUBT'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Trainers
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRAINERS', style: _sectionLabelStyle),
                  const SizedBox(height: 4),
                  Text(
                    'Below are some trainers available for this game',
                    style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: const [
                      _TrainerCard(name: 'Suresh Phogat', specialty: 'Yoga, Dance, Mobility, Stretching'),
                      _TrainerCard(name: 'Aryaraj Singh', specialty: 'Yoga, Dance, Mobility, Stretching'),
                      _TrainerCard(name: 'Suresh Phogat', specialty: 'Yoga, Dance, Mobility, Stretching'),
                      _TrainerCard(name: 'Aryaraj Singh', specialty: 'Yoga, Dance, Mobility, Stretching'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('JOIN GAME  •  ₹49 / person'),
          ),
        ),
      ),
    );
  }

  TextStyle get _sectionLabelStyle => AppTextStyles.caption.copyWith(
    color: AppColors.neutral500,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral500),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700)),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neutral500),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodyMD.copyWith(color: AppColors.neutral700)),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.name,
    required this.skill,
    this.isHost = false,
    this.isCoHost = false,
  });
  final String name;
  final String skill;
  final bool isHost;
  final bool isCoHost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.neutral200,
            child: const Icon(Icons.person, size: 22, color: AppColors.neutral500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
                    if (isHost) ...[
                      const SizedBox(width: 6),
                      _Badge('Host', AppColors.primary, AppColors.onPrimary),
                    ],
                    if (isCoHost) ...[
                      const SizedBox(width: 6),
                      _Badge('Co-host', AppColors.teal50, AppColors.teal600),
                    ],
                  ],
                ),
                Text(
                  skill,
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.bg, this.fg);
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.name, required this.specialty});
  final String name;
  final String specialty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                color: AppColors.neutral300,
                child: const Center(
                  child: Icon(Icons.person, size: 48, color: AppColors.neutral500),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Trainer',
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(name, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  specialty,
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral500, fontSize: 10),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
