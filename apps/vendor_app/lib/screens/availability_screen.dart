import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// ─── Smart Availability Planner ───────────────────────────────────────────────

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});
  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  int _dayOffset = 0;
  final Set<String> _blocked = {'Court A_9', 'Court A_10', 'Football Turf_18', 'Football Turf_19'};

  static const _courts = ['Court A', 'Court B', 'Football Turf', 'Basketball'];
  static const _hours = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21];
  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AVAILABILITY PLANNER', style: _head(28, c: _kBlue)),
                Text('Tap to block / unblock slots', style: _body(12)),
              ]),
            ),

            // Day strip
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _dayOffset;
                  return GestureDetector(
                    onTap: () => setState(() => _dayOffset = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      decoration: BoxDecoration(
                        color: active ? _kBlue.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? _kBlue.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.07)),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(_days[i], style: _body(9, c: active ? _kBlue : Colors.white.withValues(alpha: 0.4))),
                        Text('${i + 6}', style: _head(18, c: active ? _kBlue : Colors.white)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      const SizedBox(width: 100),
                      ..._hours.map((h) => SizedBox(
                        width: 40,
                        child: Text(
                          h < 12 ? '${h}A' : h == 12 ? '12P' : '${h - 12}P',
                          style: _body(9, c: Colors.white.withValues(alpha: 0.3)),
                          textAlign: TextAlign.center,
                        ),
                      )),
                    ]),
                    const SizedBox(height: 6),
                    // Court rows
                    ..._courts.map((court) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        SizedBox(
                          width: 100,
                          child: Text(court, style: _body(11, c: Colors.white.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                        ),
                        ..._hours.map((h) {
                          final key = '${court}_$h';
                          final blocked = _blocked.contains(key);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                if (blocked) _blocked.remove(key); else _blocked.add(key);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 36,
                              height: 32,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: blocked
                                    ? const Color(0xFFE34B34).withValues(alpha: 0.3)
                                    : _kBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: blocked
                                      ? const Color(0xFFE34B34).withValues(alpha: 0.5)
                                      : _kBlue.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                          );
                        }),
                      ]),
                    )),
                  ],
                ),
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _Legend(color: _kBlue.withValues(alpha: 0.3), label: 'Available'),
                const SizedBox(width: 16),
                _Legend(color: const Color(0xFFE34B34).withValues(alpha: 0.5), label: 'Blocked'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
  ]);
}
