import 'package:flutter/material.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  static const _bookings = [
    (time: '09:00 AM', player: 'Rahul Sharma', court: 'Court A', sport: 'Badminton', amount: 600, status: 'confirmed'),
    (time: '11:30 AM', player: 'Priya Kumar', court: 'Football Turf', sport: 'Football', amount: 1200, status: 'confirmed'),
    (time: '02:00 PM', player: 'Amit Roy', court: 'Court A', sport: 'Badminton', amount: 600, status: 'pending'),
    (time: '04:30 PM', player: 'Sneha Patel', court: 'Basketball', sport: 'Basketball', amount: 800, status: 'confirmed'),
    (time: '06:00 PM', player: 'Dev Nair', court: 'Court B', sport: 'Badminton', amount: 600, status: 'cancelled'),
    (time: '08:00 PM', player: 'Riya Singh', court: 'Football Turf', sport: 'Football', amount: 1200, status: 'confirmed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _kBg,
            floating: true,
            titleSpacing: 16,
            title: Text('BOOKING COMMAND CENTER', style: _head(22, c: _kBlue)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                Row(children: [
                  _BookingStat(label: 'Today', value: '6', sub: 'bookings'),
                  const SizedBox(width: 10),
                  _BookingStat(label: 'Revenue', value: '₹5,000', sub: 'today'),
                  const SizedBox(width: 10),
                  _BookingStat(label: 'Pending', value: '1', sub: 'approval'),
                ]),
                const SizedBox(height: 20),
                Text('TODAY\'S BOOKINGS', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                const SizedBox(height: 10),
                ..._bookings.map((b) => _BookingCard(booking: b)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStat extends StatelessWidget {
  const _BookingStat({required this.label, required this.value, required this.sub});
  final String label, value, sub;
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
        Text(label, style: _body(10)),
        const SizedBox(height: 2),
        Text(value, style: _head(22)),
        Text(sub, style: _body(9)),
      ]),
    ),
  );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final ({String time, String player, String court, String sport, int amount, String status}) booking;

  Color get _statusColor => switch (booking.status) {
    'confirmed' => const Color(0xFF58B48F),
    'pending' => const Color(0xFFF2AD25),
    _ => const Color(0xFFE34B34),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(children: [
        Container(
          width: 3, height: 44,
          decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(booking.player, style: _head(16)),
            const Spacer(),
            Text('₹${booking.amount}', style: _head(16, c: _kBlue)),
          ]),
          const SizedBox(height: 3),
          Text('${booking.time} · ${booking.court} · ${booking.sport}',
              style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
        ])),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(booking.status.toUpperCase(), style: _body(9, c: _statusColor)),
        ),
      ]),
    );
  }
}
