import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../providers.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

BoxDecoration _card() => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.03),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
);

// ─── Dashboard ────────────────────────────────────────────────────────────────

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(myVenuesProvider);

    return venuesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
      data: (venues) {
        final venue = venues.isNotEmpty ? venues.first : null;
        return _DashboardBody(venue: venue);
      },
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({this.venue});
  final Venue? venue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = venue != null
        ? ref.watch(venueRevenueProvider(venue!.id))
        : const AsyncValue<Map<String, dynamic>>.data({});
    final bookingsAsync = venue != null
        ? ref.watch(todaysBookingsProvider(venue!.id))
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);

    final venueName = venue?.name ?? 'Your Arena';
    final courtCount = 0; // TODO: from courts query
    final revenue = revenueAsync.asData?.value ?? {};
    final todayPaise = revenue['today_paise'] as int? ?? 0;
    final weekPaise = revenue['week_paise'] as int? ?? 0;
    final todayBookings = revenue['today_bookings'] as int? ?? 0;
    final bookings = bookingsAsync.asData?.value ?? [];

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          _VendorAppBar(
            title: 'VENUE BUSINESS OS',
            subtitle: venue?.name ?? 'Your Arena',
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Live status banner
                GestureDetector(
                  onTap: () => context.go('/arena'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_kBlue.withValues(alpha: 0.15), Colors.transparent],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: _kBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.stadium, color: _kBlue, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(venue != null ? venue!.name.toUpperCase() : 'YOUR ARENA', style: _head(18, c: _kBlue)),
                        Text('$todayBookings bookings today · ${formatRupees(todayPaise)} earned', style: _body(12)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A4A1A),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF58B48F)),
                          ),
                          child: Text(venue?.isActive == true ? 'OPEN' : 'PENDING', style: _body(10, c: const Color(0xFF58B48F))),
                        ),
                        const SizedBox(height: 6),
                        const Icon(Icons.chevron_right, color: _kBlue, size: 16),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // Revenue KPI row
                Row(children: [
                  _KpiTile(label: 'Today', value: formatRupees(todayPaise), trend: '', positive: true, onTap: () => context.go('/revenue')),
                  const SizedBox(width: 10),
                  _KpiTile(label: 'This Week', value: formatRupees(weekPaise), trend: '', positive: true, onTap: () => context.go('/revenue')),
                  const SizedBox(width: 10),
                  _KpiTile(label: 'Bookings', value: '$todayBookings', trend: 'today', positive: true, onTap: () => context.go('/bookings')),
                ]),
                const SizedBox(height: 16),

                // Court occupancy grid
                Row(children: [
                  Text('COURT OCCUPANCY', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/arena'),
                    child: Text('Manage →', style: _body(11, c: _kBlue)),
                  ),
                ]),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    _CourtStatusTile(name: 'Court A', sport: 'Badminton', status: 'Booked', pct: 0.9, color: const Color(0xFF00B4B4), onTap: () => context.go('/arena')),
                    _CourtStatusTile(name: 'Court B', sport: 'Badminton', status: 'Available', pct: 0.3, color: const Color(0xFF7B2FBE), onTap: () => context.go('/arena')),
                    _CourtStatusTile(name: 'Football Turf', sport: 'Football', status: 'Booked', pct: 0.85, color: const Color(0xFF1B5E20), onTap: () => context.go('/arena')),
                    _CourtStatusTile(name: 'Basketball', sport: 'Basketball', status: 'Available', pct: 0.1, color: const Color(0xFFE65100), onTap: () => context.go('/arena')),
                  ],
                ),
                const SizedBox(height: 16),

                // Add venue CTA
                GestureDetector(
                  onTap: () => context.go('/arena/add-venue'),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kLime.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kLime.withValues(alpha: 0.35)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add, color: _kLime, size: 16),
                      const SizedBox(width: 6),
                      Text('ADD NEW VENUE', style: _body(13, c: _kLime)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // Today's bookings
                Row(children: [
                  Text("TODAY'S BOOKINGS", style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/bookings'),
                    child: Text('View All →', style: _body(11, c: _kBlue)),
                  ),
                ]),
                const SizedBox(height: 10),
                if (bookings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _card(),
                    child: Text('No bookings today', style: _body(13, c: Colors.white.withValues(alpha: 0.4))),
                  )
                else
                  ...bookings.take(5).map((b) {
                    final slot = b['slots'] as Map? ?? {};
                    final court = slot['courts'] as Map? ?? {};
                    final user = b['users'] as Map? ?? {};
                    final amount = b['final_amount'] as int? ?? 0;
                    return GestureDetector(
                      onTap: () => context.go('/bookings'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: _card(),
                        child: Row(children: [
                          Container(width: 3, height: 36, decoration: BoxDecoration(color: _kBlue, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${user['name'] ?? 'Guest'} · ${court['name'] ?? ''}', style: _body(13, c: Colors.white)),
                            Text('${slot['start_time'] ?? ''} – ${slot['end_time'] ?? ''}', style: _body(11)),
                          ])),
                          Text(formatRupees(amount), style: _head(15, c: _kLime)),
                        ]),
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared vendor widgets ────────────────────────────────────────────────────

class _VendorAppBar extends StatelessWidget {
  const _VendorAppBar({required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kBg,
      floating: true,
      snap: true,
      expandedHeight: 0,
      titleSpacing: 16,
      title: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: _head(18, c: _kBlue)),
          Text(subtitle, style: _body(11)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go('/insights'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.person_outline, color: _kBlue, size: 18),
          ),
        ),
      ]),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value, required this.trend, required this.positive, this.onTap});
  final String label, value, trend;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: _body(10)),
            const SizedBox(height: 4),
            Text(value, style: _head(20)),
            Text(trend, style: _body(10, c: positive ? const Color(0xFF58B48F) : const Color(0xFFE34B34))),
          ]),
        ),
      ),
    );
  }
}

class _CourtStatusTile extends StatelessWidget {
  const _CourtStatusTile({required this.name, required this.sport, required this.status, required this.pct, required this.color, this.onTap});
  final String name, sport, status;
  final double pct;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(name, style: _head(13)),
            const Spacer(),
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == 'Booked' ? const Color(0xFFE34B34) : const Color(0xFF58B48F),
              ),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sport, style: _body(9, c: color)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ]),
        ]),
      ),
    );
  }
}
