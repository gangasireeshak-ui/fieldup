import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldup_supabase_client/fieldup_supabase_client.dart';
import 'package:fieldup_core/fieldup_core.dart';

// ── Supabase client ───────────────────────────────────────────────────────────
final vendorSupabaseProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Auth ──────────────────────────────────────────────────────────────────────
final vendorAuthRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(vendorSupabaseProvider)),
);

final vendorDemoAuthProvider = StateProvider<bool>((_) => false);

final vendorAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(vendorSupabaseProvider).auth.currentSession;
  return session != null || ref.watch(vendorDemoAuthProvider);
});

// ── Venue & booking repos ─────────────────────────────────────────────────────
final vendorVenueRepoProvider = Provider<VenueRepository>(
  (ref) => VenueRepository(ref.watch(vendorSupabaseProvider)),
);

final vendorBookingRepoProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(vendorSupabaseProvider)),
);

// ── My venues ─────────────────────────────────────────────────────────────────
final myVenuesProvider = FutureProvider<List<Venue>>((ref) {
  final uid = ref.watch(vendorSupabaseProvider).auth.currentUser?.id;
  if (uid == null) return Future.value([]);
  return ref.watch(vendorVenueRepoProvider).fetchMyVenues(uid);
});

// ── Revenue stats for a venue ─────────────────────────────────────────────────
final venueRevenueProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, venueId) =>
        ref.watch(vendorBookingRepoProvider).fetchRevenueStats(venueId));

// ── Courts for first owned venue ───────────────────────────────────────────────
final venueCourtsFamilyProvider =
    FutureProvider.family<List<Court>, String>((ref, venueId) =>
        ref.watch(vendorVenueRepoProvider).fetchCourts(venueId));

// ── Toggle court active via repo ──────────────────────────────────────────────
Future<void> toggleCourt(WidgetRef ref, String courtId, {required bool active}) =>
    ref.read(vendorVenueRepoProvider).toggleCourtActive(courtId, active: active);
final todaysBookingsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, venueId) {
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return ref
      .watch(vendorBookingRepoProvider)
      .fetchVenueBookings(venueId: venueId, date: dateStr);
});
