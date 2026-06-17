import 'package:flutter/material.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [0.4, 0.6, 0.5, 0.8, 0.7, 1.0, 0.9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('REVENUE ANALYTICS', style: _head(28, c: _kBlue)),
            const SizedBox(height: 4),
            Text('This week · Feather Touch Arena', style: _body(13)),
            const SizedBox(height: 20),

            // Weekly total
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kBlue.withValues(alpha: 0.12), Colors.transparent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('WEEKLY REVENUE', style: _body(11, c: _kBlue)),
                  Text('₹28,400', style: _head(48, c: Colors.white)),
                  Text('+8% vs last week', style: _body(12, c: const Color(0xFF58B48F))),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('AVG/DAY', style: _body(10)),
                  Text('₹4,057', style: _head(22)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            Text('DAILY REVENUE', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 12),

            // Bar chart
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final v = _values[i];
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('₹${(v * 5000).round()}',
                            style: _body(8, c: Colors.white.withValues(alpha: 0.3))),
                        const SizedBox(height: 4),
                        Container(
                          height: v * 100,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_kBlue, _kBlue.withValues(alpha: 0.3)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_days[i], style: _body(10, c: i == 5 ? Colors.white : Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            Text('REVENUE BY COURT', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ...const [
              ('Court A', 12400, 0.44, Color(0xFF00B4B4)),
              ('Football Turf', 9600, 0.34, Color(0xFF1B5E20)),
              ('Court B', 4200, 0.15, Color(0xFF7B2FBE)),
              ('Basketball', 2200, 0.07, Color(0xFFE65100)),
            ].map((d) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(children: [
                Container(width: 3, height: 32, decoration: BoxDecoration(color: d.$4, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.$1, style: _head(15)),
                  LinearProgressIndicator(
                    value: d.$3,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(d.$4),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ])),
                const SizedBox(width: 12),
                Text('₹${d.$2}', style: _head(16, c: _kBlue)),
              ]),
            )),
          ]),
        ),
      ),
    );
  }
}
