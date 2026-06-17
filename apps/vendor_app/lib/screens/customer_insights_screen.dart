import 'package:flutter/material.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class CustomerInsightsScreen extends StatelessWidget {
  const CustomerInsightsScreen({super.key});

  static const _sports = [
    ('Badminton', 0.48, Color(0xFF00B4B4)),
    ('Football', 0.32, Color(0xFF1B5E20)),
    ('Basketball', 0.12, Color(0xFFE65100)),
    ('Others', 0.08, Color(0xFF7B2FBE)),
  ];

  static const _times = [
    ('Morning 6–10 AM', 0.2, '68 bookings'),
    ('Peak 10 AM–4 PM', 0.55, '187 bookings'),
    ('Evening 4–8 PM', 0.9, '305 bookings'),
    ('Night 8–11 PM', 0.45, '153 bookings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CUSTOMER INSIGHTS', style: _head(28, c: _kBlue)),
            const SizedBox(height: 4),
            Text('Understand your players', style: _body(13)),
            const SizedBox(height: 20),

            // Top stats
            Row(children: [
              _InsightTile(label: 'Total Players', value: '248', icon: Icons.people),
              const SizedBox(width: 10),
              _InsightTile(label: 'Repeat Rate', value: '64%', icon: Icons.refresh),
              const SizedBox(width: 10),
              _InsightTile(label: 'Avg Spend', value: '₹720', icon: Icons.payments_outlined),
            ]),
            const SizedBox(height: 20),

            Text('SPORT PREFERENCE', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ..._sports.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.$3.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: s.$3.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                SizedBox(width: 100, child: Text(s.$1, style: _body(12, c: Colors.white.withValues(alpha: 0.8)))),
                Expanded(child: LinearProgressIndicator(
                  value: s.$2,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(s.$3),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 10),
                Text('${(s.$2 * 100).round()}%', style: _head(14, c: s.$3)),
              ]),
            )),
            const SizedBox(height: 16),

            Text('PEAK HOURS', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ..._times.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.$1, style: _body(12, c: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: t.$2,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(t.$2 > 0.7 ? _kBlue : _kBlue.withValues(alpha: 0.5)),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ])),
                const SizedBox(width: 12),
                Text(t.$3, style: _body(11)),
              ]),
            )),
          ]),
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.label, required this.value, required this.icon});
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
        Icon(icon, color: _kBlue, size: 18),
        const SizedBox(height: 6),
        Text(value, style: _head(22)),
        Text(label, style: _body(9)),
      ]),
    ),
  );
}
