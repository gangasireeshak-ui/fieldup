import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Supabase client ────────────────────────────────────────────────────────────

final vendorSupabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Auth state (stream) ────────────────────────────────────────────────────────

final vendorAuthStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(vendorSupabaseProvider).auth.onAuthStateChange,
);

// ── Convenience bool ───────────────────────────────────────────────────────────

final vendorIsAuthProvider = Provider<bool>((ref) {
  final session = ref.watch(vendorSupabaseProvider).auth.currentSession;
  return session != null;
});

// ── Demo bypass (lets us test without a live Supabase project) ─────────────────

final vendorDemoAuthProvider = StateProvider<bool>((ref) => false);

final vendorAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(vendorDemoAuthProvider) || ref.watch(vendorIsAuthProvider);
});

// ── Auth repository ────────────────────────────────────────────────────────────

final vendorAuthRepoProvider = Provider<VendorAuthRepository>(
  (ref) => VendorAuthRepository(ref.watch(vendorSupabaseProvider)),
);

class VendorAuthRepository {
  VendorAuthRepository(this._db);
  final SupabaseClient _db;

  Future<void> sendOtp({required String phone}) =>
      _db.auth.signInWithOtp(phone: phone);

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final res = await _db.auth.verifyOTP(
      phone: phone, token: otp, type: OtpType.sms,
    );
    if (res.session == null) throw Exception('OTP verification failed');
  }

  Future<void> signOut() => _db.auth.signOut();

  String? get currentUserId => _db.auth.currentUser?.id;
}
