import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Supabase client ────────────────────────────────────────────────────────────

final adminSupabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Auth state stream ──────────────────────────────────────────────────────────

final adminAuthStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(adminSupabaseProvider).auth.onAuthStateChange,
);

// ── Convenience bool ───────────────────────────────────────────────────────────

final adminIsAuthProvider = Provider<bool>((ref) {
  final session = ref.watch(adminSupabaseProvider).auth.currentSession;
  return session != null;
});

// ── Demo bypass ────────────────────────────────────────────────────────────────

final adminDemoAuthProvider = StateProvider<bool>((ref) => false);

final adminAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(adminDemoAuthProvider) || ref.watch(adminIsAuthProvider);
});

// ── Auth repository ────────────────────────────────────────────────────────────

final adminAuthRepoProvider = Provider<AdminAuthRepository>(
  (ref) => AdminAuthRepository(ref.watch(adminSupabaseProvider)),
);

class AdminAuthRepository {
  AdminAuthRepository(this._db);
  final SupabaseClient _db;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _db.auth.signInWithPassword(
      email: email, password: password,
    );
    if (res.session == null) throw Exception('Invalid credentials');
  }

  Future<void> signOut() => _db.auth.signOut();

  String? get currentUserId => _db.auth.currentUser?.id;
}
