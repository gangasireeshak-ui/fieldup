import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

const _kLime = AppColors.primary;
const _kBg = Colors.black;

class BookingSummaryScreen extends ConsumerWidget {
  const BookingSummaryScreen({
    super.key,
    required this.venueId,
    required this.extra,
  });
  final String venueId;
  final Map<String, dynamic> extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keys from new slot picker: court, sport, date, time, duration, price
    final court = extra['court'] as String? ?? 'Court A';
    final sport = extra['sport'] as String? ?? 'Badminton';
    final date = extra['date'] as String? ?? '—';
    final time = extra['time'] as String? ?? '—';
    final duration = extra['duration'] as String? ?? '60 min';
    final originalPrice = extra['price'] as int? ?? 0;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kLime.withValues(alpha: 0.04),
              ),
            ),
          ),

          Column(
            children: [
              // Top bar
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/venues/$venueId/slots'),
                            child: Container(
                              width: 36, height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CONFIRM BOOKING',
                                  style: TextStyle(
                                    fontFamily: 'Barlow Condensed',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _kLime,
                                    letterSpacing: -0.5,
                                  )),
                              Text('Review before you pay',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(height: 0.5, color: Colors.white.withValues(alpha: 0.06)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue hero card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF003D3D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.stadium, color: _kLime, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Feather Touch Arena',
                                      style: TextStyle(
                                        fontFamily: 'Barlow Condensed',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      )),
                                  Text('HAL Rd, Indiranagar',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.4),
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.teal500.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.teal500.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, color: AppColors.teal500, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Verified',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: AppColors.teal500,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Booking details
                      _SectionLabel('BOOKING DETAILS'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Column(
                          children: [
                            _BookingRow(icon: Icons.sports, label: 'Sport', value: sport),
                            _Divider(),
                            _BookingRow(icon: Icons.grid_view, label: 'Court', value: court),
                            _Divider(),
                            _BookingRow(icon: Icons.calendar_today, label: 'Date', value: date),
                            _Divider(),
                            _BookingRow(icon: Icons.schedule, label: 'Time', value: time),
                            _Divider(),
                            _BookingRow(icon: Icons.timer, label: 'Duration', value: duration),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Price breakdown
                      _SectionLabel('PRICE BREAKDOWN'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Column(
                          children: [
                            _PriceRow('Court fee', '₹$originalPrice',
                                valueColor: Colors.white.withValues(alpha: 0.5),
                                strikethrough: true),
                            const SizedBox(height: 8),
                            _PriceRow('Launch Offer 🎉', '−₹$originalPrice',
                                valueColor: AppColors.success),
                            const SizedBox(height: 8),
                            _PriceRow('Platform fee', '₹0',
                                valueColor: Colors.white.withValues(alpha: 0.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Container(
                                  height: 0.5, color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL PAYABLE',
                                    style: TextStyle(
                                      fontFamily: 'Barlow Condensed',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    )),
                                const Text('₹0',
                                    style: TextStyle(
                                      fontFamily: 'Barlow Condensed',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: _kLime,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 12,
                                    color: Colors.white.withValues(alpha: 0.3)),
                                const SizedBox(width: 6),
                                Text('Launch offer: Free bookings during beta.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cancellation policy
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A0800),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Free cancellation up to 2 hours before the slot.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              color: _kBg.withValues(alpha: 0.95),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Booking confirmed! Check your notifications.'),
                      backgroundColor: const Color(0xFF0D1500),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kLime,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kLime.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'CONFIRM FREE BOOKING →',
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 0.5,
        color: Colors.white.withValues(alpha: 0.06));
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              )),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value,
      {this.valueColor, this.strikethrough = false});
  final String label;
  final String value;
  final Color? valueColor;
  final bool strikethrough;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
            )),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
            decoration: strikethrough ? TextDecoration.lineThrough : null,
            decorationColor: valueColor,
          ),
        ),
      ],
    );
  }
}
