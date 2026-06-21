import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fieldup_supabase_client/fieldup_supabase_client.dart';
import 'package:fieldup_core/fieldup_core.dart';

part 'auth_provider.g.dart';

// ── Onboarding ────────────────────────────────────────────────────────────────
final onboardingDoneProvider = StateProvider<bool>((ref) => false);

// ── Supabase client ───────────────────────────────────────────────────────────
@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

// ── Repository providers ──────────────────────────────────────────────────────
@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));

@riverpod
UserRepository userRepository(Ref ref) =>
    UserRepository(ref.watch(supabaseClientProvider));

@riverpod
VenueRepository venueRepository(Ref ref) =>
    VenueRepository(ref.watch(supabaseClientProvider));

@riverpod
BookingRepository bookingRepository(Ref ref) =>
    BookingRepository(ref.watch(supabaseClientProvider));

@riverpod
CoachRepository coachRepository(Ref ref) =>
    CoachRepository(ref.watch(supabaseClientProvider));

@riverpod
MatchRepository matchRepository(Ref ref) =>
    MatchRepository(ref.watch(supabaseClientProvider));

// ── Auth state stream ─────────────────────────────────────────────────────────
@riverpod
Stream<AuthState> authStateStream(Ref ref) =>
    ref.watch(supabaseClientProvider).auth.onAuthStateChange;

// ── Is authenticated — driven by real session ─────────────────────────────────
@riverpod
bool isAuthenticated(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentSession != null;
}

// ── Current user profile ──────────────────────────────────────────────────────
@riverpod
Future<FieldUpUser?> currentUserProfile(Ref ref) {
  final repo = UserRepository(ref.watch(supabaseClientProvider));
  return repo.fetchCurrentUser();
}

// ── Coaches list ──────────────────────────────────────────────────────────────
@riverpod
Future<List<Coach>> coachesList(Ref ref, {String? sport, String? city}) =>
    ref.watch(coachRepositoryProvider).fetchCoaches(sport: sport, city: city);
