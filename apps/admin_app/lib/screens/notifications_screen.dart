import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;
TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _segment = 'all';
  bool _sent = false;

  static const _segments = [
    (key: 'all', label: 'All Users', count: '2,847'),
    (key: 'players', label: 'Players', count: '2,341'),
    (key: 'vendors', label: 'Vendors', count: '156'),
    (key: 'inactive', label: 'Inactive 7d', count: '432'),
  ];

  static const _templates = [
    (title: 'Book for Free!', body: 'Launch offer: play at any venue today at ₹0'),
    (title: 'New Tournament', body: 'Register for the Bangalore Open 2026 — limited spots!'),
    (title: 'Reward Points', body: 'You\'ve earned 50 Karma Points from your last booking!'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PUSH NOTIFICATION STUDIO', style: _head(26, c: _kLime)),
            Text('Reach your players instantly', style: _body(12)),
            const SizedBox(height: 20),

            if (_sent)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF58B48F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF58B48F).withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF58B48F), size: 18),
                  const SizedBox(width: 10),
                  Text('Notification sent to ${_segments.firstWhere((s) => s.key == _segment).count} users!',
                      style: _body(13, c: const Color(0xFF58B48F))),
                ]),
              ),

            // Segment selector
            Text('TARGET SEGMENT', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _segments.map((s) {
                final active = _segment == s.key;
                return GestureDetector(
                  onTap: () => setState(() => _segment = s.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? _kLime.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? _kLime.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(s.label, style: _body(12, c: active ? _kLime : Colors.white.withValues(alpha: 0.6))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: active ? _kLime.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(s.count, style: _body(9, c: active ? _kLime : Colors.white.withValues(alpha: 0.4))),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Templates
            Text('QUICK TEMPLATES', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 8),
            ..._templates.map((t) => GestureDetector(
              onTap: () {
                _titleCtrl.text = t.title;
                _bodyCtrl.text = t.body;
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.title, style: _body(12, c: Colors.white)),
                    Text(t.body, style: _body(10), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  const Icon(Icons.north_east, size: 14, color: Color(0xFF9E9E9E)),
                ]),
              ),
            )),
            const SizedBox(height: 16),

            // Compose
            Text('COMPOSE', style: _body(11, c: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(height: 8),
            _NotifInput(controller: _titleCtrl, hint: 'Notification title'),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Message body...',
                hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF9E9E9E), fontSize: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kLime, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (_titleCtrl.text.isEmpty || _bodyCtrl.text.isEmpty) return;
                HapticFeedback.heavyImpact();
                setState(() => _sent = true);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) setState(() => _sent = false);
                });
              },
              child: Container(
                height: 52, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kLime,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Text('SEND NOTIFICATION →', style: _head(16, c: const Color(0xFF1A2800))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _NotifInput extends StatelessWidget {
  const _NotifInput({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Inter', color: Color(0xFF9E9E9E), fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kLime, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
