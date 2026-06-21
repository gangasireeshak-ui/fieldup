import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fieldup_core/fieldup_core.dart';

class VenueRepository {
  VenueRepository(this._db);
  final SupabaseClient _db;

  Future<List<Venue>> fetchVenues({
    String? city,
    String? sport,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _db
        .from('venues')
        .select()
        .eq('is_active', true);

    if (city != null && city.isNotEmpty) {
      query = query.ilike('city', '%$city%');
    }
    if (sport != null && sport.isNotEmpty) {
      query = query.contains('sports', [sport]);
    }

    final data = await query
        .order('rating', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((j) => Venue.fromJson(j)).toList();
  }

  Future<Venue?> fetchVenue(String venueId) async {
    final data = await _db
        .from('venues')
        .select()
        .eq('id', venueId)
        .maybeSingle();
    return data == null ? null : Venue.fromJson(data);
  }

  Future<List<Court>> fetchCourts(String venueId) async {
    final data = await _db
        .from('courts')
        .select()
        .eq('venue_id', venueId)
        .eq('is_active', true)
        .order('name');
    return (data as List).map((j) => Court.fromJson(j)).toList();
  }

  Future<List<Slot>> fetchAvailableSlots({
    required String courtId,
    required String date, // 'YYYY-MM-DD'
  }) async {
    // Fetch all slots for this court+date, then compute which are booked
    final slots = await _db
        .from('slots')
        .select()
        .eq('court_id', courtId)
        .eq('date', date)
        .eq('is_blocked', false)
        .order('start_time');

    // Check which slots have confirmed bookings
    final slotIds = (slots as List).map((s) => s['id'] as String).toList();
    if (slotIds.isEmpty) return [];

    final bookedSlots = await _db
        .from('bookings')
        .select('slot_id')
        .inFilter('slot_id', slotIds)
        .inFilter('status', ['confirmed', 'pending']);

    final bookedIds = (bookedSlots as List)
        .map((b) => b['slot_id'] as String)
        .toSet();

    return slots.map((j) {
      final m = Map<String, dynamic>.from(j as Map);
      m['is_booked'] = bookedIds.contains(m['id']);
      return Slot.fromJson(m);
    }).toList();
  }

  Future<String> createVenue({
    required String ownerId,
    required String name,
    required String address,
    required String city,
    String? description,
    List<String> sports = const [],
    List<String> amenities = const [],
  }) async {
    final data = await _db.from('venues').insert({
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'city': city,
      if (description != null) 'description': description,
      'sports': sports,
      'amenities': amenities,
      'is_active': false, // pending admin approval
    }).select('id').single();
    return data['id'] as String;
  }

  Future<void> createCourt({
    required String venueId,
    required String name,
    required String sport,
    int? capacity,
    int pricePerHour = 0,
    String? surface,
    bool hasLights = false,
  }) async {
    await _db.from('courts').insert({
      'venue_id': venueId,
      'name': name,
      'sport': sport,
      if (capacity != null) 'capacity': capacity,
      'price_per_hour': pricePerHour,
      if (surface != null) 'surface': surface,
      'has_lights': hasLights,
    });
  }

  // Vendor: fetch venues owned by this user
  Future<List<Venue>> fetchMyVenues(String ownerId) async {
    final data = await _db
        .from('venues')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return (data as List).map((j) => Venue.fromJson(j)).toList();
  }

  Future<void> toggleCourtActive(String courtId, {required bool active}) async {
    await _db.from('courts').update({'is_active': active}).eq('id', courtId);
  }
}
