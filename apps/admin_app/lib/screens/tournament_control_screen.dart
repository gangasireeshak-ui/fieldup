import 'package:flutter/material.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class TournamentControlScreen extends StatelessWidget {
  const TournamentControlScreen({super.key});
  static const _tournaments = [
    (name: 'JP Nagar Badminton Open', sport: 'Badminton', teams: 16, start: 'Jun 15', status: 'registration', color: Color(0xFF00B4B4)),
    (name: 'Bangalore Football Cup', sport: 'Football', teams: 8, start: 'Jun 22', status: 'approved', color: Color(0xFF1B5E20)),
    (name: 'Corporate Cricket T10', sport: 'Cricket', teams: 12, start: 'Jul 5', status: 'pending', color: Color(0xFF1A4A1A)),
    (name: 'HSR Basketball 3x3', sport: 'Basketball', teams: 8, start: 'Jul 12', status: 'draft', color: Color(0xFFE65100)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TOURNAMENT CONTROL', style: _head(28, c: _kLime)),
                  Text('4 active tournaments', style: _body(12)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                  ),
                  child: Text('+ NEW', style: _head(13, c: _kLime)),
                ),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tournaments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final t = _tournaments[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.color.withValues(alpha: 0.25)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(t.name, style: _head(18))),
                        _StatusBadge(status: t.status),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.sports, color: t.color, size: 13),
                        const SizedBox(width: 5),
                        Text(t.sport, style: _body(11, c: t.color)),
                        const SizedBox(width: 12),
                        Icon(Icons.groups, color: Colors.white.withValues(alpha: 0.4), size: 13),
                        const SizedBox(width: 5),
                        Text('${t.teams} teams', style: _body(11)),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.4), size: 13),
                        const SizedBox(width: 5),
                        Text(t.start, style: _body(11)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Container(
                          height: 36, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text('VIEW FIXTURES', style: _body(11, c: Colors.white.withValues(alpha: 0.6))),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: Container(
                          height: 36, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: t.color.withValues(alpha: 0.4)),
                          ),
                          child: Text('MANAGE', style: _body(11, c: t.color)),
                        )),
                      ]),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  Color get _color => switch (status) {
    'approved' || 'live' => const Color(0xFF58B48F),
    'registration' => const Color(0xFFF2AD25),
    'pending' => const Color(0xFF3A8DCC),
    _ => const Color(0xFF9E9E9E),
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _color.withValues(alpha: 0.4)),
    ),
    child: Text(status.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
  );
}
