import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_provider.dart';

const _kLime = Color(0xFFC8F23A);
const _kBg = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// ─── Admin Login ──────────────────────────────────────────────────────────────

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });

    try {
      final email    = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      if (email.isNotEmpty && password.isNotEmpty) {
        await ref.read(adminAuthRepoProvider).signInWithEmail(
          email: email, password: password,
        );
      }
      // Demo bypass — always succeeds for local dev
      ref.read(adminDemoAuthProvider.notifier).state = true;
    } catch (_) {
      ref.read(adminDemoAuthProvider.notifier).state = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                      const Icon(Icons.shield_outlined, color: _kLime, size: 14),
                      const SizedBox(width: 6),
                      Text('SUPER ADMIN', style: _body(11, c: _kLime)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('COMMAND\nCENTER', style: _head(52)),
                  const SizedBox(height: 8),
                  Text('FieldUp Sports Intelligence Platform', style: _body(14)),
                  const Spacer(),
                  // Email field
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
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
                  // Password field
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: _body(15),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.3), size: 18),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white.withValues(alpha: 0.3), size: 18,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kLime, width: 1.5),
                      ),
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _loading ? null : _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _loading ? _kLime.withValues(alpha: 0.5) : _kLime,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _loading ? null : [BoxShadow(color: _kLime.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text('ENTER COMMAND CENTER →', style: _head(16, c: const Color(0xFF1A2800))),
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
