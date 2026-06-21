import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../providers.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(myVenuesProvider);
    final venue = venuesAsync.asData?.value.firstOrNull;
    final bookingsAsync = venue != null
        ? ref.watch(todaysBookingsProvider(venue.id))
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);

    final bookings = bookingsAsync.asData?.value ?? [];
    final totalRevPaise = bookings
        .where((b) => b['status'] == 'confirmed')
        .fold<int>(0, (s, b) => s + (b['final_amount'] as int? ?? 0));
    final pendingCount = bookings.where((b) => b['status'] == 'pending').length;

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
                // Stats row — real data
                Row(children: [
                  _BookingStat(label: 'Today', value: '${bookings.length}', sub: 'bookings'),
                  const SizedBox(width: 10),
                  _BookingStat(label: 'Revenue', value: formatRupees(totalRevPaise), sub: 'confirmed'),
                  const SizedBox(width: 10),
                  _BookingStat(label: 'Pending', value: '$pendingCount', sub: 'approval'),
                ]),
                const SizedBox(height: 20),

                Text("TODAY'S BOOKINGS",
                    style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                const SizedBox(height: 10),

                if (bookingsAsync.isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ))
                else if (bookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Center(
                      child: Text('No bookings today', style: _body(13)),
                    ),
                  )
                else
                  ...bookings.map((b) => _BookingCard(booking: b)),

                const SizedBox(height: 80),
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
  final Map<String, dynamic> booking;

  Color get _statusColor => switch (booking['status'] as String? ?? '') {
    'confirmed' => const Color(0xFF58B48F),
    'pending'   => const Color(0xFFF2AD25),
    _           => const Color(0xFFE34B34),
  };

  @override
  Widget build(BuildContext context) {
    final slot    = booking['slots']  as Map?  ?? {};
    final court   = slot['courts']    as Map?  ?? {};
    final user    = booking['users']  as Map?  ?? {};
    final amount  = booking['final_amount'] as int? ?? 0;
    final status  = booking['status'] as String? ?? '';
    final player  = user['name'] as String? ?? 'Guest';
    final courtName = court['name'] as String? ?? '';
    final sport   = court['sport'] as String? ?? '';
    final start   = slot['start_time'] as String? ?? '';
    final end     = slot['end_time']   as String? ?? '';

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
            Text(player, style: _head(16)),
            const Spacer(),
            Text(formatRupees(amount), style: _head(16, c: _kBlue)),
          ]),
          const SizedBox(height: 3),
          Text('$start–$end · $courtName · $sport',
              style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
        ])),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(status.toUpperCase(), style: _body(9, c: _statusColor)),
        ),
      ]),
    );
  }
}
