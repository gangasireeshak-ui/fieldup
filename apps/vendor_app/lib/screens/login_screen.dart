import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─── Shared vendor design tokens ──────────────────────────────────────────────
const _kBlue = Color(0xFF3A8DCC);   // Vendor accent — Turf Blue
const _kBg   = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

BoxDecoration _card({bool active = false}) => BoxDecoration(
  color: active ? _kBlue.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: active ? _kBlue.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
  ),
);

// ─── Vendor Login ─────────────────────────────────────────────────────────────

class VendorLoginScreen extends StatelessWidget {
  const VendorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBlue.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.stadium, color: _kBlue, size: 14),
                      const SizedBox(width: 6),
                      Text('VENUE OWNER', style: _body(11, c: _kBlue)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('VENUE\nBUSINESS OS', style: _head(48)),
                  const SizedBox(height: 8),
                  Text('Manage your arena like a pro', style: _body(15)),
                  const Spacer(),
                  // Phone field
                  TextField(
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '+91 Phone Number',
                      hintStyle: _body(15),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.white.withValues(alpha: 0.3), size: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _kBlue, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/dashboard'),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kBlue,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: _kBlue.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: Text('ENTER COMMAND CENTER →', style: _head(16, c: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
