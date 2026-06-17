import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kLime = AppColors.primary;
const _kBg = Colors.black;

// ─── Mock court data ──────────────────────────────────────────────────────────

class _Court {
  const _Court({
    required this.id,
    required this.name,
    required this.sport,
    required this.color,
    required this.pricePerHour,
    this.occupancy = const [],
  });

  final int id;
  final String name;
  final String sport;
  final Color color;
  final int pricePerHour; // INR
  final List<_OccupiedSlot> occupancy;
}

class _OccupiedSlot {
  const _OccupiedSlot(this.startHour, this.endHour, {this.label = ''});
  final double startHour;
  final double endHour;
  final String label;
}

final _mockCourts = [
  const _Court(
    id: 0, name: 'Court A', sport: 'Badminton', color: Color(0xFF00B4B4),
    pricePerHour: 600,
    occupancy: [_OccupiedSlot(8, 9), _OccupiedSlot(11, 12.5, label: 'Club Practice')],
  ),
  const _Court(
    id: 1, name: 'Court B', sport: 'Badminton', color: Color(0xFF7B2FBE),
    pricePerHour: 600,
    occupancy: [_OccupiedSlot(9.5, 11), _OccupiedSlot(14, 16)],
  ),
  const _Court(
    id: 2, name: 'Football Turf', sport: 'Football', color: Color(0xFF1B5E20),
    pricePerHour: 1200,
    occupancy: [_OccupiedSlot(7, 8), _OccupiedSlot(18, 20, label: 'Evening League')],
  ),
  const _Court(
    id: 3, name: 'Basketball', sport: 'Basketball', color: Color(0xFFE65100),
    pricePerHour: 800,
    occupancy: [_OccupiedSlot(10, 11.5)],
  ),
];

// ─── SlotPickerScreen ─────────────────────────────────────────────────────────

class SlotPickerScreen extends ConsumerStatefulWidget {
  const SlotPickerScreen({super.key, required this.venueId});
  final String venueId;

  @override
  ConsumerState<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends ConsumerState<SlotPickerScreen>
    with SingleTickerProviderStateMixin {
  // Date
  int _selectedDayOffset = 0;
  final _baseDate = DateTime(2026, 5, 6);
  DateTime get _selectedDate => _baseDate.add(Duration(days: _selectedDayOffset));

  // Court selection
  int? _selectedCourt;

  // Timeline drag selection
  double _dragStart = 9.0;  // hour (9.0 = 9:00 AM)
  double _dragEnd = 10.0;   // hour

  bool _isDragging = false;
  double _dragStartX = 0;

  // Timeline config
  static const _timelineStart = 6.0;  // 6 AM
  static const _timelineEnd = 22.0;   // 10 PM
  static const _timelineHours = _timelineEnd - _timelineStart; // 16 hours

  // Computed
  int get _durationMins => ((_dragEnd - _dragStart) * 60).round();
  int get _price {
    if (_selectedCourt == null) return 0;
    final court = _mockCourts[_selectedCourt!];
    return (court.pricePerHour * (_dragEnd - _dragStart)).round();
  }

  String _formatHour(double h) {
    final hr = h.floor();
    final min = ((h - hr) * 60).round();
    final suffix = hr < 12 ? 'AM' : 'PM';
    final displayHr = hr > 12 ? hr - 12 : (hr == 0 ? 12 : hr);
    return min == 0 ? '$displayHr $suffix' : '$displayHr:${min.toString().padLeft(2, '0')} $suffix';
  }

  bool _isOccupied(int courtId, double hour) {
    final court = _mockCourts[courtId];
    return court.occupancy.any((s) => hour >= s.startHour && hour < s.endHour);
  }

  bool _slotConflicts(int courtId, double start, double end) {
    final court = _mockCourts[courtId];
    return court.occupancy.any((s) => start < s.endHour && end > s.startHour);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Background glow ──────────────────────────────────────────────
          if (_selectedCourt != null)
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _mockCourts[_selectedCourt!].color.withValues(alpha: 0.08),
                ),
              ),
            ),

          Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildDateStrip(),
                      const SizedBox(height: 24),
                      _buildArenaMap(),
                      const SizedBox(height: 24),
                      if (_selectedCourt != null) ...[
                        _buildTimeline(),
                        const SizedBox(height: 24),
                        _buildLiveOccupancy(),
                        const SizedBox(height: 24),
                        _buildBookingSummaryPanel(),
                      ] else
                        _buildSelectCourtHint(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Floating CTA ─────────────────────────────────────────────────
          if (_selectedCourt != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCTA(context),
            ),
        ],
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _kBg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/venues/${widget.venueId}'),
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
                      const Text('BOOK COURT',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _kLime,
                            letterSpacing: -0.5,
                          )),
                      Text('Feather Touch Arena',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                          )),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1500),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kLime,
                            boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.8), blurRadius: 6)],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('4 courts live',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kLime,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: Colors.white.withValues(alpha: 0.06)),
          ],
        ),
      ),
    );
  }

  // ── Date Strip ───────────────────────────────────────────────────────────────
  Widget _buildDateStrip() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT DATE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.3),
            )),
        const SizedBox(height: 10),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = _baseDate.add(Duration(days: i));
              final isSelected = i == _selectedDayOffset;
              final isToday = i == 0;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayOffset = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kLime.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _kLime.withValues(alpha: 0.6)
                          : isToday
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[d.weekday - 1],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _kLime : Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontFamily: 'Barlow Condensed',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? _kLime : Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Arena Map ────────────────────────────────────────────────────────────────
  Widget _buildArenaMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('ARENA MAP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.3),
                )),
            const Spacer(),
            Text('Tap a court to select',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.25),
                )),
          ],
        ),
        const SizedBox(height: 12),
        // Visual arena layout
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF060F06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Stack(
            children: [
              // Arena floor texture lines
              ...List.generate(4, (i) => Positioned(
                top: 20 + i * 44.0,
                left: 0,
                right: 0,
                child: Container(
                  height: 0.3,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              )),
              // Courts grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: _mockCourts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final court = entry.value;
                    final isSelected = _selectedCourt == i;
                    final availPct = _courtAvailability(i);

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < _mockCourts.length - 1 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedCourt = isSelected ? null : i;
                              if (_selectedCourt != null) {
                                // Snap to first available slot
                                _dragStart = 9.0;
                                _dragEnd = 10.0;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutExpo,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? court.color.withValues(alpha: 0.25)
                                  : court.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? court.color.withValues(alpha: 0.9)
                                    : court.color.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(
                                      color: court.color.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: -4,
                                    )]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Occupancy arc indicator
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        value: availPct,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.white.withValues(alpha: 0.07),
                                        color: isSelected ? court.color : court.color.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      '${(availPct * 100).round()}%',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  court.name,
                                  style: TextStyle(
                                    fontFamily: 'Barlow Condensed',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  court.sport,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    color: isSelected
                                        ? court.color
                                        : court.color.withValues(alpha: 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // "ARENA" watermark
              Center(
                child: Text(
                  'ARENA',
                  style: TextStyle(
                    fontFamily: 'Barlow Condensed',
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.02),
                    letterSpacing: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _courtAvailability(int courtId) {
    final court = _mockCourts[courtId];
    double occupied = 0;
    for (final s in court.occupancy) {
      occupied += s.endHour - s.startHour;
    }
    return 1.0 - (occupied / _timelineHours).clamp(0, 1);
  }

  // ── Timeline + Duration Selector ─────────────────────────────────────────────
  Widget _buildTimeline() {
    final court = _mockCourts[_selectedCourt!];
    final hasConflict = _slotConflicts(_selectedCourt!, _dragStart, _dragEnd);

    // Available start slots: every 30 min from 6AM to 9:30PM
    final slots = <double>[];
    for (double h = _timelineStart; h <= _timelineEnd - 0.5; h += 0.5) {
      slots.add(h);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text('SELECT START TIME',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.3),
                )),
            const Spacer(),
            if (!hasConflict)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kLime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${_formatHour(_dragStart)} – ${_formatHour(_dragEnd)}',
                  style: const TextStyle(
                    fontFamily: 'Barlow Condensed', fontSize: 14,
                    fontWeight: FontWeight.w700, color: _kLime,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Text('Slot taken',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12,
                      color: AppColors.error,
                    )),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Visual timeline strip — tap to pick start
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              // Hour axis labels
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final w = constraints.maxWidth;
                    return SizedBox(
                      height: 14,
                      child: Stack(
                        children: [
                          for (double h = _timelineStart; h <= _timelineEnd; h += 2)
                            Positioned(
                              left: _hourToPixel(h, w) - 10,
                              child: Text(
                                h < 12 ? '${h.toInt()}A' : h == 12 ? '12P' : '${(h - 12).toInt()}P',
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Tap track
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final w = constraints.maxWidth;
                    return GestureDetector(
                      onTapDown: (d) {
                        final h = _snapHour(_pixelToHour(d.localPosition.dx, w));
                        if (!_isOccupied(_selectedCourt!, h)) {
                          setState(() {
                            _dragStart = h.clamp(_timelineStart, _timelineEnd - 0.5);
                            _dragEnd = (_dragStart + (_dragEnd - _dragStart))
                                .clamp(_timelineStart + 0.5, _timelineEnd);
                          });
                        }
                      },
                      onHorizontalDragUpdate: (d) {
                        final h = _snapHour(
                            _pixelToHour(d.localPosition.dx, w)
                                .clamp(_timelineStart, _timelineEnd - 0.5));
                        if (!_isOccupied(_selectedCourt!, h)) {
                          setState(() {
                            final dur = _dragEnd - _dragStart;
                            _dragStart = h;
                            _dragEnd = (h + dur).clamp(_timelineStart + 0.5, _timelineEnd);
                          });
                        }
                      },
                      child: SizedBox(
                        height: 52,
                        width: w,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Base track
                            Positioned(
                              top: 18, left: 0, right: 0,
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            // Occupied zones
                            ...court.occupancy.map((s) {
                              final left = _hourToPixel(s.startHour, w).clamp(0.0, w);
                              final right = _hourToPixel(s.endHour, w).clamp(0.0, w);
                              final slotW = (right - left).toDouble();
                              return Positioned(
                                top: 18,
                                left: left,
                                child: Container(
                                  width: slotW,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: s.label.isNotEmpty
                                      ? Text(s.label,
                                          style: const TextStyle(
                                            fontFamily: 'Inter', fontSize: 8, color: Colors.white),
                                          overflow: TextOverflow.clip)
                                      : null,
                                ),
                              );
                            }),
                            // Selected range
                            Builder(builder: (_) {
                              final left = _hourToPixel(_dragStart, w).clamp(0.0, w);
                              final right = _hourToPixel(_dragEnd, w).clamp(0.0, w);
                              final rangeW = (right - left).clamp(0.0, w);
                              final borderColor = hasConflict
                                  ? AppColors.error.withValues(alpha: _isDragging ? 1.0 : 0.8)
                                  : _kLime.withValues(alpha: _isDragging ? 1.0 : 0.8);
                              return Positioned(
                                top: 14,
                                left: left,
                                child: Container(
                                  width: rangeW,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: hasConflict
                                        ? AppColors.error.withValues(alpha: 0.25)
                                        : _kLime.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: borderColor),
                                    boxShadow: [
                                      BoxShadow(
                                        color: hasConflict
                                            ? AppColors.error.withValues(alpha: 0.2)
                                            : _kLime.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Start handle
                            Positioned(
                              top: 12,
                              left: (_hourToPixel(_dragStart, w) - 5).clamp(0.0, w - 10),
                              child: Container(
                                width: 10, height: 28,
                                decoration: BoxDecoration(
                                  color: _kLime,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(color: _kLime.withValues(alpha: 0.7), blurRadius: 8)
                                  ],
                                ),
                              ),
                            ),
                            // End handle
                            Positioned(
                              top: 12,
                              left: (_hourToPixel(_dragEnd, w) - 5).clamp(0.0, w - 10),
                              child: Container(
                                width: 10, height: 28,
                                decoration: BoxDecoration(
                                  color: _kLime.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            // "Now" indicator (10 AM for demo)
                            Positioned(
                              top: 10,
                              left: _hourToPixel(10.0, w) - 1,
                              child: Container(
                                width: 2, height: 32,
                                color: const Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Legend
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    _LegendDot(color: _kLime, label: 'Your slot'),
                    const SizedBox(width: 14),
                    _LegendDot(color: AppColors.error, label: 'Booked'),
                    const SizedBox(width: 14),
                    _LegendDot(color: const Color(0xFFFF6B35), label: 'Now'),
                    const Spacer(),
                    Text('Tap timeline to move slot',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.2),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (hasConflict)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.error, size: 14),
                const SizedBox(width: 6),
                Text('Slot overlaps a booking. Pick a different time.',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11, color: AppColors.error)),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // ── Duration chips ────────────────────────────────────────────────────
        Text('DURATION',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.3),
            )),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [30, 60, 90, 120, 150, 180].map((mins) {
            final hours = mins / 60.0;
            final proposedEnd = _dragStart + hours;
            final isActive = _durationMins == mins;
            final wouldConflict = _slotConflicts(_selectedCourt!, _dragStart, proposedEnd)
                || proposedEnd > _timelineEnd;
            return GestureDetector(
              onTap: wouldConflict ? null : () {
                setState(() => _dragEnd = (_dragStart + hours).clamp(_timelineStart + 0.5, _timelineEnd));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? _kLime.withValues(alpha: 0.15)
                      : wouldConflict
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? _kLime.withValues(alpha: 0.7)
                        : wouldConflict
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mins < 60 ? '${mins}m'
                          : mins == 60 ? '1h'
                          : mins % 60 == 0 ? '${mins ~/ 60}h'
                          : '${mins ~/ 60}h ${mins % 60}m',
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? _kLime
                            : wouldConflict
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!wouldConflict) ...[
                      const SizedBox(height: 2),
                      Text(
                        '₹${(court.pricePerHour * hours).round()}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: isActive ? _kLime.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  double _pixelToHour(double px, double totalWidth) {
    return _timelineStart + (px / totalWidth) * _timelineHours;
  }

  double _hourToPixel(double hour, double totalWidth) {
    return ((hour - _timelineStart) / _timelineHours) * totalWidth;
  }

  double _snapHour(double h) {
    return (h * 2).round() / 2.0;
  }

  // ── Live Occupancy ───────────────────────────────────────────────────────────
  Widget _buildLiveOccupancy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LIVE OCCUPANCY TODAY',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.3),
            )),
        const SizedBox(height: 10),
        ..._mockCourts.asMap().entries.map((entry) {
          final i = entry.key;
          final court = entry.value;
          final avail = _courtAvailability(i);
          final isSelected = _selectedCourt == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCourt = isSelected ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? court.color.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? court.color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: court.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(court.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
                        Text(court.sport,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                            )),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${court.pricePerHour}/hr',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? _kLime : Colors.white,
                          )),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                          value: avail,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(
                            avail > 0.5
                                ? _kLime
                                : avail > 0.25
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          minHeight: 3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('${(avail * 100).round()}% available',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: Colors.white.withValues(alpha: 0.3),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Booking Summary Panel ────────────────────────────────────────────────────
  Widget _buildBookingSummaryPanel() {
    if (_selectedCourt == null) return const SizedBox.shrink();
    final court = _mockCourts[_selectedCourt!];
    final hasConflict = _slotConflicts(_selectedCourt!, _dragStart, _dragEnd);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasConflict
                  ? AppColors.error.withValues(alpha: 0.4)
                  : _kLime.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: court.color,
                      boxShadow: [BoxShadow(color: court.color, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(court.name,
                      style: const TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: court.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(court.sport,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: court.color,
                        )),
                  ),
                  const Spacer(),
                  Text('${_durationMins ~/ 60}h ${_durationMins % 60 > 0 ? "${_durationMins % 60}m" : ""}',
                      style: const TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 0.5, color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryRow(icon: Icons.calendar_today, label: '${_selectedDate.day}/${_selectedDate.month}/2026'),
                  const Spacer(),
                  _SummaryRow(icon: Icons.schedule, label: '${_formatHour(_dragStart)} – ${_formatHour(_dragEnd)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Court fee', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                  const Spacer(),
                  Text('₹${court.pricePerHour} × ${(_dragEnd - _dragStart).toStringAsFixed(1)}h',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Launch Offer 🎉',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.success)),
                  const Spacer(),
                  Text('−₹$_price',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('TOTAL',
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const Spacer(),
                  Text('₹0',
                      style: const TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kLime,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectCourtHint() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text('Tap a court in the arena map\nto see availability and book',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.25),
                  height: 1.5,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Floating CTA ─────────────────────────────────────────────────────────────
  Widget _buildCTA(BuildContext context) {
    final hasConflict = _slotConflicts(_selectedCourt!, _dragStart, _dragEnd);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _kBg.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: GestureDetector(
        onTap: hasConflict ? null : () {
          HapticFeedback.heavyImpact();
          context.go(
            '/venues/${widget.venueId}/booking-summary',
            extra: {
              'court': _mockCourts[_selectedCourt!].name,
              'sport': _mockCourts[_selectedCourt!].sport,
              'date': '${_selectedDate.day}/${_selectedDate.month}/2026',
              'time': '${_formatHour(_dragStart)} – ${_formatHour(_dragEnd)}',
              'duration': '$_durationMins min',
              'price': _price,
            },
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasConflict
                ? Colors.white.withValues(alpha: 0.05)
                : _kLime,
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasConflict ? null : [
              BoxShadow(
                color: _kLime.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            hasConflict ? 'SLOT UNAVAILABLE' : 'CONFIRM BOOKING → ₹0',
            style: TextStyle(
              fontFamily: 'Barlow Condensed',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: hasConflict
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.35),
            )),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.3)),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            )),
      ],
    );
  }
}
