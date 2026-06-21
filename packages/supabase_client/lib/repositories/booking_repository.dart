import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fieldup_core/fieldup_core.dart';

class BookingRepository {
  BookingRepository(this._db);
  final SupabaseClient _db;

  Future<List<Booking>> fetchMyBookings(String userId) async {
    final data = await _db
        .from('bookings')
        .select('''
          *,
          slots (
            date, start_time, end_time,
            courts ( name, sport, venues ( name ) )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((j) => Booking.fromJson(j)).toList();
  }

  Future<Booking> createBooking({
    required String userId,
    required String slotId,
    required int originalAmountPaise,
    int discountPaise = 0,
    String? notes,
  }) async {
    final finalAmount = originalAmountPaise - discountPaise;
    final data = await _db.from('bookings').insert({
      'user_id': userId,
      'slot_id': slotId,
      'status': 'pending',
      'original_amount': originalAmountPaise,
      'discount_amount': discountPaise,
      'final_amount': finalAmount,
      if (notes != null) 'notes': notes,
    }).select('''
      *,
      slots ( date, start_time, end_time,
        courts ( name, sport, venues ( name ) ) )
    ''').single();
    return Booking.fromJson(data);
  }

  Future<void> confirmBooking({
    required String bookingId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
  }) async {
    await _db.from('bookings').update({
      'status': 'confirmed',
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
    }).eq('id', bookingId);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.from('bookings').update({
      'status': 'cancelled',
    }).eq('id', bookingId);
  }

  // Vendor: fetch all bookings for courts in a venue
  Future<List<Map<String, dynamic>>> fetchVenueBookings({
    required String venueId,
    String? date,
  }) async {
    var query = _db.from('bookings').select('''
      *,
      slots!inner (
        date, start_time, end_time,
        courts!inner ( name, sport, venue_id )
      ),
      users ( name, phone )
    ''').eq('slots.courts.venue_id', venueId);

    if (date != null) query = query.eq('slots.date', date);

    final data = await query.order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  // Vendor: revenue stats
  Future<Map<String, dynamic>> fetchRevenueStats(String venueId) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final weekAgo = today.subtract(const Duration(days: 7));
    final weekAgoStr =
        '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';

    // Today's bookings
    final todayData = await _db.from('bookings').select('''
      final_amount,
      slots!inner ( date, courts!inner ( venue_id ) )
    ''')
        .eq('slots.courts.venue_id', venueId)
        .eq('slots.date', todayStr)
        .inFilter('status', ['confirmed']);

    final weekData = await _db.from('bookings').select('''
      final_amount,
      slots!inner ( date, courts!inner ( venue_id ) )
    ''')
        .eq('slots.courts.venue_id', venueId)
        .gte('slots.date', weekAgoStr)
        .inFilter('status', ['confirmed']);

    final todayRevenue = (todayData as List)
        .fold<int>(0, (sum, b) => sum + (b['final_amount'] as int? ?? 0));
    final weekRevenue = (weekData as List)
        .fold<int>(0, (sum, b) => sum + (b['final_amount'] as int? ?? 0));

    return {
      'today_paise': todayRevenue,
      'week_paise': weekRevenue,
      'today_bookings': todayData.length,
    };
  }
}
