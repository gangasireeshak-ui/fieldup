import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fieldup_core/fieldup_core.dart';

class CoachRepository {
  CoachRepository(this._db);
  final SupabaseClient _db;

  Future<List<Coach>> fetchCoaches({
    String? sport,
    String? city,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _db
        .from('coaches')
        .select('*, users!inner(name, avatar_url, phone)')
        .eq('is_verified', true);

    if (sport != null && sport.isNotEmpty) {
      query = query.contains('sports', [sport]);
    }
    if (city != null && city.isNotEmpty) {
      query = query.ilike('city', '%$city%');
    }

    final data = await query
        .order('rating', ascending: false, nullsFirst: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((j) => Coach.fromJson(j)).toList();
  }

  Future<Coach?> fetchCoach(String coachId) async {
    final data = await _db
        .from('coaches')
        .select('*, users!inner(name, avatar_url, phone)')
        .eq('id', coachId)
        .maybeSingle();
    return data == null ? null : Coach.fromJson(data);
  }

  Future<void> expressInterest({
    required String coachId,
    required String playerId,
    required DateTime preferredDate,
    int durationMins = 60,
    String? notes,
  }) async {
    final coach = await fetchCoach(coachId);
    if (coach == null) throw Exception('Coach not found');

    await _db.from('coach_sessions').insert({
      'coach_id': coachId,
      'player_id': playerId,
      'date_time': preferredDate.toIso8601String(),
      'duration_mins': durationMins,
      'status': 'pending',
      'amount_paise': coach.hourlyRatePaise,
      if (notes != null) 'notes': notes,
    });
  }

  Future<List<Map<String, dynamic>>> fetchMySessions(String userId) async {
    final data = await _db
        .from('coach_sessions')
        .select('*, coaches!inner(*, users!inner(name, avatar_url))')
        .eq('player_id', userId)
        .order('date_time', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
