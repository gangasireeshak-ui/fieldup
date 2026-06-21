import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: sz,
      fontWeight: FontWeight.w800,
      color: c,
      letterSpacing: -0.5,
      height: 1.0,
    );

TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
      fontFamily: 'Inter',
      fontSize: sz,
      fontWeight: FontWeight.w500,
      color: c,
    );

BoxDecoration _glass({double radius = 14}) => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    );

// ─── Add Venue Screen ─────────────────────────────────────────────────────────

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  final Set<String> _selectedSports = {};
  final List<_CourtEntry> _courts = [];
  final Set<String> _amenities = {};
  bool _submitted = false;

  static const _allSports = [
    'Badminton', 'Cricket', 'Football', 'Basketball',
    'Tennis', 'Volleyball', 'Pickleball', 'Paddle Ball',
  ];
  static const _allAmenities = [
    'Parking', 'Changing Rooms', 'Lights', 'Cafeteria',
    'First Aid', 'Wi-Fi', 'Restrooms', 'Equipment Rental',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _addCourt() {
    setState(() => _courts.add(_CourtEntry()));
  }

  void _removeCourt(int i) {
    HapticFeedback.lightImpact();
    setState(() => _courts.removeAt(i));
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _addressCtrl.text.trim().isNotEmpty &&
      _selectedSports.isNotEmpty &&
      _courts.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    HapticFeedback.heavyImpact();
    setState(() => _submitted = true);

    // TODO: persist to Supabase via repository
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_nameCtrl.text.trim()} submitted for review',
              style: _body(13, c: Colors.black),
            ),
            backgroundColor: _kLime,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/arena');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/arena'),
                    child: Container(
                      width: 36, height: 36,
                      alignment: Alignment.center,
                      decoration: _glass(radius: 10),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ADD VENUE', style: _head(22, c: _kBlue)),
                    Text('Submit for admin review', style: _body(11)),
                  ]),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('VENUE DETAILS'),
                    const SizedBox(height: 10),
                    _Field(controller: _nameCtrl, hint: 'Venue name *', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 10),
                    _Field(controller: _addressCtrl, hint: 'Street address *', onChanged: (_) => setState(() {})),
                    const SizedBox(height: 10),
                    _Field(controller: _cityCtrl, hint: 'City'),
                    const SizedBox(height: 10),
                    _Field(controller: _descCtrl, hint: 'Description (optional)', maxLines: 3),
                    const SizedBox(height: 10),
                    _Field(
                      controller: _priceCtrl,
                      hint: 'Base price per hour (₹)',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),
                    _SectionLabel('SPORTS AVAILABLE *'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _allSports.map((s) {
                        final active = _selectedSports.contains(s);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => active ? _selectedSports.remove(s) : _selectedSports.add(s));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? _kBlue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? _kBlue.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(s, style: _body(12, c: active ? _kBlue : Colors.white.withValues(alpha: 0.6))),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _SectionLabel('COURTS *'),
                        const Spacer(),
                        GestureDetector(
                          onTap: _addCourt,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _kBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _kBlue.withValues(alpha: 0.4)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.add, color: _kBlue, size: 14),
                              const SizedBox(width: 4),
                              Text('ADD COURT', style: _body(11, c: _kBlue)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_courts.isEmpty)
                      Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: _glass(),
                        child: Text('Tap ADD COURT to configure courts', style: _body(12)),
                      )
                    else
                      ..._courts.asMap().entries.map((e) =>
                          _CourtCard(
                            index: e.key,
                            entry: e.value,
                            onRemove: () => _removeCourt(e.key),
                            sports: _selectedSports.toList(),
                            onChanged: () => setState(() {}),
                          )),

                    const SizedBox(height: 24),
                    _SectionLabel('AMENITIES'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _allAmenities.map((a) {
                        final active = _amenities.contains(a);
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => active ? _amenities.remove(a) : _amenities.add(a));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: active ? _kLime.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? _kLime.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              if (active) ...[
                                const Icon(Icons.check, color: _kLime, size: 12),
                                const SizedBox(width: 4),
                              ],
                              Text(a, style: _body(12, c: active ? _kLime : Colors.white.withValues(alpha: 0.6))),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Submit bar ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: GestureDetector(
                onTap: _canSubmit && !_submitted ? _submit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canSubmit && !_submitted
                        ? _kBlue
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _canSubmit && !_submitted
                        ? [BoxShadow(color: _kBlue.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))]
                        : null,
                  ),
                  child: _submitted
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'SUBMIT FOR REVIEW →',
                          style: _head(17,
                              c: _canSubmit ? Colors.white : Colors.white.withValues(alpha: 0.25)),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Court entry model + card ─────────────────────────────────────────────────

class _CourtEntry {
  final nameCtrl = TextEditingController();
  String sport = '';
  String surface = 'Synthetic';
  int capacity = 2;
  bool hasLights = false;
}

class _CourtCard extends StatefulWidget {
  const _CourtCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.sports,
    required this.onChanged,
  });
  final int index;
  final _CourtEntry entry;
  final VoidCallback onRemove;
  final List<String> sports;
  final VoidCallback onChanged;

  @override
  State<_CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<_CourtCard> {
  static const _surfaces = ['Synthetic', 'Grass', 'Hardcourt', 'Clay', 'Wooden', 'Concrete'];

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('COURT ${widget.index + 1}', style: _head(14, c: _kBlue)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onRemove,
            child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.3), size: 18),
          ),
        ]),
        const SizedBox(height: 12),
        _Field(
          controller: e.nameCtrl,
          hint: 'Court name (e.g. Court A)',
          onChanged: (_) => widget.onChanged(),
        ),
        const SizedBox(height: 10),
        // Sport dropdown
        _DropdownRow<String>(
          label: 'Sport',
          value: e.sport.isEmpty ? null : e.sport,
          items: widget.sports.isEmpty
              ? ['Select sports above']
              : widget.sports,
          onChanged: (v) => setState(() => e.sport = v ?? ''),
        ),
        const SizedBox(height: 8),
        // Surface dropdown
        _DropdownRow<String>(
          label: 'Surface',
          value: e.surface,
          items: _surfaces,
          onChanged: (v) => setState(() => e.surface = v ?? 'Synthetic'),
        ),
        const SizedBox(height: 8),
        // Capacity row
        Row(children: [
          Text('Capacity', style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() { if (e.capacity > 1) e.capacity--; }),
            child: Container(
              width: 28, height: 28,
              alignment: Alignment.center,
              decoration: _glass(radius: 8),
              child: const Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${e.capacity}', style: _head(16)),
          ),
          GestureDetector(
            onTap: () => setState(() => e.capacity++),
            child: Container(
              width: 28, height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBlue.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.add, color: _kBlue, size: 14),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        // Lights toggle
        Row(children: [
          Text('Has floodlights', style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => e.hasLights = !e.hasLights),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40, height: 22,
              decoration: BoxDecoration(
                color: e.hasLights ? _kBlue : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: e.hasLights ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 16, height: 16,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _body(11, c: Colors.white.withValues(alpha: 0.35)));
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: _body(14, c: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _body(14, c: Colors.white.withValues(alpha: 0.25)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBlue, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: DropdownButton<T>(
          value: value,
          hint: Text('Select', style: _body(12)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text('$i', style: _body(12, c: Colors.white)))).toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1A1A1A),
          underline: const SizedBox(),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.4), size: 16),
          style: _body(12, c: Colors.white),
        ),
      ),
    ]);
  }
}
