import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_supabase_client/fieldup_supabase_client.dart';
import 'package:fieldup_core/fieldup_core.dart';

// ── Supabase client ───────────────────────────────────────────────────────────
final adminSupabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Auth ──────────────────────────────────────────────────────────────────────
final adminAuthRepoProvider = Provider<AdminAuthRepository>(
  (ref) => AdminAuthRepository(ref.watch(adminSupabaseProvider)),
);

final adminDemoAuthProvider = StateProvider<bool>((_) => false);

final adminAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(adminSupabaseProvider).auth.currentSession;
  return session != null || ref.watch(adminDemoAuthProvider);
});

// ── Platform KPIs ─────────────────────────────────────────────────────────────
final platformKpisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(adminSupabaseProvider);

  // Count users
  final usersRes = await db.from('users').select('id').count();
  final totalUsers = usersRes.count;

  // Today's confirmed bookings + revenue
  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  final bookingsRes = await db
      .from('bookings')
      .select('final_amount')
      .eq('status', 'confirmed')
      .gte('created_at', todayStr);
  final bookings = bookingsRes as List;
  final totalRevToday =
      bookings.fold<int>(0, (s, b) => s + (b['final_amount'] as int? ?? 0));

  // Live matches count
  final liveRes = await db.from('matches').select('id').eq('status', 'live').count();
  final liveMatches = liveRes.count;

  // Pending venue approvals
  final pendingRes = await db.from('venues').select('id').eq('is_active', false).count();
  final pendingVenues = pendingRes.count;

  return {
    'total_users': totalUsers,
    'bookings_today': bookings.length,
    'revenue_today_paise': totalRevToday,
    'live_matches': liveMatches,
    'pending_venues': pendingVenues,
  };
});

// ── Pending approvals ─────────────────────────────────────────────────────────
final pendingVenuesProvider = FutureProvider<List<Venue>>((ref) async {
  final data = await ref.watch(adminSupabaseProvider)
      .from('venues')
      .select()
      .eq('is_active', false)
      .order('created_at', ascending: false);
  return (data as List).map((j) => Venue.fromJson(j)).toList();
});

final pendingCoachesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await ref.watch(adminSupabaseProvider)
      .from('coaches')
      .select('*, users!inner(name, phone)')
      .eq('is_verified', false)
      .order('created_at', ascending: false);
  return (data as List).cast<Map<String, dynamic>>();
});

// ── Admin repository for approval actions ─────────────────────────────────────
class AdminAuthRepository {
  AdminAuthRepository(this._db);
  final SupabaseClient _db;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _db.auth.signInWithPassword(
        email: email, password: password);
    if (res.session == null) throw Exception('Invalid credentials');
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<void> approveVenue(String venueId) async =>
      _db.from('venues').update({'is_active': true}).eq('id', venueId);

  Future<void> rejectVenue(String venueId) async =>
      _db.from('venues').delete().eq('id', venueId);

  Future<void> approveCoach(String coachId) async =>
      _db.from('coaches').update({'is_verified': true}).eq('id', coachId);

  Future<void> rejectCoach(String coachId) async =>
      _db.from('coaches').delete().eq('id', coachId);
}
