import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fieldup_core/fieldup_core.dart';

class MatchRepository {
  MatchRepository(this._db);
  final SupabaseClient _db;

  Future<MatchRecord> saveMatch({
    required String sport,
    required String team1,
    required String team2,
    required String status,
    required String recordedBy,
    String? venueId,
    String? umpire1,
    String? umpire2,
    Map<String, dynamic>? sportData,
  }) async {
    final data = await _db.from('matches').insert({
      'sport': sport,
      'team1': team1,
      'team2': team2,
      'status': status,
      'recorded_by': recordedBy,
      if (venueId != null) 'venue_id': venueId,
      if (umpire1 != null) 'umpire1': umpire1,
      if (umpire2 != null) 'umpire2': umpire2,
      if (sportData != null) 'sport_data': sportData,
    }).select().single();
    return MatchRecord.fromJson(data);
  }

  Future<void> updateMatchStatus({
    required String matchId,
    required String status,
    Map<String, dynamic>? sportData,
  }) async {
    await _db.from('matches').update({
      'status': status,
      if (sportData != null) 'sport_data': sportData,
    }).eq('id', matchId);
  }

  Future<List<MatchRecord>> fetchMyMatches(String userId) async {
    final data = await _db
        .from('matches')
        .select('*, venues(name)')
        .eq('recorded_by', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((j) => MatchRecord.fromJson(j)).toList();
  }

  Future<List<MatchRecord>> fetchLiveMatches() async {
    final data = await _db
        .from('matches')
        .select('*, venues(name)')
        .eq('status', 'live')
        .order('created_at', ascending: false)
        .limit(20);
    return (data as List).map((j) => MatchRecord.fromJson(j)).toList();
  }
}
