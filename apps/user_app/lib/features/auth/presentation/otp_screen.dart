import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focuses = List.generate(6, (_) => FocusNode());
  String _otp = '';
  bool _isLoading = false;
  bool _isError = false;
  int _retrySeconds = 45;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_retrySeconds > 0) _retrySeconds--; });
      return _retrySeconds > 0;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  String get _maskedPhone {
    if (widget.phone.length < 6) return widget.phone;
    return '${widget.phone.substring(0, 6)}****${widget.phone.substring(widget.phone.length - 2)}';
  }

  Future<void> _verify() async {
    if (_otp.length < 6 || _isLoading) return;
    setState(() { _isLoading = true; _isError = false; });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
        phone: widget.phone,
        token: _otp,
      );
      if (mounted) context.go('/auth/create-account');
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _isError = true; });
    }
  }

  Future<void> _resendOtp() async {
    await ref.read(authRepositoryProvider).sendOtp(phone: widget.phone);
    if (mounted) setState(() => _retrySeconds = 45);
    _startCountdown();
  }

  void _onDigit(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focuses[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focuses[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    setState(() => _otp = otp);
    if (otp.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final min = (_retrySeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_retrySeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative lime glow orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen400.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen400.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Centered glass card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      constraints: const BoxConstraints(maxWidth: 440),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414).withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Top lime accent line
                          Container(
                            height: 1,
                            margin: const EdgeInsets.only(bottom: 28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.brandGreen400.withValues(alpha: 0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Shield icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.neutral300.withValues(alpha: 0.4),
                              border: Border.all(
                                color: AppColors.neutral500.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: AppColors.brandGreen400,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'VERIFY OTP',
                            style: TextStyle(
                              fontFamily: 'Barlow Condensed',
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: AppColors.brandGreen400,
                              letterSpacing: -1.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),

                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.neutral700,
                              ),
                              children: [
                                const TextSpan(text: 'Sent to '),
                                TextSpan(
                                  text: _maskedPhone,
                                  style: const TextStyle(
                                    color: AppColors.neutral900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 6 OTP input boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) => _OtpBox(
                              controller: _controllers[i],
                              focusNode: _focuses[i],
                              isError: _isError,
                              isFilled: _controllers[i].text.isNotEmpty,
                              onChanged: (v) => _onDigit(i, v),
                            )),
                          ),

                          if (_isError) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Incorrect OTP. Please try again.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ],

                          // Resend timer
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: _retrySeconds > 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Resend OTP in ',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: AppColors.neutral700,
                                        ),
                                      ),
                                      Text(
                                        '$min:$sec',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brandGreen400,
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: _resendOtp,
                                    child: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandGreen400,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.brandGreen400,
                                      ),
                                    ),
                                  ),
                          ),

                          // Verify & Proceed button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (_otp.length < 6 || _isLoading)
                                  ? null
                                  : _verify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandGreen400,
                                foregroundColor: AppColors.brandGreen700,
                                disabledBackgroundColor:
                                    AppColors.brandGreen400.withValues(alpha: 0.3),
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
                                          'VERIFY & PROCEED',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 18),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Change phone number
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Change Phone Number',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.neutral700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.neutral700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isError,
    required this.isFilled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isError;
  final bool isFilled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Barlow Condensed',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isError
              ? AppColors.error
              : isFilled
                  ? AppColors.brandGreen400
                  : AppColors.neutral900,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.neutral300.withValues(alpha: 0.5),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: isError
                  ? AppColors.error
                  : isFilled
                      ? AppColors.brandGreen400
                      : AppColors.neutral500.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.brandGreen400,
              width: 2,
            ),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.neutral500.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
