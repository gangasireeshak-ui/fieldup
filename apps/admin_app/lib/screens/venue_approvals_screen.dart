import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_core/fieldup_core.dart';
import '../providers.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class VenueApprovalsScreen extends ConsumerStatefulWidget {
  const VenueApprovalsScreen({super.key});
  @override
  ConsumerState<VenueApprovalsScreen> createState() => _VenueApprovalsScreenState();
}

class _VenueApprovalsScreenState extends ConsumerState<VenueApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingVenuesAsync = ref.watch(pendingVenuesProvider);
    final pendingCoachesAsync = ref.watch(pendingCoachesProvider);

    final venueCount = pendingVenuesAsync.asData?.value.length ?? 0;
    final coachCount = (pendingCoachesAsync.asData?.value.length ?? 0);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text('APPROVAL CENTER', style: _head(28, c: _kLime)),
            ),
            TabBar(
              controller: _tabs,
              indicatorColor: _kLime,
              labelColor: _kLime,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.3),
              labelStyle: _body(12, c: _kLime),
              unselectedLabelStyle: _body(12),
              tabs: [
                Tab(text: 'Venues ($venueCount)'),
                Tab(text: 'Coaches ($coachCount)'),
                const Tab(text: 'Approved'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  // ── Pending venues ──────────────────────────────────────────
                  pendingVenuesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e', style: _body(13))),
                    data: (venues) => venues.isEmpty
                        ? Center(child: Text('No pending venues 🎉', style: _body(13)))
                        : _VenueApprovalList(venues: venues, ref: ref),
                  ),
                  // ── Pending coaches ─────────────────────────────────────────
                  pendingCoachesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e', style: _body(13))),
                    data: (coaches) => coaches.isEmpty
                        ? Center(child: Text('No pending coaches 🎉', style: _body(13)))
                        : _CoachApprovalList(coaches: coaches, ref: ref),
                  ),
                  // ── Approved (placeholder) ──────────────────────────────────
                  Center(
                    child: Text('Approved venues/coaches appear here.',
                        style: _body(13, c: Colors.white.withValues(alpha: 0.4))),
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

// ── Venue approval list ───────────────────────────────────────────────────────

class _VenueApprovalList extends ConsumerStatefulWidget {
  const _VenueApprovalList({required this.venues, required this.ref});
  final List<Venue> venues;
  final WidgetRef ref;
  @override
  ConsumerState<_VenueApprovalList> createState() => _VenueApprovalListState();
}

class _VenueApprovalListState extends ConsumerState<_VenueApprovalList> {
  final Set<String> _approved = {};
  final Set<String> _rejected = {};

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.venues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final v = widget.venues[i];
        final approved = _approved.contains(v.id);
        final rejected = _rejected.contains(v.id);
        return _ApprovalCard(
          icon: Icons.stadium_outlined,
          title: v.name,
          subtitle: '${v.city} · ${v.address}',
          detail: v.sports.join(', '),
          approved: approved,
          rejected: rejected,
          onApprove: () async {
            await ref.read(adminAuthRepoProvider).approveVenue(v.id);
            setState(() => _approved.add(v.id));
            ref.invalidate(pendingVenuesProvider);
            ref.invalidate(platformKpisProvider);
          },
          onReject: () async {
            await ref.read(adminAuthRepoProvider).rejectVenue(v.id);
            setState(() => _rejected.add(v.id));
            ref.invalidate(pendingVenuesProvider);
            ref.invalidate(platformKpisProvider);
          },
        );
      },
    );
  }
}

// ── Coach approval list ────────────────────────────────────────────────────────

class _CoachApprovalList extends ConsumerStatefulWidget {
  const _CoachApprovalList({required this.coaches, required this.ref});
  final List<Map<String, dynamic>> coaches;
  final WidgetRef ref;
  @override
  ConsumerState<_CoachApprovalList> createState() => _CoachApprovalListState();
}

class _CoachApprovalListState extends ConsumerState<_CoachApprovalList> {
  final Set<String> _approved = {};
  final Set<String> _rejected = {};

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.coaches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final c = widget.coaches[i];
        final user = c['users'] as Map? ?? {};
        final id = c['id'] as String? ?? '';
        final name = user['name'] as String? ?? 'Coach';
        final sports = (c['sports'] as List?)?.cast<String>().join(', ') ?? '';
        final exp = '${c['experience_years'] ?? 0} years exp';
        final approved = _approved.contains(id);
        final rejected = _rejected.contains(id);
        return _ApprovalCard(
          icon: Icons.person_outlined,
          title: name,
          subtitle: '$sports · $exp',
          detail: (c['certifications'] as List?)?.cast<String>().join(', ') ?? '',
          approved: approved,
          rejected: rejected,
          onApprove: () async {
            await ref.read(adminAuthRepoProvider).approveCoach(id);
            setState(() => _approved.add(id));
            ref.invalidate(pendingCoachesProvider);
          },
          onReject: () async {
            await ref.read(adminAuthRepoProvider).rejectCoach(id);
            setState(() => _rejected.add(id));
            ref.invalidate(pendingCoachesProvider);
          },
        );
      },
    );
  }
}

// ── Shared approval card ─────────────────────────────────────────────────────

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.approved,
    required this.rejected,
    required this.onApprove,
    required this.onReject,
  });
  final IconData icon;
  final String title, subtitle, detail;
  final bool approved, rejected;
  final VoidCallback onApprove, onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: approved
            ? const Color(0xFF58B48F).withValues(alpha: 0.08)
            : rejected
                ? const Color(0xFFE34B34).withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: approved
              ? const Color(0xFF58B48F).withValues(alpha: 0.4)
              : rejected
                  ? const Color(0xFFE34B34).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _kLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kLime, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: _head(16)),
            Text(subtitle, style: _body(11)),
          ])),
        ]),
        if (detail.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(detail, style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
        ],
        const SizedBox(height: 12),
        if (!approved && !rejected)
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: onReject,
                child: Container(
                  height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE34B34).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE34B34).withValues(alpha: 0.4)),
                  ),
                  child: Text('REJECT', style: _head(14, c: const Color(0xFFE34B34))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onApprove,
                child: Container(
                  height: 40, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kLime.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kLime.withValues(alpha: 0.5)),
                  ),
                  child: Text('APPROVE', style: _head(14, c: _kLime)),
                ),
              ),
            ),
          ])
        else
          Container(
            height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(
              color: approved
                  ? const Color(0xFF58B48F).withValues(alpha: 0.1)
                  : const Color(0xFFE34B34).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              approved ? '✓ APPROVED' : '✗ REJECTED',
              style: _head(14, c: approved
                  ? const Color(0xFF58B48F)
                  : const Color(0xFFE34B34)),
            ),
          ),
      ]),
    );
  }
}
