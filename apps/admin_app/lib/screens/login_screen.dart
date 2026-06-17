import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned(
            top: -120, left: -120,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kLime.withValues(alpha: 0.04),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kLime.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kLime.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shield_outlined, color: _kLime, size: 14),
                      const SizedBox(width: 6),
                      Text('SUPER ADMIN', style: _body(11, c: _kLime)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('COMMAND\nCENTER', style: _head(52)),
                  const SizedBox(height: 8),
                  Text('FieldUp Sports Intelligence Platform', style: _body(14)),
                  const Spacer(),
                  TextField(
                    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Admin Email',
                      hintStyle: _body(15),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      prefixIcon: Icon(Icons.alternate_email, color: Colors.white.withValues(alpha: 0.3), size: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kLime, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: _body(15),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.3), size: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kLime, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/command'),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kLime,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: Text('ENTER COMMAND CENTER →', style: _head(16, c: const Color(0xFF1A2800))),
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
