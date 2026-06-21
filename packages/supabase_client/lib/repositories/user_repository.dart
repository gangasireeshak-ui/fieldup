import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fieldup_core/fieldup_core.dart';

class UserRepository {
  UserRepository(this._db);
  final SupabaseClient _db;

  Future<FieldUpUser?> fetchCurrentUser() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await _db.from('users').select().eq('id', uid).maybeSingle();
    if (data == null) return null;
    return FieldUpUser.fromJson(data);
  }

  Future<FieldUpUser> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? city,
    List<String>? sportPreferences,
  }) async {
    final updates = <String, dynamic>{
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (city != null) 'city': city,
      if (sportPreferences != null) 'sport_preferences': sportPreferences,
    };
    final data = await _db
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return FieldUpUser.fromJson(data);
  }

  Future<int> fetchKarmaPoints(String userId) async {
    final data = await _db
        .from('users')
        .select('karma_points')
        .eq('id', userId)
        .single();
    return data['karma_points'] as int? ?? 0;
  }
}
