import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class TournamentControlScreen extends StatelessWidget {
  const TournamentControlScreen({super.key});

  static const _tournaments = [
    (name: 'JP Nagar Badminton Open', sport: 'Badminton', teams: 16, start: 'Jun 15', status: 'registration', color: Color(0xFF00B4B4)),
    (name: 'Bangalore Football Cup',  sport: 'Football',  teams: 8,  start: 'Jun 22', status: 'approved',     color: Color(0xFF1B5E20)),
    (name: 'Corporate Cricket T10',   sport: 'Cricket',   teams: 12, start: 'Jul 5',  status: 'pending',      color: Color(0xFF1A4A1A)),
    (name: 'HSR Basketball 3x3',      sport: 'Basketball',teams: 8,  start: 'Jul 12', status: 'draft',        color: Color(0xFFE65100)),
  ];

  void _showNewTournamentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _NewTournamentSheet(),
    );
  }

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
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TOURNAMENT CONTROL', style: _head(28, c: _kLime)),
                  Text('${_tournaments.length} active tournaments', style: _body(12)),
                ]),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showNewTournamentSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kLime.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add, color: _kLime, size: 14),
                      const SizedBox(width: 4),
                      Text('NEW', style: _head(13, c: _kLime)),
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tournaments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final t = _tournaments[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.color.withValues(alpha: 0.25)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(t.name, style: _head(18))),
                        _StatusBadge(status: t.status),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.sports, color: t.color, size: 13),
                        const SizedBox(width: 5),
                        Text(t.sport, style: _body(11, c: t.color)),
                        const SizedBox(width: 12),
                        Icon(Icons.groups, color: Colors.white.withValues(alpha: 0.4), size: 13),
                        const SizedBox(width: 5),
                        Text('${t.teams} teams', style: _body(11)),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.4), size: 13),
                        const SizedBox(width: 5),
                        Text(t.start, style: _body(11)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Container(
                          height: 36, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text('VIEW FIXTURES', style: _body(11, c: Colors.white.withValues(alpha: 0.6))),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: Container(
                          height: 36, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: t.color.withValues(alpha: 0.4)),
                          ),
                          child: Text('MANAGE', style: _body(11, c: t.color)),
                        )),
                      ]),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── New Tournament Sheet ─────────────────────────────────────────────────────

class _NewTournamentSheet extends StatefulWidget {
  const _NewTournamentSheet();

  @override
  State<_NewTournamentSheet> createState() => _NewTournamentSheetState();
}

class _NewTournamentSheetState extends State<_NewTournamentSheet> {
  final _nameCtrl     = TextEditingController();
  final _teamsCtrl    = TextEditingController(text: '8');
  String _sport       = 'Badminton';
  String _format      = 'Knockout';
  bool   _submitting  = false;

  static const _sports  = ['Badminton', 'Cricket', 'Football', 'Basketball', 'Tennis', 'Volleyball'];
  static const _formats = ['Knockout', 'Round Robin', 'League', 'Group + Knockout'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teamsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    HapticFeedback.heavyImpact();
    setState(() => _submitting = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tournament "${_nameCtrl.text.trim()}" created as Draft',
              style: _body(13, c: Colors.black)),
          backgroundColor: _kLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: _kLime.withValues(alpha: 0.25))),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('NEW TOURNAMENT', style: _head(22, c: _kLime)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.4), size: 20),
            ),
          ]),
          const SizedBox(height: 18),
          // Name
          _SheetField(controller: _nameCtrl, hint: 'Tournament name *'),
          const SizedBox(height: 12),
          // Sport picker
          _SheetDropdown<String>(
            label: 'Sport',
            value: _sport,
            items: _sports,
            onChanged: (v) => setState(() => _sport = v ?? _sport),
          ),
          const SizedBox(height: 12),
          // Format picker
          _SheetDropdown<String>(
            label: 'Format',
            value: _format,
            items: _formats,
            onChanged: (v) => setState(() => _format = v ?? _format),
          ),
          const SizedBox(height: 12),
          // Teams count
          _SheetField(
            controller: _teamsCtrl,
            hint: 'Number of teams',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _submitting ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _submitting ? _kLime.withValues(alpha: 0.4) : _kLime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('CREATE TOURNAMENT', style: _head(16, c: const Color(0xFF1A2800))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.controller, required this.hint, this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: _body(14, c: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: _body(14, c: Colors.white.withValues(alpha: 0.25)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kLime, width: 1.5),
      ),
    ),
  );
}

class _SheetDropdown<T> extends StatelessWidget {
  const _SheetDropdown({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Row(children: [
      Text(label, style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
      const Spacer(),
      DropdownButton<T>(
        value: value,
        items: items.map((i) => DropdownMenuItem(value: i, child: Text('$i', style: _body(13, c: Colors.white)))).toList(),
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1A1A1A),
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.4), size: 16),
        style: _body(13, c: Colors.white),
      ),
    ]),
  );
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  Color get _color => switch (status) {
    'approved' || 'live' => const Color(0xFF58B48F),
    'registration'       => const Color(0xFFF2AD25),
    'pending'            => const Color(0xFF3A8DCC),
    _                    => const Color(0xFF9E9E9E),
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _color.withValues(alpha: 0.4)),
    ),
    child: Text(status.toUpperCase(),
        style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: _color)),
  );
}
