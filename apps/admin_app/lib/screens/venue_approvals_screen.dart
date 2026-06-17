import 'package:flutter/material.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class VenueApprovalsScreen extends StatefulWidget {
  const VenueApprovalsScreen({super.key});
  @override
  State<VenueApprovalsScreen> createState() => _VenueApprovalsScreenState();
}

class _VenueApprovalsScreenState extends State<VenueApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _venues = [
    (name: 'Koramangala Sports Hub', owner: 'Rajesh Kumar', sports: 'Badminton, Football', city: 'Bangalore', status: 'pending'),
    (name: 'BTM Sports Center', owner: 'Anita Shah', sports: 'Cricket, Basketball', city: 'Bangalore', status: 'pending'),
    (name: 'Whitefield Arena', owner: 'Dev Patel', sports: 'Tennis, Badminton', city: 'Bangalore', status: 'pending'),
  ];
  static const _coaches = [
    (name: 'Suresh Phogat', sport: 'Badminton', exp: '8 years', cert: 'BWF Level 2', status: 'pending'),
    (name: 'Meera Krishnan', sport: 'Yoga', exp: '5 years', cert: 'RYT 500', status: 'pending'),
  ];

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
              tabs: const [Tab(text: 'Venues (3)'), Tab(text: 'Coaches (2)'), Tab(text: 'Approved')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _ApprovalList(items: _venues.map((v) => _ApprovalItem(
                    title: v.name,
                    subtitle: '${v.owner} · ${v.city}',
                    detail: v.sports,
                    type: 'venue',
                  )).toList()),
                  _ApprovalList(items: _coaches.map((c) => _ApprovalItem(
                    title: c.name,
                    subtitle: '${c.sport} · ${c.exp}',
                    detail: c.cert,
                    type: 'coach',
                  )).toList()),
                  const Center(child: Text('No pending approvals', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF9E9E9E)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalItem {
  const _ApprovalItem({required this.title, required this.subtitle, required this.detail, required this.type});
  final String title, subtitle, detail, type;
}

class _ApprovalList extends StatefulWidget {
  const _ApprovalList({required this.items});
  final List<_ApprovalItem> items;
  @override
  State<_ApprovalList> createState() => _ApprovalListState();
}

class _ApprovalListState extends State<_ApprovalList> {
  final Set<int> _approved = {};
  final Set<int> _rejected = {};

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final item = widget.items[i];
        final approved = _approved.contains(i);
        final rejected = _rejected.contains(i);
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
                child: Icon(
                  item.type == 'venue' ? Icons.stadium_outlined : Icons.person_outlined,
                  color: _kLime, size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: _head(16)),
                Text(item.subtitle, style: _body(11)),
              ])),
            ]),
            const SizedBox(height: 10),
            Text(item.detail, style: _body(12, c: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 12),
            if (!approved && !rejected)
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rejected.add(i)),
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
                    onTap: () => setState(() => _approved.add(i)),
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
                  style: _head(14, c: approved ? const Color(0xFF58B48F) : const Color(0xFFE34B34)),
                ),
              ),
          ]),
        );
      },
    );
  }
}
