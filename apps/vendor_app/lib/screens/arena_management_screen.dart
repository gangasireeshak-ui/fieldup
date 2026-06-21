import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../providers.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// Sport → accent colour mapping
Color _sportColor(String sport) => switch (sport.toLowerCase()) {
  'badminton'  => const Color(0xFF00B4B4),
  'football'   => const Color(0xFF1B5E20),
  'basketball' => const Color(0xFFE65100),
  'cricket'    => const Color(0xFF1A4A1A),
  'tennis'     => const Color(0xFF7B2FBE),
  _            => const Color(0xFF3A8DCC),
};

class ArenaManagementScreen extends ConsumerStatefulWidget {
  const ArenaManagementScreen({super.key});
  @override
  ConsumerState<ArenaManagementScreen> createState() =>
      _ArenaManagementScreenState();
}

class _ArenaManagementScreenState extends ConsumerState<ArenaManagementScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(myVenuesProvider);
    final venue = venuesAsync.asData?.value.firstOrNull;

    final courtsAsync = venue != null
        ? ref.watch(venueCourtsFamilyProvider(venue.id))
        : const AsyncValue<List<Court>>.data([]);

    final courts = courtsAsync.asData?.value ?? [];
    // Clamp selection to valid range when courts reload
    final selIdx = _selected.clamp(0, courts.isEmpty ? 0 : courts.length - 1);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                Text('ARENA MANAGEMENT', style: _head(28, c: _kBlue)),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/arena/add-venue'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add, color: _kBlue, size: 14),
                      const SizedBox(width: 4),
                      Text('ADD VENUE', style: _head(13, c: _kBlue)),
                    ]),
                  ),
                ),
              ]),
            ),

            // Venue name subtitle
            if (venue != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(venue.name,
                    style: _body(12, c: Colors.white.withValues(alpha: 0.4))),
              ),

            const SizedBox(height: 16),

            // Court selector strip
            if (courtsAsync.isLoading)
              const SizedBox(
                height: 90,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (courts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  venue == null
                      ? 'No venue found. Add one first.'
                      : 'No courts configured yet.',
                  style: _body(13, c: Colors.white.withValues(alpha: 0.4)),
                ),
              )
            else
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final c = courts[i];
                    final color = _sportColor(c.sport);
                    final isActive = selIdx == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 120,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? color.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.07),
                          ),
                          boxShadow: isActive
                              ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: -4)]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.isActive
                                    ? const Color(0xFF58B48F)
                                    : const Color(0xFFE34B34),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: _head(14)),
                                Text(c.sport, style: _body(10, c: color)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Court detail
            if (courts.isNotEmpty && selIdx < courts.length)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _CourtDetail(
                    court: courts[selIdx],
                    onToggle: (active) async {
                      await toggleCourt(ref, courts[selIdx].id, active: active);
                      ref.invalidate(venueCourtsFamilyProvider(venue!.id));
                    },
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _CourtDetail extends StatelessWidget {
  const _CourtDetail({required this.court, required this.onToggle});
  final Court court;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final color = _sportColor(court.sport);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(court.name.toUpperCase(), style: _head(24, c: color)),
                const Spacer(),
                Switch(
                  value: court.isActive,
                  activeColor: color,
                  onChanged: onToggle,
                ),
              ]),
              Text(court.sport, style: _body(13)),
              const SizedBox(height: 16),
              if (court.capacity != null)
                _DetailRow('Capacity', '${court.capacity} players'),
              if (court.pricePerHour > 0)
                _DetailRow('Rate', '₹${court.pricePerHour ~/ 100}/hr'),
              if (court.surface != null)
                _DetailRow('Surface', court.surface!),
              _DetailRow('Lights', court.hasLights ? 'Available' : 'Not available'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text("TODAY'S SCHEDULE",
            style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
        const SizedBox(height: 10),
        ...List.generate(5, (i) {
          final h = 8 + i * 2;
          final booked = i < 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: booked
                  ? color.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: booked
                    ? color.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(children: [
              Text('$h:00 – ${h + 2}:00',
                  style: _head(16,
                      c: booked
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: booked
                      ? color.withValues(alpha: 0.15)
                      : const Color(0xFF1A4A1A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  booked ? 'BOOKED' : 'OPEN',
                  style: _body(9,
                      c: booked ? color : const Color(0xFF58B48F)),
                ),
              ),
            ]),
          );
        }),
      ],
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
      Text(label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.4))),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white)),
    ]),
  );
}
