import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._db);
  final SupabaseClient _db;

  User? get currentUser => _db.auth.currentUser;
  Session? get currentSession => _db.auth.currentSession;
  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _db.auth.onAuthStateChange;

  Future<void> sendOtp({required String phone}) async {
    await _db.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    final res = await _db.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    if (res.session == null) throw Exception('OTP verification failed');
    return res;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _db.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.session == null) throw Exception('Sign-in failed');
    return res;
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<void> upsertProfile({
    required String userId,
    String? name,
    String? email,
    String? referralCodeUsed,
  }) async {
    await _db.from('users').upsert({
      'id': userId,
      'phone': currentUser?.phone ?? '',
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (referralCodeUsed != null) 'referral_code_used': referralCodeUsed,
    });
  }

  Future<void> saveSportInterests({
    required String userId,
    required List<String> sports,
  }) async {
    await _db.from('users').update({
      'sport_preferences': sports,
    }).eq('id', userId);
  }
}
