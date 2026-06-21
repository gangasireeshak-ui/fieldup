import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fieldup_design_system/fieldup_design_system.dart';
import 'auth_provider.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  bool _agreeToTerms = false;
  bool _agreeToNotifications = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final uid = repo.currentUser?.id;
      if (uid != null) {
        await repo.upsertProfile(
          userId: uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          referralCodeUsed: _referralController.text.trim().isEmpty ? null : _referralController.text.trim(),
        );
      }
      if (mounted) context.go('/auth/interests');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Hero image — full-width, shrinks when keyboard opens
            Flexible(
              child: Container(
                width: double.infinity,
                color: AppColors.neutral300,
              ),
            ),

            // Bottom sheet form
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle — 48×6dp, neutral200
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: AppTextStyles.headingLG,
                          ),
                          const SizedBox(height: 32),

                          const _FieldLabel('Name'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'John Doe',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          const _FieldLabel('Mobile Number'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _phoneController,
                            readOnly: true,
                            decoration: InputDecoration(
                              fillColor: AppColors.neutral100,
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                child: Text(
                                  '+91',
                                  style: AppTextStyles.bodyLG.copyWith(
                                    color: AppColors.neutral600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const _FieldLabel('E-mail (Optional)'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'john@example.com',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              return emailRegex.hasMatch(v.trim())
                                  ? null
                                  : 'Enter a valid email';
                            },
                          ),
                          const SizedBox(height: 16),

                          const _FieldLabel('Referral Code'),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _referralController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Enter code',
                            ),
                          ),
                          const SizedBox(height: 20),

                          _ConsentRow(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyMD.copyWith(
                                  color: AppColors.neutral700,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: AppTextStyles.bodyMD.copyWith(
                                      color: AppColors.teal600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.teal600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: AppTextStyles.bodyMD.copyWith(
                                      color: AppColors.teal600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.teal600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _ConsentRow(
                            value: _agreeToNotifications,
                            onChanged: (v) => setState(
                              () => _agreeToNotifications = v ?? false,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _agreeToNotifications =
                                    !_agreeToNotifications,
                              ),
                              child: Text(
                                'I agree to receive emails and notifications',
                                style: AppTextStyles.bodyMD.copyWith(
                                  color: AppColors.neutral700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Get OTP'),
                          ),
                        ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.label);
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.teal500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}
