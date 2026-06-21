import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedRole = 0; // 0=Player, 1=Vendor, 2=Admin

  static const _roles = [
    (label: 'PLAYER', icon: Icons.sports_soccer, desc: 'Find. Play. Rise.', color: Color(0xFFC8F23A)),
    (label: 'VENDOR', icon: Icons.stadium_outlined, desc: 'Manage your arena', color: Color(0xFF3A8DCC)),
    (label: 'ADMIN', icon: Icons.shield_outlined, desc: 'Command center', color: Color(0xFF9C27B0)),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final phone = '+91${_phoneController.text.trim()}';
    try {
      await ref.read(authRepositoryProvider).sendOtp(phone: phone);
      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/auth/otp', extra: phone);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final heroHeight = size.height * 0.42;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Hero image section ────────────────────────────────────────────
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Soccer match photo
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAnvfjC1XSr5sc-w5wwDY67l8oGC8tkVSbVw6sKv_tWZ09WSdBEUMAwQ1Df06qucqCJPHQ0s3o8gs0qU5A-RTzTFavqjhd8u06l5Y9mpKSrx-fSwdcHKg3kaGmB8MeLfS7geyc31jYb-wzmDGvZJIG0kiLR-caFP0GsU3t5XuEYyFCk-4VNmeJBvjR37VLuifzeZI3vPMqWXWoJSjgeG_M3X1-H0N2AHMEJk-KBEhYHN2ngQ0TRykTdoMZ6Gkso39vM4l4OJztek',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A4030), Color(0xFF0D1525)],
                      ),
                    ),
                  ),
                ),

                // Dark overlay to keep text legible
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),

                // Decorative accent line
                Positioned(
                  top: heroHeight * 0.2,
                  left: -20,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: Container(
                      width: 2,
                      height: heroHeight * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.brandGreen400.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradient fade at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                ),

                // FieldUp brand text
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Text(
                      'FieldUp',
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.brandGreen400,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Glassmorphic form card ────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        // ── Role selector ─────────────────────────────────
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(_roles.length, (i) {
                            final role = _roles[i];
                            final active = _selectedRole == i;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(right: i < _roles.length - 1 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? role.color.withValues(alpha: 0.12)
                                        : Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: active
                                          ? role.color.withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: active ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(role.icon, size: 18,
                                          color: active ? role.color : Colors.white.withValues(alpha: 0.3)),
                                      const SizedBox(height: 4),
                                      Text(role.label,
                                          style: TextStyle(
                                            fontFamily: 'Barlow Condensed',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: active ? role.color : Colors.white.withValues(alpha: 0.4),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: _roles[_selectedRole].color,
                            height: 1.0,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Login to your FieldUp account',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Phone input
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mobile Number',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: AppColors.neutral900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.08),
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.1),
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '+91',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            color: AppColors.neutral900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          color: AppColors.neutral900,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your phone number',
                                          counterText: '',
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          hintStyle: TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppColors.neutral600
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Enter your mobile number';
                                          }
                                          if (v.trim().length != 10) {
                                            return 'Enter a valid 10-digit number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Get OTP button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGreen400,
                              foregroundColor: AppColors.brandGreen700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.brandGreen700,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get OTP',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),

                        // Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () =>
                                context.push('/auth/create-account'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neutral900,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
