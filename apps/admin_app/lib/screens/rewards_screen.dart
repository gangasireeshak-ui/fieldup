import 'package:flutter/material.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('REWARDS MANAGEMENT', style: _head(28, c: _kLime)),
            Text('FieldUp Karma Points System', style: _body(12)),
            const SizedBox(height: 20),

            // Summary
            Row(children: [
              _RewardStat(label: 'Points Issued', value: '284K', icon: Icons.bolt),
              const SizedBox(width: 10),
              _RewardStat(label: 'Redeemed', value: '42K', icon: Icons.redeem),
              const SizedBox(width: 10),
              _RewardStat(label: 'Active Users', value: '1.2K', icon: Icons.people),
            ]),
            const SizedBox(height: 20),

            Text('EARN RULES', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ...[
              (action: 'Venue Booking', points: 50, icon: Icons.stadium_outlined),
              (action: 'Game Join', points: 20, icon: Icons.sports_soccer),
              (action: 'Referral', points: 100, icon: Icons.person_add_outlined),
              (action: 'Profile Complete', points: 30, icon: Icons.check_circle_outline),
              (action: 'Match Score Entry', points: 15, icon: Icons.scoreboard_outlined),
            ].map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(children: [
                Icon(r.icon, color: Colors.white.withValues(alpha: 0.4), size: 18),
                const SizedBox(width: 12),
                Text(r.action, style: _body(13, c: Colors.white.withValues(alpha: 0.7))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _kLime.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.bolt, color: _kLime, size: 12),
                    const SizedBox(width: 3),
                    Text('+${r.points}', style: _body(11, c: _kLime)),
                  ]),
                ),
              ]),
            )),
            const SizedBox(height: 20),

            Text('TOP EARNERS THIS WEEK', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ...const [
              ('Rahul Sharma', 'Bangalore', 2840),
              ('Priya Kumar', 'Mumbai', 2210),
              ('Amit Roy', 'Delhi', 1980),
            ].asMap().entries.map((e) {
              final rank = e.key + 1;
              final player = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: rank == 1 ? _kLime.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rank == 1 ? _kLime.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(children: [
                  Text('#$rank', style: _head(20, c: rank == 1 ? _kLime : Colors.white.withValues(alpha: 0.3))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(player.$1, style: _head(16)),
                    Text(player.$2, style: _body(11)),
                  ])),
                  Row(children: [
                    Icon(Icons.bolt, color: _kLime, size: 14),
                    const SizedBox(width: 3),
                    Text('${player.$3}', style: _head(16, c: _kLime)),
                  ]),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  const _RewardStat({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: _kLime, size: 18),
        const SizedBox(height: 6),
        Text(value, style: _head(22)),
        Text(label, style: _body(9)),
      ]),
    ),
  );
}
