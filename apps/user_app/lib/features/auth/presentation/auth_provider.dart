import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

// ── Onboarding state ───────────────────────────────────────────────────────────
// StateProvider so it can be updated synchronously; initialized from
// SharedPreferences in main.dart via ProviderScope overrides.

final onboardingDoneProvider = StateProvider<bool>((ref) => false);

// ── Supabase client provider ───────────────────────────────────────────────────

@riverpod
SupabaseClient supabaseClient(Ref ref) =>
    Supabase.instance.client;

// ── Auth state ─────────────────────────────────────────────────────────────────

final demoAuthProvider = StateProvider<bool>((ref) => false);

@riverpod
Stream<AuthState> authStateStream(Ref ref) =>
    ref.watch(supabaseClientProvider).auth.onAuthStateChange;

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(demoAuthProvider);
}

// ── Auth repository ─────────────────────────────────────────────────────────

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));

class AuthRepository {
  AuthRepository(this._supabase);
  final SupabaseClient _supabase;

  Future<void> sendOtp({required String phone}) async {
    await _supabase.auth.signInWithOtp(phone: phone);
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _supabase.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    if (response.session == null) {
      throw Exception('OTP verification failed');
    }
  }

  Future<void> createProfile({
    required String name,
    String? email,
    String? referralCode,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': name,
      if (email != null) 'email': email,
      if (referralCode != null) 'referral_code_used': referralCode,
    });
  }

  Future<void> saveInterests({required List<String> sports}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('profiles').update({
      'sport_preferences': sports,
    }).eq('id', userId);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
