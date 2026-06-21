import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';

// ─── Shared styling helpers ───────────────────────────────────────────────────

const _kLime = AppColors.primary;
const _kBg = AppColors.background;

BoxDecoration _glowCard({bool active = false}) => BoxDecoration(
      color: active
          ? _kLime.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: active
            ? _kLime.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.08),
      ),
      boxShadow: active
          ? [
              BoxShadow(
                color: _kLime.withValues(alpha: 0.2),
                blurRadius: 32,
                spreadRadius: -8,
              )
            ]
          : null,
    );

BoxDecoration _glass({double radius = 16}) => BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
    );

TextStyle _display(double size,
        {Color color = Colors.white, FontWeight weight = FontWeight.w800}) =>
    TextStyle(
      fontFamily: 'Barlow Condensed',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -1.5,
      height: 1.0,
    );

TextStyle _label(double size,
        {Color color = const Color(0xFF9E9E9E),
        FontWeight weight = FontWeight.w600}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.3,
    );

// ─── Root ScoringScreen ───────────────────────────────────────────────────────

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  _SportChoice? _chosen;
  _MatchConfig? _config;
  bool _courtAssigned = false;

  bool get _needsCourtAssignment =>
      _chosen == _SportChoice.badminton ||
      _chosen == _SportChoice.paddleball ||
      _chosen == _SportChoice.pickleball;

  @override
  Widget build(BuildContext context) {
    if (_chosen == null) {
      return _SportSelectionScreen(
        onSelect: (c) => setState(() => _chosen = c),
      );
    }
    if (_config == null) {
      return _MatchSetupScreen(
        sport: _chosen!,
        onStart: (cfg) => setState(() => _config = cfg),
        onBack: () => setState(() => _chosen = null),
      );
    }
    if (_needsCourtAssignment && !_courtAssigned) {
      return _CourtAssignmentScreen(
        config: _config!,
        sport: _chosen!,
        onStart: () => setState(() => _courtAssigned = true),
        onBack: () => setState(() => _config = null),
      );
    }
    return _buildScorer();
  }

  Widget _buildScorer() {
    final cfg = _config!;
    final onExit = () => setState(() {
          _chosen = null;
          _config = null;
          _courtAssigned = false;
        });
    switch (_chosen!) {
      case _SportChoice.cricket:
        return _CricketScorer(config: cfg, onExit: onExit);
      case _SportChoice.badminton:
        return _BadmintonScorer(config: cfg, onExit: onExit);
      case _SportChoice.paddleball:
        return _PaddleballScorer(config: cfg, onExit: onExit);
      case _SportChoice.pickleball:
        return _PickleballScorer(config: cfg, onExit: onExit);
      case _SportChoice.tennis:
        return _TennisScorer(config: cfg, onExit: onExit);
      case _SportChoice.football:
        return _FootballScorer(config: cfg, onExit: onExit);
      case _SportChoice.basketball:
        return _BasketballScorer(config: cfg, onExit: onExit);
      case _SportChoice.volleyball:
        return _VolleyballScorer(config: cfg, onExit: onExit);
    }
  }
}

// ─── Court Assignment Screen ──────────────────────────────────────────────────

class _CourtAssignmentScreen extends StatefulWidget {
  const _CourtAssignmentScreen({
    required this.config,
    required this.sport,
    required this.onStart,
    required this.onBack,
  });
  final _MatchConfig config;
  final _SportChoice sport;
  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  State<_CourtAssignmentScreen> createState() => _CourtAssignmentScreenState();
}

class _CourtAssignmentScreenState extends State<_CourtAssignmentScreen> {
  // 4 positions per side (2 rows × 2 cols), null = unassigned
  final List<String?> _team1Slots = [null, null, null, null];
  final List<String?> _team2Slots = [null, null, null, null];

  List<String> get _team1Players =>
      (widget.config.params['team1Players'] as List<String>?) ?? [];
  List<String> get _team2Players =>
      (widget.config.params['team2Players'] as List<String>?) ?? [];

  void _assignSlot(List<String?> slots, int index, List<String> players) {
    final assigned = slots.whereType<String>().toSet();
    final available = players.where((p) => !assigned.contains(p)).toList();
    if (available.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ASSIGN PLAYER', style: _display(20, color: _kLime)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: available.map((p) => GestureDetector(
                onTap: () {
                  setState(() => slots[index] = p);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _kLime.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                  ),
                  child: Text(p, style: _label(13, color: Colors.white)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCourtGrid(
      List<String?> slots, List<String> players, bool isTop) {
    return Column(
      children: [
        // Team label band (Figma: lime/teal band top and bottom)
        Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kLime.withValues(alpha: 0.15),
            border: Border(
              top: BorderSide(color: _kLime.withValues(alpha: 0.4)),
              bottom: BorderSide(color: _kLime.withValues(alpha: 0.4)),
            ),
          ),
          child: Text(
            isTop ? widget.config.team1.toUpperCase() : widget.config.team2.toUpperCase(),
            style: _label(13, color: _kLime, weight: FontWeight.w700),
          ),
        ),
        // 2×2 grid
        Row(
          children: [0, 1].map((col) {
            return Expanded(
              child: Column(
                children: [0, 1].map((row) {
                  final idx = row * 2 + col;
                  final name = slots[idx];
                  return GestureDetector(
                    onTap: () => _assignSlot(slots, idx, players),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 100,
                      decoration: BoxDecoration(
                        color: name != null
                            ? _kLime.withValues(alpha: 0.12)
                            : const Color(0xFF7EC8A4).withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: name != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36, height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _kLime.withValues(alpha: 0.2),
                                      border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: _display(16, color: _kLime),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name,
                                    style: _label(11, color: Colors.white),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_circle_outline,
                                            color: Colors.white.withValues(alpha: 0.4), size: 16),
                                        const SizedBox(width: 6),
                                        Text('Assign Player',
                                            style: _label(11,
                                                color: Colors.white.withValues(alpha: 0.5))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 36, height: 36,
                      alignment: Alignment.center,
                      decoration: _glass(radius: 10),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sportName(widget.sport).toUpperCase(),
                          style: _display(22, color: _kLime)),
                      Text('COURT ASSIGNMENT', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                  const Spacer(),
                  Text('Match 1', style: _label(12, color: Colors.white.withValues(alpha: 0.3))),
                ],
              ),
            ),
            // Court
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  color: Colors.white.withValues(alpha: 0.02),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Expanded(child: _buildCourtGrid(_team1Slots, _team1Players, true)),
                      // Net line
                      Container(
                        height: 3,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      Expanded(child: _buildCourtGrid(_team2Slots, _team2Players, false)),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showRulesSheet(context, widget.sport),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        child: Text('VIEW RULES',
                            style: _label(14, color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onStart,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kLime,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _kLime.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Text('START GAME',
                            style: _display(17, color: AppColors.onPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sport enum & config ──────────────────────────────────────────────────────

enum _SportChoice { cricket, badminton, paddleball, pickleball, tennis, football, basketball, volleyball }

// ─── Player entry model ───────────────────────────────────────────────────────

class _PlayerEntry {
  _PlayerEntry({required this.name, this.skillTier = 'Rookie', this.selected = false});
  String name;
  String skillTier;
  bool selected;
  static const tiers = ['Rookie', 'Contender', 'Playmaker', 'Competitive', 'Elite'];
}

class _MatchConfig {
  final String team1;
  final String team2;
  final Map<String, dynamic> params; // overs, bestOf, duration, etc.
  const _MatchConfig({required this.team1, required this.team2, this.params = const {}});
}

// ─── Sport Selection Screen ───────────────────────────────────────────────────

class _SportSelectionScreen extends StatefulWidget {
  const _SportSelectionScreen({required this.onSelect});
  final ValueChanged<_SportChoice> onSelect;

  @override
  State<_SportSelectionScreen> createState() => _SportSelectionScreenState();
}

class _SportSelectionScreenState extends State<_SportSelectionScreen> {
  _SportChoice? _hovered;

  static const _sports = [
    (choice: _SportChoice.cricket,     label: 'Cricket',     icon: Icons.sports_cricket,    grad: [Color(0xFF1A4A1A), Color(0xFF0D2D0D)]),
    (choice: _SportChoice.badminton,   label: 'Badminton',   icon: Icons.sports_tennis,     grad: [Color(0xFF0D3B3B), Color(0xFF061E1E)]),
    (choice: _SportChoice.football,    label: 'Football',    icon: Icons.sports_soccer,     grad: [Color(0xFF0D1E3B), Color(0xFF060F1E)]),
    (choice: _SportChoice.tennis,      label: 'Tennis',      icon: Icons.sports_tennis,     grad: [Color(0xFF3B3000), Color(0xFF1E1800)]),
    (choice: _SportChoice.pickleball,  label: 'Pickle Ball', icon: Icons.sports_tennis,     grad: [Color(0xFF1A3B1A), Color(0xFF0D1E0D)]),
    (choice: _SportChoice.paddleball,  label: 'Paddle Ball', icon: Icons.sports_tennis,     grad: [Color(0xFF3B1A3B), Color(0xFF1E0D1E)]),
    (choice: _SportChoice.basketball,  label: 'Basketball',  icon: Icons.sports_basketball, grad: [Color(0xFF3B1A00), Color(0xFF1E0D00)]),
    (choice: _SportChoice.volleyball,  label: 'Volleyball',  icon: Icons.sports_volleyball, grad: [Color(0xFF2A0D3B), Color(0xFF160619)]),
  ];

  @override
  Widget build(BuildContext context) {
    final sel = _hovered;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SCORING', style: _display(42, color: _kLime)),
                  const SizedBox(height: 4),
                  Text('SELECT YOUR SPORT', style: _label(12, color: Colors.white.withValues(alpha: 0.4), weight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GridView.builder(
                  itemCount: _sports.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (_, i) {
                    final s = _sports[i];
                    final isActive = _hovered == s.choice;
                    return GestureDetector(
                      onTap: () => setState(() => _hovered = s.choice),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutExpo,
                        transform: Matrix4.identity()
                          ..scale(isActive ? 1.04 : 1.0),
                        transformAlignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: s.grad,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? _kLime.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.06),
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _kLime.withValues(alpha: 0.25),
                                    blurRadius: 28,
                                    spreadRadius: -4,
                                  )
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            // Watermark icon
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Icon(s.icon, size: 80,
                                  color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(s.icon, size: 32,
                                      color: isActive ? _kLime : Colors.white.withValues(alpha: 0.7)),
                                  Text(
                                    s.label.toUpperCase(),
                                    style: _display(22,
                                        color: isActive ? _kLime : Colors.white,
                                        weight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutExpo,
              offset: sel != null ? Offset.zero : const Offset(0, 0.5),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: sel != null ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: GestureDetector(
                    onTap: sel != null ? () => widget.onSelect(sel) : null,
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
                          )
                        ],
                      ),
                      child: Text(
                        'START SCORING →',
                        style: _display(18,
                            color: AppColors.onPrimary, weight: FontWeight.w800),
                      ),
                    ),
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

// ─── Match Setup Screen ───────────────────────────────────────────────────────

class _MatchSetupScreen extends StatefulWidget {
  const _MatchSetupScreen({
    required this.sport,
    required this.onStart,
    required this.onBack,
  });
  final _SportChoice sport;
  final ValueChanged<_MatchConfig> onStart;
  final VoidCallback onBack;

  @override
  State<_MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<_MatchSetupScreen> {
  final _t1ctrl = TextEditingController(text: 'Team A');
  final _t2ctrl = TextEditingController(text: 'Team B');
  int _overs = 10;
  int _bestOf = 3;
  int _quarterMins = 10;
  int _halfMins = 45;
  bool _singles = true;

  // Player rosters — max 3 per side per Figma spec
  final List<_PlayerEntry> _team1Players = [];
  final List<_PlayerEntry> _team2Players = [];

  @override
  void dispose() {
    _t1ctrl.dispose();
    _t2ctrl.dispose();
    super.dispose();
  }

  void _showAddPlayerSheet(List<_PlayerEntry> roster) {
    final nameCtrl = TextEditingController();
    String selectedTier = 'Rookie';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final bottom = MediaQuery.of(ctx).viewInsets.bottom;
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F0F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  shrinkWrap: true,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text('ADD PLAYER', style: _display(22, color: _kLime)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Player name',
                        hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kLime, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('SKILL TIER', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _PlayerEntry.tiers.map((t) {
                        final active = t == selectedTier;
                        return GestureDetector(
                          onTap: () => setS(() => selectedTier = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: active ? _kLime.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? _kLime.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(t, style: _label(12, color: active ? _kLime : Colors.white.withValues(alpha: 0.5))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        setState(() {
                          roster.add(_PlayerEntry(name: name, skillTier: selectedTier));
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kLime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('ADD PLAYER', style: _display(17, color: AppColors.onPrimary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamRoster(String label, List<_PlayerEntry> roster) {
    final canAdd = roster.length < 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
        const SizedBox(height: 8),
        ...roster.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: _glass(radius: 12),
            child: Row(
              children: [
                // Avatar circle with initials
                Container(
                  width: 38, height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kLime.withValues(alpha: 0.15),
                    border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: _display(16, color: _kLime),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: _label(13, color: Colors.white, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(p.skillTier, style: _label(11, color: _kLime)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => roster.removeAt(i)),
                  child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.3), size: 18),
                ),
              ],
            ),
          );
        }),
        if (canAdd)
          GestureDetector(
            onTap: () => _showAddPlayerSheet(roster),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kLime.withValues(alpha: 0.4),
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                color: _kLime.withValues(alpha: 0.04),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: _kLime, size: 18),
                  const SizedBox(width: 6),
                  Text('ADD PLAYERS', style: _label(13, color: _kLime, weight: FontWeight.w700)),
                ],
              ),
            ),
          )
        else
          Container(
            height: 36,
            alignment: Alignment.center,
            child: Text('MAX 3 PLAYERS', style: _label(11, color: Colors.white.withValues(alpha: 0.25))),
          ),
      ],
    );
  }

  bool get _canStart => _team1Players.isNotEmpty && _team2Players.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40, height: 40,
                      decoration: _glass(radius: 12),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _sportName(widget.sport).toUpperCase(),
                    style: _display(28, color: _kLime),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // CREATE TEAM section header (Figma)
                    Row(
                      children: [
                        Text('CREATE TEAM', style: _display(20, color: Colors.white)),
                        const Spacer(),
                        Icon(Icons.keyboard_arrow_up, color: _kLime, size: 22),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Team 1
                    Text('Team 1', style: _label(12, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 8),
                    _InputField(controller: _t1ctrl, hint: 'Team Name'),
                    const SizedBox(height: 12),
                    _buildTeamRoster('', _team1Players),
                    const SizedBox(height: 20),
                    // Team 2
                    Text('Team 2', style: _label(12, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 8),
                    _InputField(controller: _t2ctrl, hint: 'Team Name'),
                    const SizedBox(height: 12),
                    _buildTeamRoster('', _team2Players),
                    const SizedBox(height: 24),
                    ..._sportParams(),
                  ],
                ),
              ),
            ),
            // Bottom bar: VIEW RULES + START MATCH (Figma pattern)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showRulesSheet(context, widget.sport),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                        child: Text('VIEW RULES', style: _label(14, color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _canStart ? _submit : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _canStart ? _kLime : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _canStart
                              ? [BoxShadow(color: _kLime.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6))]
                              : null,
                        ),
                        child: Text(
                          'START MATCH',
                          style: _display(17,
                              color: _canStart ? AppColors.onPrimary : Colors.white.withValues(alpha: 0.25)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sportParams() {
    switch (widget.sport) {
      case _SportChoice.cricket:
        return [
          Text('OVERS', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          _SegmentPicker(
            options: const ['5', '10', '15', '20'],
            selected: '$_overs',
            onSelect: (v) => setState(() => _overs = int.parse(v)),
          ),
        ];
      case _SportChoice.badminton:
      case _SportChoice.paddleball:
      case _SportChoice.pickleball:
      case _SportChoice.tennis:
      case _SportChoice.volleyball:
        return [
          Text('FORMAT', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          _SegmentPicker(
            options: const ['Best of 3', 'Best of 5'],
            selected: 'Best of $_bestOf',
            onSelect: (v) => setState(() => _bestOf = v.contains('3') ? 3 : 5),
          ),
          if (widget.sport == _SportChoice.badminton || widget.sport == _SportChoice.tennis ||
              widget.sport == _SportChoice.paddleball || widget.sport == _SportChoice.pickleball) ...[
            const SizedBox(height: 16),
            Text('SINGLES / DOUBLES', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 8),
            _SegmentPicker(
              options: const ['Singles', 'Doubles'],
              selected: _singles ? 'Singles' : 'Doubles',
              onSelect: (v) => setState(() => _singles = v == 'Singles'),
            ),
          ],
        ];
      case _SportChoice.football:
        return [
          Text('HALF DURATION (MINS)', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          _SegmentPicker(
            options: const ['20', '30', '45'],
            selected: '$_halfMins',
            onSelect: (v) => setState(() => _halfMins = int.parse(v)),
          ),
        ];
      case _SportChoice.basketball:
        return [
          Text('QUARTER LENGTH (MINS)', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          _SegmentPicker(
            options: const ['8', '10', '12'],
            selected: '$_quarterMins',
            onSelect: (v) => setState(() => _quarterMins = int.parse(v)),
          ),
        ];
    }
  }

  void _submit() {
    final params = <String, dynamic>{};
    switch (widget.sport) {
      case _SportChoice.cricket:
        params['overs'] = _overs;
      case _SportChoice.badminton:
      case _SportChoice.paddleball:
      case _SportChoice.pickleball:
      case _SportChoice.tennis:
      case _SportChoice.volleyball:
        params['bestOf'] = _bestOf;
        params['singles'] = _singles;
      case _SportChoice.football:
        params['halfMins'] = _halfMins;
      case _SportChoice.basketball:
        params['quarterMins'] = _quarterMins;
    }
    widget.onStart(_MatchConfig(
      team1: _t1ctrl.text.trim().isEmpty ? 'Team A' : _t1ctrl.text.trim(),
      team2: _t2ctrl.text.trim().isEmpty ? 'Team B' : _t2ctrl.text.trim(),
      params: params,
    ));
  }
}

String _sportName(_SportChoice s) {
  const names = {
    _SportChoice.cricket:    'Cricket',
    _SportChoice.badminton:  'Badminton',
    _SportChoice.paddleball: 'Paddle Ball',
    _SportChoice.pickleball: 'Pickle Ball',
    _SportChoice.tennis:     'Tennis',
    _SportChoice.football:   'Football',
    _SportChoice.basketball: 'Basketball',
    _SportChoice.volleyball: 'Volleyball',
  };
  return names[s]!;
}

// ─── VIEW RULES sheet ─────────────────────────────────────────────────────────

void _showRulesSheet(BuildContext context, _SportChoice sport) {
  final rules = _sportRules(sport);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: _kLime.withValues(alpha: 0.25))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(_sportName(sport).toUpperCase(), style: _display(24, color: _kLime)),
            const Spacer(),
            Text('RULES', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
          ]),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.map((rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5, height: 5,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _kLime),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(rule, style: _label(13, color: Colors.white.withValues(alpha: 0.8))),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

List<String> _sportRules(_SportChoice sport) {
  switch (sport) {
    case _SportChoice.cricket:
      return [
        'Each team bats once. Select overs before the match.',
        'A batsman is out if: bowled, caught, LBW, run out, stumped, or hit wicket.',
        'Wide and no-ball add 1 run and are not counted as a legal delivery.',
        'Bye and leg-bye count as extras but are legal deliveries.',
        'Strike rotates on odd runs; ends swap at the end of each over.',
        'Team with more runs at the end wins. Tied match = Super Over.',
      ];
    case _SportChoice.badminton:
      return [
        'Best of 3 or 5 games. First to 21 points wins a game (must lead by 2).',
        'At 20-all, the side that first gains a 2-point lead wins.',
        'At 29-all, the side that scores the 30th point wins.',
        'Server rotates when the receiving side wins a rally.',
        'A toss determines the first server and side of the court.',
        'Service must be below the waist and travel diagonally.',
      ];
    case _SportChoice.paddleball:
      return [
        'Played on a smaller court using a solid paddle and depressurised ball.',
        'Best of 3 or 5 sets. First to 6 games wins a set (must lead by 2).',
        'At 6-6 a tiebreak is played (first to 7 points, lead by 2).',
        'Serve must land in the diagonally opposite service box.',
        'Let serves are replayed. Two consecutive faults lose the point.',
        'Ball may bounce off the glass walls — walls are in play.',
      ];
    case _SportChoice.pickleball:
      return [
        'Played on a badminton-sized court with a perforated plastic ball.',
        'Only the serving team can score. Serve rotates on a side-out.',
        'Games are played to 11 points — win by 2.',
        'Serve must be underhand, below the waist, cross-court.',
        'The non-volley zone (kitchen) extends 7 ft from the net.',
        'Volleys are not allowed inside the kitchen.',
      ];
    case _SportChoice.tennis:
      return [
        'Best of 3 or 5 sets. First to 6 games wins a set (lead by 2).',
        'Points: Love → 15 → 30 → 40. Win the game from 40 (or after deuce).',
        'Deuce: both at 40. One player must win 2 consecutive points.',
        'At 6-6 in a set, a tiebreak is played to 7 (lead by 2, max 10 pts).',
        'Serve: two attempts per point. Foot fault counts as a fault.',
        'Ball landing on the line is in.',
      ];
    case _SportChoice.football:
      return [
        'Two halves of equal duration. Team with most goals wins.',
        'A goal is scored when the ball fully crosses the goal line.',
        'Offside: attacker is level with or behind the second-last defender.',
        'Fouls inside the penalty area result in a penalty kick.',
        'Yellow card = caution. Two yellows = red card = ejection.',
        'Extra time and penalty shootout decide draws in knockout games.',
      ];
    case _SportChoice.basketball:
      return [
        'Four quarters. Team with most points wins.',
        'Field goal = 2 pts. Three-pointer = 3 pts. Free throw = 1 pt.',
        'Personal foul: illegal contact. 5 fouls = ejection.',
        'Team foul bonus: from the 5th team foul per quarter, opposing team shoots free throws.',
        'Shot clock: 24 seconds to attempt a shot.',
        'Overtime: 5-minute periods until the tie is broken.',
      ];
    case _SportChoice.volleyball:
      return [
        'Best of 5 sets. First to 25 pts wins a set (lead by 2). Final set to 15 pts.',
        'Rally scoring: every rally produces a point regardless of who served.',
        'Each team may touch the ball up to 3 times before sending it over.',
        'Rotation: teams rotate clockwise after winning back service.',
        'Libero: specialist defensive player — cannot attack above net height.',
        'Players must not touch the net during play.',
      ];
  }
}

// ─── Cricket Scorer ───────────────────────────────────────────────────────────

// ─── Cricket data models ──────────────────────────────────────────────────────

enum _WicketType { bowled, caught, lbw, runOut, stumped, hitWicket, retiredHurt }

class _CricketPlayer {
  _CricketPlayer(this.name);
  final String name;
  int runs = 0;
  int balls = 0;
  int fours = 0;
  int sixes = 0;
  bool isOut = false;
  String howOut = '';
}

class _CricketBowler {
  _CricketBowler(this.name);
  final String name;
  int overs = 0;
  int balls = 0;
  int runs = 0;
  int wickets = 0;
  int wides = 0;
  int noBalls = 0;
}

class _BallRecord {
  _BallRecord({
    required this.display,
    required this.isLegal,
    required this.runs,
    required this.isWicket,
    this.extra = '',
  });
  final String display; // '1','2','W','Wd','Nb','·','4','6'
  final bool isLegal;
  final int runs;
  final bool isWicket;
  final String extra;
}

// ─── Cricket Scorer — Full Workflow ──────────────────────────────────────────

enum _CricketStep {
  teamSetup,    // Enter team names + squad
  toss,         // Toss coin
  playingXI,    // Select 11 players per team
  innings,      // Live scoring
  inningsBreak, // Innings transition
  result,       // Final scorecard
}

class _CricketScorer extends StatefulWidget {
  const _CricketScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_CricketScorer> createState() => _CricketScorerState();
}

class _CricketScorerState extends State<_CricketScorer> {
  late int _totalOvers;
  late String _team1Name, _team2Name;

  // Squad (entered during setup)
  final List<String> _squad1 = [];
  final List<String> _squad2 = [];

  // Playing XI
  final List<String> _xi1 = [];
  final List<String> _xi2 = [];

  // Match meta
  String _umpire1 = '';
  String _umpire2 = '';
  String _matchVenue = '';

  // Toss
  String _tossWinner = '';
  String _tossChoice = ''; // 'bat' or 'bowl'
  String get _battingTeamName => _tossChoice == 'bat' ? _tossWinner
      : (_tossWinner == _team1Name ? _team2Name : _team1Name);
  String get _bowlingTeamName => _battingTeamName == _team1Name ? _team2Name : _team1Name;

  // Current step
  _CricketStep _step = _CricketStep.teamSetup;

  // Squad setup controllers
  final _squad1Ctrl = TextEditingController();
  final _squad2Ctrl = TextEditingController();
  final _umpire1Ctrl = TextEditingController();
  final _umpire2Ctrl = TextEditingController();
  final _venueCtrl   = TextEditingController();

  // Innings state
  int _inning = 1;
  int _i1runs = 0, _i1wkts = 0, _i1balls = 0;
  final List<String> _i1log = [];
  int _i2runs = 0, _i2wkts = 0, _i2balls = 0;
  final List<String> _i2log = [];

  // Current batsmen / bowler
  String _striker = '';
  String _nonStriker = '';
  String _currentBowler = '';

  bool _matchOver = false;
  String _resultText = '';

  // Derived getters
  int get _runs => _inning == 1 ? _i1runs : _i2runs;
  int get _wkts => _inning == 1 ? _i1wkts : _i2wkts;
  int get _balls => _inning == 1 ? _i1balls : _i2balls;
  List<String> get _log => _inning == 1 ? _i1log : _i2log;
  int get _overs => _balls ~/ 6;
  int get _ballsInOver => _balls % 6;
  double get _runRate => _balls == 0 ? 0 : (_runs * 6) / _balls;
  int get _target => _i1runs + 1;
  int get _needed => _target - _i2runs;
  double get _reqRate {
    final left = (_totalOvers * 6) - _i2balls;
    return left <= 0 ? 99 : (_needed * 6) / left;
  }

  List<String> get _battingXI => _battingTeamName == _team1Name ? _xi1 : _xi2;
  List<String> get _bowlingXI => _bowlingTeamName == _team1Name ? _xi1 : _xi2;

  @override
  void initState() {
    super.initState();
    _totalOvers = widget.config.params['overs'] as int? ?? 10;
    _team1Name = widget.config.team1;
    _team2Name = widget.config.team2;
    // Pre-fill minimal squads so workflow can proceed
    for (int i = 1; i <= 11; i++) {
      _squad1.add('$_team1Name P$i');
      _squad2.add('$_team2Name P$i');
    }
  }

  @override
  void dispose() {
    _squad1Ctrl.dispose();
    _squad2Ctrl.dispose();
    _umpire1Ctrl.dispose();
    _umpire2Ctrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  void _addBall(String event, int legalBalls, int runsScored, bool isWicket) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inning == 1) {
        _i1runs += runsScored;
        _i1balls += legalBalls;
        if (isWicket) _i1wkts++;
        _i1log.add(event);
      } else {
        _i2runs += runsScored;
        _i2balls += legalBalls;
        if (isWicket) _i2wkts++;
        _i2log.add(event);
      }
    });
    _checkInningsEnd();
    if (_matchOver) return;

    final completedOver = legalBalls == 1 && _ballsInOver == 0;

    if (legalBalls == 1 && runsScored.isOdd && !isWicket) {
      // Odd runs — ask who is at striker's end after the run
      _showStrikerChoiceSheet();
    } else if (completedOver) {
      // End of over — swap ends automatically then ask for new bowler
      setState(() {
        final tmp = _striker; _striker = _nonStriker; _nonStriker = tmp;
      });
      _pickBowler();
    }
  }

  void _showStrikerChoiceSheet() {
    if (_striker.isEmpty && _nonStriker.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WHO IS ON STRIKE?', style: _display(20, color: _kLime)),
            const SizedBox(height: 4),
            Text('Batters crossed — confirm the striker', style: _label(12, color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 16),
            Row(children: [
              for (final batter in [_striker, _nonStriker]) ...[
                if (batter.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          if (batter != _striker) {
                            final tmp = _striker; _striker = _nonStriker; _nonStriker = tmp;
                          }
                          // After odd-run over boundary, also ask bowler
                          if (_ballsInOver == 0) _pickBowler();
                        });
                      },
                      child: Container(
                        height: 64,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _kLime.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(batter, style: _label(14, color: Colors.white, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('ON STRIKE', style: _label(9, color: _kLime)),
                        ]),
                      ),
                    ),
                  ),
                if (batter != (_nonStriker.isNotEmpty ? _nonStriker : '')) const SizedBox(width: 8),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  void _checkInningsEnd() {
    final wkts = _inning == 1 ? _i1wkts : _i2wkts;
    final balls = _inning == 1 ? _i1balls : _i2balls;

    if (_inning == 2) {
      if (_i2runs >= _target) {
        setState(() {
          _matchOver = true;
          _resultText = '$_battingTeamName WON\nby ${10 - wkts} wickets';
          _step = _CricketStep.result;
        });
        return;
      }
      if (wkts >= 10 || balls >= _totalOvers * 6) {
        final diff = _i1runs - _i2runs;
        setState(() {
          _matchOver = true;
          _resultText = diff > 0
              ? '$_bowlingTeamName WON\nby $diff runs'
              : diff == 0 ? 'MATCH TIED'
              : '$_battingTeamName WON\nby ${10 - wkts} wickets';
          _step = _CricketStep.result;
        });
      }
    } else {
      if (wkts >= 10 || balls >= _totalOvers * 6) {
        setState(() => _step = _CricketStep.inningsBreak);
      }
    }
  }

  void _startInnings2() {
    setState(() {
      _inning = 2;
      _striker = '';
      _nonStriker = '';
      _currentBowler = '';
      _step = _CricketStep.innings;
    });
    _pickOpeners(innings: 2);
  }

  void _pickOpeners({required int innings}) {
    _showPlayerPicker(
      title: 'SELECT STRIKER',
      players: _battingXI,
      onPick: (p) {
        setState(() => _striker = p);
        _showPlayerPicker(
          title: 'SELECT NON-STRIKER',
          players: _battingXI.where((x) => x != p).toList(),
          onPick: (p2) {
            setState(() => _nonStriker = p2);
            _pickBowler();
          },
        );
      },
    );
  }

  void _pickBowler() {
    _showPlayerPicker(
      title: 'SELECT BOWLER',
      players: _bowlingXI,
      onPick: (p) => setState(() => _currentBowler = p),
    );
  }

  void _showWicketDialog() {
    final batters = _battingXI.where((b) => b != _nonStriker).toList();
    final wicketTypes = ['Bowled', 'Caught', 'LBW', 'Run Out', 'Stumped', 'Hit Wicket'];
    // Lift mutable state ABOVE the builder so setS() doesn't reset them
    String? selectedType;
    String? outBatter = _striker.isNotEmpty ? _striker : (batters.isNotEmpty ? batters.first : null);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.error.withValues(alpha: 0.4))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WICKET', style: _display(28, color: AppColors.error)),
                  const SizedBox(height: 4),
                  Text('How out?', style: _label(13, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: wicketTypes.map((t) => GestureDetector(
                      onTap: () => setS(() => selectedType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedType == t
                              ? AppColors.error.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedType == t
                                ? AppColors.error.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(t, style: _label(13,
                            color: selectedType == t ? AppColors.error : Colors.white)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('OUT BATTER', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: batters.map((b) => GestureDetector(
                      onTap: () => setS(() => outBatter = b),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: outBatter == b
                              ? AppColors.error.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: outBatter == b
                                ? AppColors.error.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(b, style: _label(12,
                            color: outBatter == b ? AppColors.error : Colors.white.withValues(alpha: 0.7))),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: selectedType == null ? null : () {
                      Navigator.pop(ctx);
                      HapticFeedback.heavyImpact();
                      _addBall('W', 1, 0, true);
                      final dismissed = outBatter ?? _striker;
                      // New batsman comes in
                      final remaining = _battingXI
                          .where((b) => b != _nonStriker && b != dismissed)
                          .toList();
                      if (remaining.isNotEmpty) {
                        _showPlayerPicker(
                          title: 'NEW BATSMAN',
                          players: remaining,
                          onPick: (p) => setState(() => _striker = p),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedType != null
                            ? AppColors.error.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('CONFIRM WICKET',
                          style: _display(18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPlayerPicker({
    required String title,
    required List<String> players,
    required ValueChanged<String> onPick,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _display(22, color: _kLime)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: players.map((p) => GestureDetector(
                onTap: () { Navigator.pop(context); onPick(p); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kLime.withValues(alpha: 0.3)),
                  ),
                  child: Text(p, style: _label(13, color: Colors.white)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _CricketStep.teamSetup:
        return _buildTeamSetup();
      case _CricketStep.toss:
        return _buildToss();
      case _CricketStep.playingXI:
        return _buildPlayingXI();
      case _CricketStep.innings:
        return _buildInnings();
      case _CricketStep.inningsBreak:
        return _buildInningsBreak();
      case _CricketStep.result:
        return _MatchResultScreen(result: _resultText, onExit: widget.onExit);
    }
  }

  // ── Step 1: Team Setup ──────────────────────────────────────────────────────
  Widget _buildTeamSetup() {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(sport: 'CRICKET', info: 'MATCH SETUP', onExit: widget.onExit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Teams summary card
                    Text('TEAMS', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _glowCard(active: true),
                      child: Row(
                        children: [
                          Expanded(child: Column(children: [
                            Text(_team1Name.toUpperCase(), style: _display(20, color: _kLime)),
                            Text('${_squad1.length} players', style: _label(11)),
                          ])),
                          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08)),
                          Expanded(child: Column(children: [
                            Text(_team2Name.toUpperCase(), style: _display(20, color: Colors.white)),
                            Text('${_squad2.length} players', style: _label(11)),
                          ])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('OVERS: $_totalOvers', style: _display(18, color: _kLime)),
                    const SizedBox(height: 20),

                    // Match venue
                    Text('MATCH VENUE', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(height: 8),
                    _CricketInputField(
                      controller: _venueCtrl,
                      hint: 'Ground / venue name',
                      icon: Icons.stadium_outlined,
                      onChanged: (v) => setState(() => _matchVenue = v),
                    ),
                    const SizedBox(height: 20),

                    // Umpires
                    Text('UMPIRES', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(height: 8),
                    _CricketInputField(
                      controller: _umpire1Ctrl,
                      hint: 'Umpire 1 name',
                      icon: Icons.sports_outlined,
                      onChanged: (v) => setState(() => _umpire1 = v),
                    ),
                    const SizedBox(height: 10),
                    _CricketInputField(
                      controller: _umpire2Ctrl,
                      hint: 'Umpire 2 name (optional)',
                      icon: Icons.sports_outlined,
                      onChanged: (v) => setState(() => _umpire2 = v),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _NextBtn(label: 'PROCEED TO TOSS →', onTap: () => setState(() => _step = _CricketStep.toss)),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Toss ───────────────────────────────────────────────────────────
  Widget _buildToss() {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(sport: 'CRICKET', info: 'TOSS', onExit: widget.onExit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // "WHO WON THE TOSS?" — Figma style heading
                    Text('WHO WON THE TOSS?',
                        style: _display(22, color: Colors.white)),
                    const SizedBox(height: 20),
                    // Team icon cards (Figma: bordered card, circular team logo, team label below)
                    Row(children: [
                      for (final team in [_team1Name, _team2Name]) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tossWinner = team),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: _tossWinner == team
                                    ? _kLime.withValues(alpha: 0.10)
                                    : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _tossWinner == team
                                      ? _kLime.withValues(alpha: 0.7)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: _tossWinner == team ? 1.5 : 1,
                                ),
                                boxShadow: _tossWinner == team
                                    ? [BoxShadow(color: _kLime.withValues(alpha: 0.18), blurRadius: 20)]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(team == _team1Name ? 'Team 1' : 'Team 2',
                                      style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                                  const SizedBox(height: 12),
                                  // Circular team logo
                                  Container(
                                    width: 56, height: 56,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _tossWinner == team
                                          ? _kLime.withValues(alpha: 0.2)
                                          : Colors.white.withValues(alpha: 0.06),
                                      border: Border.all(
                                        color: _tossWinner == team
                                            ? _kLime.withValues(alpha: 0.5)
                                            : Colors.white.withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Text(
                                      team.isNotEmpty ? team[0].toUpperCase() : '?',
                                      style: _display(26,
                                          color: _tossWinner == team
                                              ? _kLime
                                              : Colors.white.withValues(alpha: 0.6)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(team,
                                      style: _label(13,
                                          color: _tossWinner == team
                                              ? _kLime
                                              : Colors.white.withValues(alpha: 0.7),
                                          weight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (team != _team2Name) const SizedBox(width: 12),
                      ],
                    ]),
                    if (_tossWinner.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text('WHAT HAVE THEY DECIDED?',
                          style: _display(22, color: Colors.white)),
                      const SizedBox(height: 20),
                      // Batting / Balling icon cards (Figma style)
                      Row(children: [
                        for (final choice in ['bat', 'bowl']) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tossChoice = choice),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: _tossChoice == choice
                                      ? _kLime.withValues(alpha: 0.10)
                                      : Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _tossChoice == choice
                                        ? _kLime.withValues(alpha: 0.7)
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: _tossChoice == choice ? 1.5 : 1,
                                  ),
                                  boxShadow: _tossChoice == choice
                                      ? [BoxShadow(color: _kLime.withValues(alpha: 0.18), blurRadius: 20)]
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    // Circular icon — teal bg as in Figma
                                    Container(
                                      width: 64, height: 64,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _tossChoice == choice
                                            ? _kLime.withValues(alpha: 0.2)
                                            : const Color(0xFF1A4A3A).withValues(alpha: 0.6),
                                      ),
                                      child: Text(
                                        choice == 'bat' ? '🏏' : '🎯',
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      choice == 'bat' ? 'Batting' : 'Balling',
                                      style: _label(14,
                                          color: _tossChoice == choice
                                              ? _kLime
                                              : Colors.white.withValues(alpha: 0.6),
                                          weight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (choice != 'bowl') const SizedBox(width: 12),
                        ],
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            if (_tossWinner.isNotEmpty && _tossChoice.isNotEmpty)
              _NextBtn(
                label: '${_battingTeamName.toUpperCase()} BATS FIRST →',
                onTap: () => setState(() => _step = _CricketStep.playingXI),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Playing XI ─────────────────────────────────────────────────────
  Widget _buildPlayingXI() {
    // For this version, auto-select all 11 from each squad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_xi1.isEmpty) {
        setState(() {
          _xi1.addAll(_squad1.take(11));
          _xi2.addAll(_squad2.take(11));
        });
      }
    });

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(sport: 'CRICKET', info: 'PLAYING XI', onExit: widget.onExit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    for (final team in [_team1Name, _team2Name]) ...[
                      Text(team.toUpperCase(),
                          style: _display(18, color: team == _battingTeamName ? _kLime : Colors.white)),
                      const SizedBox(height: 4),
                      Text(team == _battingTeamName ? 'BATTING' : 'BOWLING',
                          style: _label(10, color: Colors.white.withValues(alpha: 0.4))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _glass(),
                        child: Wrap(
                          spacing: 8, runSpacing: 8,
                          children: (team == _team1Name ? _xi1 : _xi2).map((p) =>
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Text(p, style: _label(12, color: Colors.white.withValues(alpha: 0.8))),
                            ),
                          ).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            _NextBtn(
              label: 'START INNINGS →',
              onTap: () {
                setState(() => _step = _CricketStep.innings);
                _pickOpeners(innings: 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 4: Live Innings ───────────────────────────────────────────────────
  Widget _buildInnings() {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'CRICKET',
              info: 'INN $_inning • ${_battingTeamName.toUpperCase()} BATTING',
              onExit: widget.onExit,
              venue: _matchVenue.isNotEmpty ? _matchVenue : null,
              umpire: _umpire1.isNotEmpty ? _umpire1 : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Scoreboard
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _glowCard(active: true),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$_runs/$_wkts', style: _display(72, color: _kLime)),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text('($_overs.$_ballsInOver)',
                                    style: _display(26, color: Colors.white.withValues(alpha: 0.4))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatPill('RR', _runRate.toStringAsFixed(2)),
                              if (_inning == 2) ...[
                                _StatPill('TGT', '$_target'),
                                _StatPill('NEED', '$_needed'),
                                _StatPill('RRR', _reqRate.toStringAsFixed(2)),
                              ] else
                                _StatPill('OVERS', '$_totalOvers'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _BallByBallRow(log: _log),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Batsmen strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: _glass(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _kLime,
                                      boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.8), blurRadius: 6)],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(_striker.isEmpty ? 'Striker' : _striker,
                                      style: _label(13, color: Colors.white)),
                                ]),
                                const SizedBox(height: 4),
                                Text(_nonStriker.isEmpty ? 'Non-striker' : _nonStriker,
                                    style: _label(12, color: Colors.white.withValues(alpha: 0.4))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickBowler,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('BOWLER', style: _label(9, color: Colors.white.withValues(alpha: 0.3))),
                                Text(_currentBowler.isEmpty ? 'Select' : _currentBowler,
                                    style: _label(13, color: _kLime)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Controls
                    _buildScoringControls(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringControls() {
    return Column(
      children: [
        // Runs row
        Row(children: [
          for (final r in [0, 1, 2, 3, 4, 6])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _CricBtn(
                  label: r == 0 ? '·' : '$r',
                  color: r == 4 ? const Color(0xFF003D5C)
                      : r == 6 ? const Color(0xFF5C3000) : null,
                  onTap: () => _addBall(r == 0 ? '·' : '$r', 1, r, false),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        // Extras row
        Row(children: [
          Expanded(child: _CricBtn(
            label: 'WIDE', sub: '+1',
            color: const Color(0xFF1A1A00),
            onTap: () => _addBall('Wd', 0, 1, false),
          )),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(
            label: 'NO BALL', sub: '+1',
            color: const Color(0xFF1A0D00),
            onTap: () => _addBall('Nb', 0, 1, false),
          )),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(
            label: 'BYE',
            onTap: () => _addBall('B', 1, 0, false),
          )),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(
            label: 'LEG BYE',
            onTap: () => _addBall('Lb', 1, 0, false),
          )),
        ]),
        const SizedBox(height: 8),
        // Wicket button
        GestureDetector(
          onTap: _showWicketDialog,
          child: Container(
            height: 64,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
              boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.15), blurRadius: 20)],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.sports_cricket, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text('WICKET', style: _display(24, color: AppColors.error)),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Step 5: Innings Break ──────────────────────────────────────────────────
  Widget _buildInningsBreak() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('INNINGS BREAK', style: _display(32, color: _kLime)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: _glowCard(active: true),
                child: Column(
                  children: [
                    Text(_battingTeamName.toUpperCase(),
                        style: _label(13, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 8),
                    Text('$_i1runs/$_i1wkts',
                        style: _display(64, color: Colors.white)),
                    Text('${_i1balls ~/ 6}.${_i1balls % 6} overs',
                        style: _label(14, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kLime.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                      ),
                      child: Text('TARGET: $_target',
                          style: _display(22, color: _kLime)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _NextBtn(
                label: 'START 2ND INNINGS →',
                onTap: _startInnings2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared cricket sub-widgets ────────────────────────────────────────────────

class _CricketInputField extends StatelessWidget {
  const _CricketInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withValues(alpha: 0.25)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kLime, width: 1.5),
        ),
      ),
    );
  }
}

class _NextBtn extends StatelessWidget {
  const _NextBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _kLime,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Text(label, style: _display(18, color: AppColors.onPrimary, weight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _CricketControls extends StatelessWidget {
  const _CricketControls({required this.onEvent});
  final void Function(String event, int legalBalls, int runs, bool isWicket) onEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          for (final r in [1, 2, 3, 4, 6])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _CricBtn(
                  label: '+$r',
                  color: r == 4 ? const Color(0xFF005F8A) : r == 6 ? const Color(0xFF8A4A00) : null,
                  onTap: () => onEvent('$r', 1, r, false),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _CricBtn(label: 'WIDE', sub: '+1', color: const Color(0xFF2A2A00), onTap: () => onEvent('Wd', 0, 1, false))),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(label: 'NO BALL', sub: '+1', color: const Color(0xFF2A1500), onTap: () => onEvent('Nb', 0, 1, false))),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(label: 'BYE', onTap: () => onEvent('B', 1, 0, false))),
          const SizedBox(width: 6),
          Expanded(child: _CricBtn(label: 'DOT', sub: '0', onTap: () => onEvent('·', 1, 0, false))),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity, height: 64,
          child: GestureDetector(
            onTap: () => onEvent('W', 1, 0, true),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -6)],
              ),
              child: Text('WICKET', style: _display(24, color: AppColors.error)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CricBtn extends StatelessWidget {
  const _CricBtn({required this.label, this.sub, this.color, required this.onTap});
  final String label;
  final String? sub;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: _display(18, color: Colors.white)),
            if (sub != null) Text(sub!, style: _label(10, color: _kLime)),
          ],
        ),
      ),
    );
  }
}

class _BallByBallRow extends StatelessWidget {
  const _BallByBallRow({required this.log});
  final List<String> log;

  Color _dotColor(String e) {
    if (e == 'W') return AppColors.error;
    if (e == 'Wd' || e == 'Nb') return const Color(0xFFF7BC45);
    if (e == '·') return Colors.white.withValues(alpha: 0.2);
    if (e == '6') return const Color(0xFFFF8C00);
    if (e == '4') return const Color(0xFF3A8DCC);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final last6 = log.length > 6 ? log.sublist(log.length - 6) : log;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 6; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32, height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < last6.length ? _dotColor(last6[i]).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: i < last6.length ? _dotColor(last6[i]).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08)),
            ),
            child: i < last6.length
                ? Text(last6[i], style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: _dotColor(last6[i])))
                : null,
          ),
      ],
    );
  }
}

// ─── Badminton Scorer ─────────────────────────────────────────────────────────

class _BadmintonScorer extends StatefulWidget {
  const _BadmintonScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_BadmintonScorer> createState() => _BadmintonScorerState();
}

class _BadmintonScorerState extends State<_BadmintonScorer> {
  late int _bestOf;
  late String _p1, _p2;
  List<(int, int)> _sets = [];
  int _p1cur = 0, _p2cur = 0;
  int _server = 1; // 1 or 2
  bool _matchOver = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _bestOf = widget.config.params['bestOf'] as int? ?? 3;
    _p1 = widget.config.team1;
    _p2 = widget.config.team2;
  }

  int _setsWon(int player) => _sets.where((s) {
        if (player == 1) return s.$1 > s.$2;
        return s.$2 > s.$1;
      }).length;

  int get _setsNeeded => (_bestOf / 2).ceil();

  void _addPoint(int player) {
    HapticFeedback.lightImpact();
    setState(() {
      if (player == 1) {
        _p1cur++;
        _server = 1;
      } else {
        _p2cur++;
        _server = 2;
      }
    });
    _checkSetWin();
  }

  void _checkSetWin() {
    final p1 = _p1cur, p2 = _p2cur;
    bool setOver = false;

    // Standard win: 21 with 2 ahead
    if (p1 >= 21 && p1 - p2 >= 2) { setOver = true; }
    else if (p2 >= 21 && p2 - p1 >= 2) { setOver = true; }
    // Deuce max: 30 points
    else if (p1 == 30) { setOver = true; }
    else if (p2 == 30) { setOver = true; }

    if (setOver) {
      setState(() {
        _sets.add((_p1cur, _p2cur));
        _p1cur = 0;
        _p2cur = 0;
      });
      final w1 = _setsWon(1), w2 = _setsWon(2);
      if (w1 >= _setsNeeded) {
        setState(() { _matchOver = true; _result = '$_p1 WON\n$w1 — $w2 sets'; });
      } else if (w2 >= _setsNeeded) {
        setState(() { _matchOver = true; _result = '$_p2 WON\n$w2 — $w1 sets'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _MatchResultScreen(result: _result, onExit: widget.onExit);

    final isDeuceZone = _p1cur >= 20 && _p2cur >= 20;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'BADMINTON',
              info: 'Set ${_sets.length + 1} of $_bestOf${isDeuceZone ? " • DEUCE ZONE" : ""}',
              onExit: widget.onExit,
            ),
            // Sets row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _bestOf; i++) ...[
                    if (i < _sets.length)
                      _SetScorePill(
                        p1: _sets[i].$1,
                        p2: _sets[i].$2,
                        active: false,
                      )
                    else if (i == _sets.length)
                      _SetScorePill(p1: _p1cur, p2: _p2cur, active: true)
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 44, height: 28,
                        decoration: _glass(radius: 8),
                      ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Player names + scores
                    _ShuttleScore(
                      p1: _p1, p2: _p2,
                      s1: _p1cur, s2: _p2cur,
                      server: _server,
                    ),
                  ],
                ),
              ),
            ),
            // Point buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(1),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kLime.withValues(alpha: 0.2), _kLime.withValues(alpha: 0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, color: _kLime, size: 20),
                            const SizedBox(height: 4),
                            Text(_p1.toUpperCase(), style: _label(11, color: _kLime)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(2),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kLime.withValues(alpha: 0.05), _kLime.withValues(alpha: 0.2)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward, color: _kLime, size: 20),
                            const SizedBox(height: 4),
                            Text(_p2.toUpperCase(), style: _label(11, color: _kLime)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tennis Scorer ────────────────────────────────────────────────────────────

class _TennisScorer extends StatefulWidget {
  const _TennisScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_TennisScorer> createState() => _TennisScorerState();
}

class _TennisScorerState extends State<_TennisScorer> {
  late int _bestOf;
  late String _p1, _p2;

  List<(int, int)> _sets = [];
  int _p1games = 0, _p2games = 0;
  int _p1pts = 0, _p2pts = 0; // 0=Love,1=15,2=30,3=40,4=Adv
  bool _inTiebreak = false;
  int _p1tb = 0, _p2tb = 0;
  bool _matchOver = false;
  String _result = '';

  static const _ptLabels = ['Love', '15', '30', '40'];

  @override
  void initState() {
    super.initState();
    _bestOf = widget.config.params['bestOf'] as int? ?? 3;
    _p1 = widget.config.team1;
    _p2 = widget.config.team2;
  }

  int _setsWon(int p) => _sets.where((s) => p == 1 ? s.$1 > s.$2 : s.$2 > s.$1).length;
  int get _setsNeeded => (_bestOf / 2).ceil();

  String _ptsLabel(int p1, int p2) {
    if (_inTiebreak) return '';
    if (p1 >= 3 && p2 >= 3) {
      if (p1 == p2) return 'Deuce';
      if (p1 > p2) return 'Adv $_p1';
      return 'Adv $_p2';
    }
    return '${_ptLabels[p1.clamp(0, 3)]} — ${_ptLabels[p2.clamp(0, 3)]}';
  }

  void _addPoint(int player) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inTiebreak) {
        if (player == 1) _p1tb++; else _p2tb++;
        _checkTiebreak();
        return;
      }
      if (player == 1) _p1pts++; else _p2pts++;
      _resolvePoint();
    });
  }

  void _undoPoint() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_inTiebreak) {
        if (_p1tb > 0) _p1tb--; else if (_p2tb > 0) _p2tb--;
        return;
      }
      if (_p1pts > 0) _p1pts--; else if (_p2pts > 0) _p2pts--;
    });
  }

  void _resolvePoint() {
    final p1 = _p1pts, p2 = _p2pts;
    bool gameOver = false;
    int winner = 0;

    if (p1 >= 3 && p2 >= 3) {
      // Deuce territory
      if (p1 - p2 >= 2) { gameOver = true; winner = 1; }
      else if (p2 - p1 >= 2) { gameOver = true; winner = 2; }
    } else {
      if (p1 >= 4) { gameOver = true; winner = 1; }
      else if (p2 >= 4) { gameOver = true; winner = 2; }
    }

    if (gameOver) {
      _p1pts = 0; _p2pts = 0;
      if (winner == 1) _p1games++; else _p2games++;
      _checkSetWin();
    }
  }

  void _checkSetWin() {
    bool setOver = false;

    if (_p1games >= 6 && _p1games - _p2games >= 2) { setOver = true; }
    else if (_p2games >= 6 && _p2games - _p1games >= 2) { setOver = true; }
    else if (_p1games == 6 && _p2games == 6) { _inTiebreak = true; return; }
    else if (_p1games == 7) { setOver = true; }
    else if (_p2games == 7) { setOver = true; }

    if (setOver) {
      _sets.add((_p1games, _p2games));
      _p1games = 0; _p2games = 0;
      final w1 = _setsWon(1), w2 = _setsWon(2);
      if (w1 >= _setsNeeded) {
        _matchOver = true;
        _result = '$_p1 WON\n$w1 — $w2 sets';
      } else if (w2 >= _setsNeeded) {
        _matchOver = true;
        _result = '$_p2 WON\n$w2 — $w1 sets';
      }
    }
  }

  void _checkTiebreak() {
    final p1 = _p1tb, p2 = _p2tb;
    if (p1 >= 7 && p1 - p2 >= 2) {
      _inTiebreak = false; _p1tb = 0; _p2tb = 0;
      _sets.add((7, _p2games));
      _p1games = 0; _p2games = 0;
      final w1 = _setsWon(1);
      if (w1 >= _setsNeeded) { _matchOver = true; _result = '$_p1 WON'; }
    } else if (p2 >= 7 && p2 - p1 >= 2) {
      _inTiebreak = false; _p1tb = 0; _p2tb = 0;
      _sets.add((_p1games, 7));
      _p1games = 0; _p2games = 0;
      final w2 = _setsWon(2);
      if (w2 >= _setsNeeded) { _matchOver = true; _result = '$_p2 WON'; }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _MatchResultScreen(result: _result, onExit: widget.onExit);
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(sport: 'TENNIS', info: 'Best of $_bestOf sets', onExit: widget.onExit),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Scoreboard table
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _glowCard(active: true),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 100),
                              for (int i = 0; i < _bestOf; i++)
                                Expanded(child: Center(child: Text('S${i+1}', style: _label(10, color: Colors.white.withValues(alpha: 0.4))))),
                              const SizedBox(width: 8),
                              SizedBox(width: 60, child: Center(child: Text(_inTiebreak ? 'TB' : 'PTS', style: _label(10, color: Colors.white.withValues(alpha: 0.4))))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TennisRow(
                            name: _p1, sets: _sets, currentGames: _p1games,
                            isP1: true, pts: _inTiebreak ? _p1tb : _p1pts,
                            bestOf: _bestOf, inTiebreak: _inTiebreak,
                          ),
                          const SizedBox(height: 8),
                          _TennisRow(
                            name: _p2, sets: _sets, currentGames: _p2games,
                            isP1: false, pts: _inTiebreak ? _p2tb : _p2pts,
                            bestOf: _bestOf, inTiebreak: _inTiebreak,
                          ),
                          const SizedBox(height: 16),
                          if (!_inTiebreak)
                            Text(
                              _ptsLabel(_p1pts, _p2pts),
                              style: _display(20, color: _kLime),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _undoPoint,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: _glass(radius: 10),
                            child: Text('↩ UNDO', style: _label(12, color: Colors.white.withValues(alpha: 0.6))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _LargePointBtn(label: _p1.toUpperCase(), onTap: () => _addPoint(1))),
                        const SizedBox(width: 12),
                        Expanded(child: _LargePointBtn(label: _p2.toUpperCase(), onTap: () => _addPoint(2))),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TennisRow extends StatelessWidget {
  const _TennisRow({
    required this.name, required this.sets, required this.currentGames,
    required this.isP1, required this.pts, required this.bestOf,
    required this.inTiebreak,
  });
  final String name;
  final List<(int, int)> sets;
  final int currentGames, pts, bestOf;
  final bool isP1, inTiebreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(name, style: _label(14, color: Colors.white, weight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ),
        for (int i = 0; i < bestOf; i++)
          Expanded(
            child: Center(
              child: i < sets.length
                  ? Text(
                      '${isP1 ? sets[i].$1 : sets[i].$2}',
                      style: _display(22,
                          color: (isP1 ? sets[i].$1 > sets[i].$2 : sets[i].$2 > sets[i].$1)
                              ? _kLime
                              : Colors.white.withValues(alpha: 0.4)),
                    )
                  : i == sets.length
                      ? Text('$currentGames', style: _display(22, color: Colors.white))
                      : Text('-', style: _label(14, color: Colors.white.withValues(alpha: 0.2))),
            ),
          ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Center(
            child: Text('$pts', style: _display(22, color: _kLime)),
          ),
        ),
      ],
    );
  }
}

// ─── Football Scorer ──────────────────────────────────────────────────────────

class _FootballScorer extends StatefulWidget {
  const _FootballScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_FootballScorer> createState() => _FootballScorerState();
}

class _GoalEvent {
  final int team;
  final String scorer;
  final int minute;
  final bool isOG, isPenalty;
  const _GoalEvent({required this.team, required this.scorer, required this.minute, this.isOG = false, this.isPenalty = false});
}

class _FootballScorerState extends State<_FootballScorer>
    with SingleTickerProviderStateMixin {
  late String _t1, _t2;
  int _half = 1;
  List<_GoalEvent> _goals = [];
  bool _timerRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  int get _t1goals => _goals.where((g) => (g.team == 1 && !g.isOG) || (g.team == 2 && g.isOG)).length;
  int get _t2goals => _goals.where((g) => (g.team == 2 && !g.isOG) || (g.team == 1 && g.isOG)).length;
  int get _elapsedMins => _elapsedSeconds ~/ 60;

  @override
  void initState() {
    super.initState();
    _t1 = widget.config.team1;
    _t2 = widget.config.team2;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() => _timerRunning = !_timerRunning);
    if (_timerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
    } else {
      _timer?.cancel();
    }
  }

  void _showGoalSheet(int team) {
    final nameCtrl = TextEditingController();
    bool isOG = false, isPenalty = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _kLime.withValues(alpha: 0.3))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 4, height: 24, decoration: BoxDecoration(color: _kLime, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text('⚽ GOAL — ${team == 1 ? _t1.toUpperCase() : _t2.toUpperCase()}', style: _display(20, color: _kLime)),
              ]),
              const SizedBox(height: 16),
              _InputField(controller: nameCtrl, hint: 'Scorer name (optional)'),
              const SizedBox(height: 12),
              Row(children: [
                _ToggleChip(label: 'Own Goal', active: isOG, onTap: () => setS(() => isOG = !isOG)),
                const SizedBox(width: 8),
                _ToggleChip(label: 'Penalty', active: isPenalty, onTap: () => setS(() => isPenalty = !isPenalty)),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _goals.add(_GoalEvent(
                      team: team,
                      scorer: nameCtrl.text.trim().isEmpty ? (team == 1 ? _t1 : _t2) : nameCtrl.text.trim(),
                      minute: _elapsedMins + 1,
                      isOG: isOG,
                      isPenalty: isPenalty,
                    ));
                  });
                  Navigator.pop(ctx);
                  HapticFeedback.heavyImpact();
                },
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kLime,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('CONFIRM GOAL', style: _display(18, color: AppColors.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mins = _elapsedSeconds ~/ 60;
    final secs = _elapsedSeconds % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'FOOTBALL',
              info: _half == 1 ? '1ST HALF' : _half == 2 ? '2ND HALF' : 'EXTRA TIME',
              onExit: widget.onExit,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Scoreboard
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: _glowCard(active: true),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(_t1.toUpperCase(), style: _display(18, color: Colors.white), textAlign: TextAlign.center)),
                                Text('$_t1goals', style: _display(80, color: _kLime)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('—', style: _display(40, color: Colors.white.withValues(alpha: 0.2))),
                                ),
                                Text('$_t2goals', style: _display(80, color: _kLime)),
                                Expanded(child: Text(_t2.toUpperCase(), style: _display(18, color: Colors.white), textAlign: TextAlign.center)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _toggleTimer,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _timerRunning
                                      ? _kLime.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _timerRunning
                                        ? _kLime.withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _timerRunning ? Icons.pause : Icons.play_arrow,
                                      color: _timerRunning ? _kLime : Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(timeStr,
                                        style: _display(24,
                                            color: _timerRunning ? _kLime : Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Goal log
                    if (_goals.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _glass(),
                          child: Column(
                            children: _goals.reversed.take(5).map((g) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    "${g.minute}'",
                                    style: _label(12, color: _kLime),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('⚽', style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(g.scorer, style: _label(13, color: Colors.white)),
                                  if (g.isOG)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text('(OG)', style: _label(10, color: AppColors.error)),
                                    ),
                                  if (g.isPenalty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text('(P)', style: _label(10, color: _kLime)),
                                    ),
                                  const Spacer(),
                                  Text(
                                    g.team == 1 ? _t1 : _t2,
                                    style: _label(11, color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _FootballGoalBtn(label: '⚽ ${_t1.toUpperCase()}', onTap: () => _showGoalSheet(1))),
                      const SizedBox(width: 10),
                      Expanded(child: _FootballGoalBtn(label: '${_t2.toUpperCase()} ⚽', onTap: () => _showGoalSheet(2))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_half < 3) setState(() { _half++; _elapsedSeconds = 0; _timer?.cancel(); _timerRunning = false; });
                        },
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: _glass(radius: 10),
                          child: Text(
                            _half == 1 ? 'START 2ND HALF →' : _half == 2 ? 'EXTRA TIME →' : 'END MATCH',
                            style: _label(12, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_goals.isNotEmpty) setState(() => _goals.removeLast());
                      },
                      child: Container(
                        height: 44, width: 44,
                        alignment: Alignment.center,
                        decoration: _glass(radius: 10),
                        child: const Icon(Icons.undo, color: Colors.white, size: 18),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FootballGoalBtn extends StatelessWidget {
  const _FootballGoalBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_kLime.withValues(alpha: 0.15), _kLime.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kLime.withValues(alpha: 0.4)),
        ),
        child: Text(label, style: _display(16, color: _kLime)),
      ),
    );
  }
}

// ─── Basketball Scorer ────────────────────────────────────────────────────────

class _BasketballScorer extends StatefulWidget {
  const _BasketballScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_BasketballScorer> createState() => _BasketballScorerState();
}

class _BasketballScorerState extends State<_BasketballScorer>
    with SingleTickerProviderStateMixin {
  late int _quarterMins;
  late String _t1, _t2;
  int _t1score = 0, _t2score = 0;
  int _t1fouls = 0, _t2fouls = 0;
  int _quarter = 1;
  int _elapsedSeconds = 0;
  bool _timerRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _quarterMins = widget.config.params['quarterMins'] as int? ?? 10;
    _t1 = widget.config.team1;
    _t2 = widget.config.team2;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() => _timerRunning = !_timerRunning);
    if (_timerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
      });
    } else {
      _timer?.cancel();
    }
  }

  void _addScore(int team, int pts) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (team == 1) _t1score += pts; else _t2score += pts;
    });
  }

  void _addFoul(int team) {
    HapticFeedback.lightImpact();
    setState(() {
      if (team == 1) _t1fouls++; else _t2fouls++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qMins = _quarterMins * 60 - _elapsedSeconds;
    final displaySecs = qMins.clamp(0, _quarterMins * 60);
    final mins = displaySecs ~/ 60;
    final secs = displaySecs % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'BASKETBALL',
              info: 'Q$_quarter • $timeStr',
              onExit: widget.onExit,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Scoreboard
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _glowCard(active: true),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_t1.toUpperCase(), style: _display(16, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('$_t1score', style: _display(80, color: _kLime)),
                                    Text('Fouls: $_t1fouls', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text('Q$_quarter', style: _display(28, color: Colors.white.withValues(alpha: 0.3))),
                                  GestureDetector(
                                    onTap: _toggleTimer,
                                    child: Icon(
                                      _timerRunning ? Icons.pause_circle : Icons.play_circle,
                                      color: _timerRunning ? _kLime : Colors.white.withValues(alpha: 0.4),
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_t2.toUpperCase(), style: _display(16, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('$_t2score', style: _display(80, color: _kLime)),
                                    Text('Fouls: $_t2fouls', style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Scoring controls
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              for (final pts in [1, 2, 3])
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () => _addScore(1, pts),
                                    child: Container(
                                      height: 56,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          _kLime.withValues(alpha: pts == 3 ? 0.2 : 0.08),
                                          Colors.transparent
                                        ]),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _kLime.withValues(alpha: pts == 3 ? 0.5 : 0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('+$pts', style: _display(22, color: _kLime)),
                                          Text(pts == 1 ? 'FREE THROW' : pts == 2 ? 'FIELD GOAL' : '3-POINTER',
                                              style: _label(9, color: Colors.white.withValues(alpha: 0.4))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () => _addFoul(1),
                                child: Container(
                                  height: 44, margin: const EdgeInsets.symmetric(vertical: 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                  ),
                                  child: Text('FOUL', style: _label(12, color: AppColors.warning)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 250,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              for (final pts in [1, 2, 3])
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () => _addScore(2, pts),
                                    child: Container(
                                      height: 56,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            _kLime.withValues(alpha: pts == 3 ? 0.2 : 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _kLime.withValues(alpha: pts == 3 ? 0.5 : 0.2)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('+$pts', style: _display(22, color: _kLime)),
                                          Text(pts == 1 ? 'FREE THROW' : pts == 2 ? 'FIELD GOAL' : '3-POINTER',
                                              style: _label(9, color: Colors.white.withValues(alpha: 0.4))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              GestureDetector(
                                onTap: () => _addFoul(2),
                                child: Container(
                                  height: 44, margin: const EdgeInsets.symmetric(vertical: 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                  ),
                                  child: Text('FOUL', style: _label(12, color: AppColors.warning)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_quarter < 4 || _t1score == _t2score)
                      GestureDetector(
                        onTap: () => setState(() {
                          _quarter++;
                          _elapsedSeconds = 0;
                          _t1fouls = 0;
                          _t2fouls = 0;
                          _timer?.cancel();
                          _timerRunning = false;
                        }),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: _glass(radius: 12),
                          child: Text(
                            _quarter < 4 ? 'NEXT QUARTER →' : 'OVERTIME →',
                            style: _label(13, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Paddleball Scorer ────────────────────────────────────────────────────────
// Rules: sets to 6 games (lead by 2), tiebreak at 6-6. Same scoring as Tennis.

class _PaddleballScorer extends StatefulWidget {
  const _PaddleballScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_PaddleballScorer> createState() => _PaddleballScorerState();
}

class _PaddleballScorerState extends State<_PaddleballScorer> {
  late int _bestOf;
  late String _p1, _p2;

  List<(int, int)> _sets = [];
  int _p1games = 0, _p2games = 0;
  int _p1pts = 0, _p2pts = 0;
  bool _inTiebreak = false;
  int _p1tb = 0, _p2tb = 0;
  bool _matchOver = false;
  String _result = '';

  static const _ptLabels = ['0', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _bestOf = widget.config.params['bestOf'] as int? ?? 3;
    _p1 = widget.config.team1;
    _p2 = widget.config.team2;
  }

  int _setsWon(int p) =>
      _sets.where((s) => p == 1 ? s.$1 > s.$2 : s.$2 > s.$1).length;
  int get _setsNeeded => (_bestOf / 2).ceil();

  void _addPoint(int player) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_inTiebreak) {
        if (player == 1) _p1tb++; else _p2tb++;
        _checkTiebreak();
        return;
      }
      if (player == 1) _p1pts++; else _p2pts++;
      _resolvePoint();
    });
  }

  void _undoPoint() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_inTiebreak) {
        if (_p1tb > 0) _p1tb--; else if (_p2tb > 0) _p2tb--;
        return;
      }
      if (_p1pts > 0) _p1pts--; else if (_p2pts > 0) _p2pts--;
    });
  }

  void _resolvePoint() {
    final p1 = _p1pts, p2 = _p2pts;
    bool gameOver = false;
    int winner = 0;
    if (p1 >= 3 && p2 >= 3) {
      if (p1 - p2 >= 2) { gameOver = true; winner = 1; }
      else if (p2 - p1 >= 2) { gameOver = true; winner = 2; }
    } else {
      if (p1 >= 4) { gameOver = true; winner = 1; }
      else if (p2 >= 4) { gameOver = true; winner = 2; }
    }
    if (gameOver) {
      _p1pts = 0; _p2pts = 0;
      if (winner == 1) _p1games++; else _p2games++;
      _checkSetWin();
    }
  }

  void _checkSetWin() {
    if (_p1games >= 6 && _p1games - _p2games >= 2) { _closeSet(); return; }
    if (_p2games >= 6 && _p2games - _p1games >= 2) { _closeSet(); return; }
    if (_p1games == 6 && _p2games == 6) { _inTiebreak = true; return; }
    if (_p1games == 7 || _p2games == 7) { _closeSet(); }
  }

  void _closeSet() {
    _sets.add((_p1games, _p2games));
    _p1games = 0; _p2games = 0;
    final w1 = _setsWon(1), w2 = _setsWon(2);
    if (w1 >= _setsNeeded) { _matchOver = true; _result = '$_p1 WON\n$w1 — $w2 sets'; }
    else if (w2 >= _setsNeeded) { _matchOver = true; _result = '$_p2 WON\n$w2 — $w1 sets'; }
  }

  void _checkTiebreak() {
    final p1 = _p1tb, p2 = _p2tb;
    if (p1 >= 7 && p1 - p2 >= 2) { _inTiebreak = false; _p1tb = 0; _p2tb = 0; _sets.add((7, _p2games)); _p1games = 0; _p2games = 0; final w1 = _setsWon(1); if (w1 >= _setsNeeded) { _matchOver = true; _result = '$_p1 WON'; } }
    else if (p2 >= 7 && p2 - p1 >= 2) { _inTiebreak = false; _p1tb = 0; _p2tb = 0; _sets.add((_p1games, 7)); _p1games = 0; _p2games = 0; final w2 = _setsWon(2); if (w2 >= _setsNeeded) { _matchOver = true; _result = '$_p2 WON'; } }
  }

  String _ptsLabel(int p1, int p2) {
    if (_inTiebreak) return '';
    if (p1 >= 3 && p2 >= 3) {
      if (p1 == p2) return 'Deuce';
      return p1 > p2 ? 'Adv $_p1' : 'Adv $_p2';
    }
    return '${_ptLabels[p1.clamp(0, 3)]} — ${_ptLabels[p2.clamp(0, 3)]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _MatchResultScreen(result: _result, onExit: widget.onExit);
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'PADDLE BALL',
              info: 'Best of $_bestOf sets${_inTiebreak ? " • TIEBREAK" : ""}',
              onExit: widget.onExit,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _glowCard(active: true),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 100),
                              for (int i = 0; i < _bestOf; i++)
                                Expanded(child: Center(child: Text('S${i + 1}', style: _label(10, color: Colors.white.withValues(alpha: 0.4))))),
                              const SizedBox(width: 8),
                              SizedBox(width: 60, child: Center(child: Text(_inTiebreak ? 'TB' : 'PTS', style: _label(10, color: Colors.white.withValues(alpha: 0.4))))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TennisRow(name: _p1, sets: _sets, currentGames: _p1games, isP1: true, pts: _inTiebreak ? _p1tb : _p1pts, bestOf: _bestOf, inTiebreak: _inTiebreak),
                          const SizedBox(height: 8),
                          _TennisRow(name: _p2, sets: _sets, currentGames: _p2games, isP1: false, pts: _inTiebreak ? _p2tb : _p2pts, bestOf: _bestOf, inTiebreak: _inTiebreak),
                          const SizedBox(height: 16),
                          if (!_inTiebreak)
                            Text(_ptsLabel(_p1pts, _p2pts), style: _display(20, color: _kLime)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _undoPoint,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: _glass(radius: 10),
                            child: Text('↩ UNDO', style: _label(12, color: Colors.white.withValues(alpha: 0.6))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _LargePointBtn(label: _p1.toUpperCase(), onTap: () => _addPoint(1))),
                        const SizedBox(width: 12),
                        Expanded(child: _LargePointBtn(label: _p2.toUpperCase(), onTap: () => _addPoint(2))),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pickleball Scorer ────────────────────────────────────────────────────────
// Rules: rally-point to 11, win by 2. Only serving side scores in traditional
// mode — we use rally-point (easier for casual play).

class _PickleballScorer extends StatefulWidget {
  const _PickleballScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_PickleballScorer> createState() => _PickleballScorerState();
}

class _PickleballScorerState extends State<_PickleballScorer> {
  late int _bestOf;
  late String _p1, _p2;
  List<(int, int)> _games = [];
  int _p1pts = 0, _p2pts = 0;
  int _server = 1;
  bool _matchOver = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _bestOf = widget.config.params['bestOf'] as int? ?? 3;
    _p1 = widget.config.team1;
    _p2 = widget.config.team2;
  }

  int _gamesWon(int player) =>
      _games.where((g) => player == 1 ? g.$1 > g.$2 : g.$2 > g.$1).length;
  int get _gamesNeeded => (_bestOf / 2).ceil();

  void _addPoint(int player) {
    HapticFeedback.lightImpact();
    setState(() {
      if (player == 1) { _p1pts++; _server = 1; }
      else { _p2pts++; _server = 2; }
    });
    _checkGameWin();
  }

  void _checkGameWin() {
    final p1 = _p1pts, p2 = _p2pts;
    bool gameOver = false;
    if (p1 >= 11 && p1 - p2 >= 2) gameOver = true;
    else if (p2 >= 11 && p2 - p1 >= 2) gameOver = true;
    if (gameOver) {
      setState(() {
        _games.add((_p1pts, _p2pts));
        _p1pts = 0; _p2pts = 0;
      });
      final w1 = _gamesWon(1), w2 = _gamesWon(2);
      if (w1 >= _gamesNeeded) { setState(() { _matchOver = true; _result = '$_p1 WON\n$w1 — $w2 games'; }); }
      else if (w2 >= _gamesNeeded) { setState(() { _matchOver = true; _result = '$_p2 WON\n$w2 — $w1 games'; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _MatchResultScreen(result: _result, onExit: widget.onExit);
    final isDeuceZone = _p1pts >= 10 && _p2pts >= 10;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'PICKLE BALL',
              info: 'Game ${_games.length + 1} of $_bestOf${isDeuceZone ? " • DEUCE" : ""}',
              onExit: widget.onExit,
            ),
            // Games row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _bestOf; i++) ...[
                    if (i < _games.length)
                      _SetScorePill(p1: _games[i].$1, p2: _games[i].$2, active: false)
                    else if (i == _games.length)
                      _SetScorePill(p1: _p1pts, p2: _p2pts, active: true)
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 44, height: 28,
                        decoration: _glass(radius: 8),
                      ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShuttleScore(p1: _p1, p2: _p2, s1: _p1pts, s2: _p2pts, server: _server),
                    const SizedBox(height: 8),
                    Text('First to 11  •  win by 2',
                        style: _label(11, color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(1),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_kLime.withValues(alpha: 0.2), _kLime.withValues(alpha: 0.05)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.arrow_back, color: _kLime, size: 20),
                          const SizedBox(height: 4),
                          Text(_p1.toUpperCase(), style: _label(11, color: _kLime)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(2),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_kLime.withValues(alpha: 0.05), _kLime.withValues(alpha: 0.2)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.arrow_forward, color: _kLime, size: 20),
                          const SizedBox(height: 4),
                          Text(_p2.toUpperCase(), style: _label(11, color: _kLime)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Volleyball Scorer ────────────────────────────────────────────────────────

class _VolleyballScorer extends StatefulWidget {
  const _VolleyballScorer({required this.config, required this.onExit});
  final _MatchConfig config;
  final VoidCallback onExit;

  @override
  State<_VolleyballScorer> createState() => _VolleyballScorerState();
}

class _VolleyballScorerState extends State<_VolleyballScorer> {
  late int _bestOf;
  late String _t1, _t2;
  List<(int, int)> _sets = [];
  int _t1cur = 0, _t2cur = 0;
  int _servingTeam = 1;
  bool _matchOver = false;
  String _result = '';

  int get _currentSet => _sets.length + 1;
  bool get _isFinalSet => _currentSet == _bestOf;
  int get _pointsNeeded => _isFinalSet ? 15 : 25;

  @override
  void initState() {
    super.initState();
    _bestOf = widget.config.params['bestOf'] as int? ?? 5;
    _t1 = widget.config.team1;
    _t2 = widget.config.team2;
  }

  int _setsWon(int team) => _sets.where((s) => team == 1 ? s.$1 > s.$2 : s.$2 > s.$1).length;
  int get _setsNeeded => (_bestOf / 2).ceil();

  void _addPoint(int team) {
    HapticFeedback.lightImpact();
    setState(() {
      if (team == 1) { _t1cur++; _servingTeam = 1; }
      else { _t2cur++; _servingTeam = 2; }
    });
    _checkSetWin();
  }

  void _checkSetWin() {
    final n = _pointsNeeded;
    bool setOver = false;

    if (_t1cur >= n && _t1cur - _t2cur >= 2) { setOver = true; }
    else if (_t2cur >= n && _t2cur - _t1cur >= 2) { setOver = true; }

    if (setOver) {
      setState(() {
        _sets.add((_t1cur, _t2cur));
        _t1cur = 0; _t2cur = 0;
      });
      final w1 = _setsWon(1), w2 = _setsWon(2);
      if (w1 >= _setsNeeded) {
        setState(() { _matchOver = true; _result = '$_t1 WON\n$w1 — $w2 sets'; });
      } else if (w2 >= _setsNeeded) {
        setState(() { _matchOver = true; _result = '$_t2 WON\n$w2 — $w1 sets'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _MatchResultScreen(result: _result, onExit: widget.onExit);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ScorerTopBar(
              sport: 'VOLLEYBALL',
              info: 'Set $_currentSet of $_bestOf${_isFinalSet ? " • FINAL SET" : ""}',
              onExit: widget.onExit,
            ),
            // Sets progress circles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _bestOf; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 36, height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _sets.length
                            ? (_setsWon(1) > _setsWon(2)
                                ? (i < _setsWon(1) ? _kLime.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05))
                                : Colors.white.withValues(alpha: 0.05))
                            : i == _sets.length
                                ? _kLime.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.03),
                        border: Border.all(
                          color: i == _sets.length
                              ? _kLime.withValues(alpha: 0.6)
                              : i < _sets.length
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: i < _sets.length
                          ? Text(
                              '${_sets[i].$1}-${_sets[i].$2}',
                              style: _label(9, color: Colors.white.withValues(alpha: 0.6)),
                            )
                          : i == _sets.length
                              ? Text('${_currentSet}', style: _label(12, color: _kLime))
                              : null,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ShuttleScore(
                  p1: _t1, p2: _t2,
                  s1: _t1cur, s2: _t2cur,
                  server: _servingTeam,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(1),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_kLime.withValues(alpha: 0.2), _kLime.withValues(alpha: 0.05)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, color: _kLime, size: 20),
                            const SizedBox(height: 4),
                            Text(_t1.toUpperCase(), style: _label(11, color: _kLime)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _addPoint(2),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_kLime.withValues(alpha: 0.05), _kLime.withValues(alpha: 0.2)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward, color: _kLime, size: 20),
                            const SizedBox(height: 4),
                            Text(_t2.toUpperCase(), style: _label(11, color: _kLime)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ScorerTopBar extends StatelessWidget {
  const _ScorerTopBar({
    required this.sport,
    required this.info,
    required this.onExit,
    this.venue,
    this.umpire,
  });
  final String sport;
  final String info;
  final VoidCallback onExit;
  final String? venue;
  final String? umpire;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onExit,
            child: Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              decoration: _glass(radius: 10),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sport, style: _display(22, color: _kLime)),
                Text(info, style: _label(11, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          // venue + umpire meta shown on the right when provided
          if (venue != null || umpire != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (venue != null)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.stadium_outlined, size: 10, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        venue!,
                        style: _label(10, color: Colors.white.withValues(alpha: 0.45)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                if (umpire != null)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.sports_outlined, size: 10, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        umpire!,
                        style: _label(10, color: Colors.white.withValues(alpha: 0.45)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
              ],
            ),
        ],
      ),
    );
  }
}

class _ShuttleScore extends StatelessWidget {
  const _ShuttleScore({
    required this.p1, required this.p2,
    required this.s1, required this.s2,
    required this.server,
  });
  final String p1, p2;
  final int s1, s2, server;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(p1.toUpperCase(), style: _label(13, color: Colors.white, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: s1.toDouble()),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutExpo,
                builder: (_, v, __) => Text(
                  '${v.round()}',
                  style: _display(96, color: _kLime),
                ),
              ),
              if (server == 1)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kLime,
                    boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.6), blurRadius: 8)],
                  ),
                ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('—', style: _display(36, color: Colors.white.withValues(alpha: 0.15))),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(p2.toUpperCase(), style: _label(13, color: Colors.white, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: s2.toDouble()),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutExpo,
                builder: (_, v, __) => Text(
                  '${v.round()}',
                  style: _display(96, color: Colors.white),
                ),
              ),
              if (server == 2)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kLime,
                    boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.6), blurRadius: 8)],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SetScorePill extends StatelessWidget {
  const _SetScorePill({required this.p1, required this.p2, required this.active});
  final int p1, p2;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? _kLime.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? _kLime.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        '$p1-$p2',
        style: _display(16, color: active ? _kLime : Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: _display(18, color: Colors.white)),
        Text(label, style: _label(9, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }
}

class _LargePointBtn extends StatelessWidget {
  const _LargePointBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kLime.withValues(alpha: 0.15), _kLime.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kLime.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.1), blurRadius: 20)],
        ),
        child: Text('POINT\n$label', style: _display(16, color: _kLime), textAlign: TextAlign.center),
      ),
    );
  }
}

class _MatchResultScreen extends StatelessWidget {
  const _MatchResultScreen({required this.result, required this.onExit});
  final String result;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kLime.withValues(alpha: 0.15),
                  border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.3), blurRadius: 40)],
                ),
                child: Text('🏆', style: const TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 32),
              Text('MATCH RESULT', style: _label(12, color: Colors.white.withValues(alpha: 0.4))),
              const SizedBox(height: 12),
              Text(result, style: _display(40, color: _kLime), textAlign: TextAlign.center),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: onExit,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kLime,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Text('NEW MATCH →', style: _display(18, color: AppColors.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Input Widgets ─────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kLime, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SegmentPicker extends StatelessWidget {
  const _SegmentPicker({required this.options, required this.selected, required this.onSelect});
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final isActive = o == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? _kLime.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? _kLime.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                o,
                style: _label(12,
                    color: isActive ? _kLime : Colors.white.withValues(alpha: 0.5),
                    weight: isActive ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _kLime.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _kLime.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: _label(12, color: active ? _kLime : Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
