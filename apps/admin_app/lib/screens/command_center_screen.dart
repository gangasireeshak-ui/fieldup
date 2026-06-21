import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class CommandCenterScreen extends StatelessWidget {
  const CommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _kBg,
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FIELDUP COMMAND CENTER', style: _head(18, c: _kLime)),
                Text('Live Ecosystem Dashboard', style: _body(11)),
              ]),
              const Spacer(),
              // Notifications shortcut
              GestureDetector(
                onTap: () => context.go('/notifications'),
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        width: 7, height: 7,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE34B34)),
                      ),
                    ),
                  ]),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _kLime.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: _kLime,
                      boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.8), blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('LIVE', style: _body(10, c: _kLime)),
                ]),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Platform KPIs — tap analytics
                Row(children: [
                  _AdminKpi(label: 'Active Users', value: '2,847', change: '+124 today', positive: true, onTap: () => context.go('/analytics')),
                  const SizedBox(width: 10),
                  _AdminKpi(label: 'Live Matches', value: '18', change: 'right now', positive: true, onTap: () => context.go('/analytics')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _AdminKpi(label: 'Bookings Today', value: '341', change: '+28%', positive: true, onTap: () => context.go('/analytics')),
                  const SizedBox(width: 10),
                  _AdminKpi(label: 'Revenue Today', value: '₹1.2L', change: '+15%', positive: true, onTap: () => context.go('/analytics')),
                ]),
                const SizedBox(height: 20),

                // Pending approvals — navigates to /approvals
                GestureDetector(
                  onTap: () => context.go('/approvals'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1500),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2AD25).withValues(alpha: 0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFF2AD25), size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('PENDING APPROVALS', style: _head(16, c: const Color(0xFFF2AD25))),
                        Text('3 venues · 2 coaches · 1 tournament', style: _body(12)),
                      ])),
                      const Icon(Icons.chevron_right, color: Color(0xFFF2AD25), size: 20),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),

                Text('PLATFORM HEALTH', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                const SizedBox(height: 10),
                ...[
                  ('App Uptime',       0.998, '99.8%'),
                  ('API Response',     0.92,  '124ms avg'),
                  ('Booking Success',  0.972, '97.2%'),
                  ('Payment Success',  0.989, '98.9%'),
                ].map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Row(children: [
                    Text(m.$1, style: _body(13, c: Colors.white.withValues(alpha: 0.7))),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: m.$2,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(m.$2 > 0.95 ? _kLime : const Color(0xFFF2AD25)),
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(m.$3, style: _head(14, c: m.$2 > 0.95 ? _kLime : const Color(0xFFF2AD25))),
                  ]),
                )),
                const SizedBox(height: 20),

                // Quick actions row
                Row(children: [
                  Text('QUICK ACTIONS', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _QuickAction(icon: Icons.verified_outlined,       label: 'Approvals',   color: const Color(0xFFF2AD25), onTap: () => context.go('/approvals')),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.emoji_events_outlined,   label: 'Tournaments', color: const Color(0xFF3A8DCC), onTap: () => context.go('/tournaments')),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.campaign_outlined,       label: 'Banners',     color: _kLime,                 onTap: () => context.go('/banners')),
                  const SizedBox(width: 8),
                  _QuickAction(icon: Icons.notifications_outlined,  label: 'Push',        color: const Color(0xFF58B48F), onTap: () => context.go('/notifications')),
                ]),
                const SizedBox(height: 20),

                Text('RECENT ACTIVITY', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                const SizedBox(height: 10),
                ...[
                  ('New venue registered',   'Koramangala Sports Hub', '2m ago',  Icons.stadium_outlined,      Color(0xFF3A8DCC), '/approvals'),
                  ('Booking spike detected', '34 bookings in 10 min',  '8m ago',  Icons.trending_up,           _kLime,            '/analytics'),
                  ('Coach approved',         'Suresh Phogat — BWF L2', '15m ago', Icons.check_circle_outline,  Color(0xFF58B48F), '/approvals'),
                  ('Payout processed',       '₹12,400 to 6 vendors',   '1h ago',  Icons.payments_outlined,     Color(0xFF58B48F), '/analytics'),
                ].map((a) => GestureDetector(
                  onTap: () => context.go(a.$6),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: a.$5.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(a.$4, color: a.$5, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.$1, style: _body(13, c: Colors.white)),
                        Text(a.$2, style: _body(11)),
                      ])),
                      Text(a.$3, style: _body(10)),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2), size: 14),
                    ]),
                  ),
                )),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _AdminKpi extends StatelessWidget {
  const _AdminKpi({required this.label, required this.value, required this.change, required this.positive, this.onTap});
  final String label, value, change;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _body(11)),
          const SizedBox(height: 4),
          Text(value, style: _head(28)),
          Text(change, style: _body(10, c: positive ? const Color(0xFF58B48F) : const Color(0xFFE34B34))),
        ]),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: _body(9, c: color)),
        ]),
      ),
    ),
  );
}
