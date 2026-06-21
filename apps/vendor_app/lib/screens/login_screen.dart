import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_provider.dart';

const _kBlue = Color(0xFF3A8DCC);
const _kBg   = Colors.black;

TextStyle _head(double sz, {Color c = Colors.white}) => TextStyle(
  fontFamily: 'Barlow Condensed', fontSize: sz, fontWeight: FontWeight.w800,
  color: c, letterSpacing: -0.5, height: 1.0,
);
TextStyle _body(double sz, {Color c = const Color(0xFF9E9E9E)}) => TextStyle(
  fontFamily: 'Inter', fontSize: sz, fontWeight: FontWeight.w500, color: c,
);

// ─── Vendor Login ─────────────────────────────────────────────────────────────

class VendorLoginScreen extends ConsumerStatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  ConsumerState<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends ConsumerState<VendorLoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    setState(() { _loading = true; _error = null; });

    try {
      if (phone.isNotEmpty) {
        await ref.read(vendorAuthRepoProvider).sendOtp(phone: phone);
        // For demo: bypass OTP and go straight in via demoAuth flag
      }
      // Demo bypass — works without a Supabase project configured
      ref.read(vendorDemoAuthProvider.notifier).state = true;
    } catch (_) {
      // Fallback to demo mode so the UI is always navigable
      ref.read(vendorDemoAuthProvider.notifier).state = true;
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _kBlue.withValues(alpha: 0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.stadium, color: _kBlue, size: 14),
                      const SizedBox(width: 6),
                      Text('VENUE OWNER', style: _body(11, c: _kBlue)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('VENUE\nBUSINESS OS', style: _head(48)),
                  const SizedBox(height: 8),
                  Text('Manage your arena like a pro', style: _body(15)),
                  const Spacer(),
                  TextField(
                    controller: _phoneCtrl,
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
                        borderSide: const BorderSide(color: _kBlue, width: 1.5),
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
                        color: _loading ? _kBlue.withValues(alpha: 0.5) : _kBlue,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _loading ? null : [BoxShadow(color: _kBlue.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('ENTER COMMAND CENTER →', style: _head(16, c: Colors.white)),
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
