import 'package:flutter/material.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _revenue = [0.3, 0.5, 0.45, 0.7, 0.65, 1.0];
  static const _users = [0.2, 0.35, 0.5, 0.55, 0.75, 0.9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SPORTS INTELLIGENCE', style: _head(28, c: _kLime)),
            Text('Platform analytics · Last 6 months', style: _body(12)),
            const SizedBox(height: 20),

            // Revenue chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('GROSS REVENUE', style: _body(11, c: Colors.white.withValues(alpha: 0.4))),
                  const Spacer(),
                  Text('₹14.2L', style: _head(22, c: _kLime)),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(6, (i) => Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                          height: _revenue[i] * 80,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_kLime, _kLime.withValues(alpha: 0.3)],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_months[i], style: _body(9, c: i == 5 ? Colors.white : Colors.white.withValues(alpha: 0.4))),
                      ]),
                    )),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // User growth
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('USER GROWTH', style: _body(11, c: Colors.white.withValues(alpha: 0.4))),
                  const Spacer(),
                  Text('2,847', style: _head(22, c: const Color(0xFF3A8DCC))),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(6, (i) => Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                          height: _users[i] * 60,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A8DCC).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_months[i], style: _body(9, c: Colors.white.withValues(alpha: 0.4))),
                      ]),
                    )),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            Text('PLATFORM BREAKDOWN', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 10),
            ...const [
              ('Venue Bookings', '1,247', '+28%', Color(0xFF58B48F)),
              ('Game Joins', '892', '+42%', Color(0xFF3A8DCC)),
              ('Coach Sessions', '341', '+15%', _kLime),
              ('Tournament Entries', '167', '+63%', Color(0xFFE65100)),
            ].map((d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(children: [
                Container(width: 3, height: 32, decoration: BoxDecoration(color: d.$4, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Text(d.$1, style: _body(13, c: Colors.white.withValues(alpha: 0.7))),
                const Spacer(),
                Text(d.$2, style: _head(18)),
                const SizedBox(width: 8),
                Text(d.$3, style: _body(11, c: const Color(0xFF58B48F))),
              ]),
            )),
          ]),
        ),
      ),
    );
  }
}
