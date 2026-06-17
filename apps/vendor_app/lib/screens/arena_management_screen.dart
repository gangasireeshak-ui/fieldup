import 'package:flutter/material.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// ─── Arena Management ─────────────────────────────────────────────────────────

class ArenaManagementScreen extends StatefulWidget {
  const ArenaManagementScreen({super.key});
  @override
  State<ArenaManagementScreen> createState() => _ArenaManagementScreenState();
}

class _ArenaManagementScreenState extends State<ArenaManagementScreen> {
  int _selected = 0;

  static const _courts = [
    (name: 'Court A', sport: 'Badminton', active: true, color: Color(0xFF00B4B4)),
    (name: 'Court B', sport: 'Badminton', active: true, color: Color(0xFF7B2FBE)),
    (name: 'Football Turf', sport: 'Football', active: true, color: Color(0xFF1B5E20)),
    (name: 'Basketball', sport: 'Basketball', active: false, color: Color(0xFFE65100)),
  ];

  @override
  Widget build(BuildContext context) {
    final court = _courts[_selected];
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('ARENA MANAGEMENT', style: _head(28, c: _kBlue)),
            ),
            const SizedBox(height: 16),
            // Court selector
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _courts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final c = _courts[i];
                  final active = _selected == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 120,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: active ? c.color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: active ? c.color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.07)),
                        boxShadow: active ? [BoxShadow(color: c.color.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: -4)] : null,
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.active ? const Color(0xFF58B48F) : const Color(0xFFE34B34),
                          ),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.name, style: _head(14)),
                          Text(c.sport, style: _body(10, c: c.color)),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Court detail card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: court.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: court.color.withValues(alpha: 0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(court.name.toUpperCase(), style: _head(24, c: court.color)),
                        const Spacer(),
                        Switch(
                          value: court.active,
                          activeColor: court.color,
                          onChanged: (_) {},
                        ),
                      ]),
                      Text(court.sport, style: _body(13)),
                      const SizedBox(height: 16),
                      _DetailRow('Capacity', '4 players'),
                      _DetailRow('Rate', '₹600/hr'),
                      _DetailRow('Surface', 'Synthetic'),
                      _DetailRow('Lights', 'Available'),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('TODAY\'S SCHEDULE', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                  const SizedBox(height: 10),
                  ...List.generate(5, (i) {
                    final h = 8 + i * 2;
                    final booked = i < 3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: booked ? court.color.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: booked ? court.color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(children: [
                        Text('$h:00 – ${h + 2}:00', style: _head(16, c: booked ? Colors.white : Colors.white.withValues(alpha: 0.3))),
                        const Spacer(),
                        if (booked) ...[
                          Text('Rahul S.', style: _body(12, c: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: court.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('BOOKED', style: _body(9, c: court.color)),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A4A1A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('OPEN', style: _body(9, c: const Color(0xFF58B48F))),
                          ),
                      ]),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.4))),
      const Spacer(),
      Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  );
}
