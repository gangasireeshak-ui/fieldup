class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.status,
    required this.originalAmount,
    required this.finalAmount,
    this.discountAmount = 0,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.notes,
    required this.createdAt,
    // joined fields
    this.venueName,
    this.courtName,
    this.sport,
    this.slotDate,
    this.slotStart,
    this.slotEnd,
  });

  final String id;
  final String userId;
  final String slotId;
  final BookingStatus status;
  final int originalAmount; // paise
  final int finalAmount;    // paise
  final int discountAmount; // paise
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? notes;
  final DateTime createdAt;

  // Denormalised display fields (from join)
  final String? venueName;
  final String? courtName;
  final String? sport;
  final String? slotDate;
  final String? slotStart;
  final String? slotEnd;

  factory Booking.fromJson(Map<String, dynamic> j) {
    final slot = j['slots'] as Map<String, dynamic>?;
    final court = slot?['courts'] as Map<String, dynamic>?;
    final venue = court?['venues'] as Map<String, dynamic>?;

    return Booking(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      slotId: j['slot_id'] as String,
      status: BookingStatus.fromString(j['status'] as String? ?? 'pending'),
      originalAmount: j['original_amount'] as int? ?? 0,
      finalAmount: j['final_amount'] as int? ?? 0,
      discountAmount: j['discount_amount'] as int? ?? 0,
      razorpayOrderId: j['razorpay_order_id'] as String?,
      razorpayPaymentId: j['razorpay_payment_id'] as String?,
      notes: j['notes'] as String?,
      createdAt: DateTime.parse(j['created_at'] as String),
      venueName: venue?['name'] as String?,
      courtName: court?['name'] as String?,
      sport: court?['sport'] as String?,
      slotDate: slot?['date'] as String?,
      slotStart: slot?['start_time'] as String?,
      slotEnd: slot?['end_time'] as String?,
    );
  }
}

enum BookingStatus {
  pending, confirmed, cancelled, completed, refunded;

  static BookingStatus fromString(String s) =>
      BookingStatus.values.firstWhere((e) => e.name == s, orElse: () => BookingStatus.pending);

  String get label => switch (this) {
    BookingStatus.pending   => 'Pending',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.completed => 'Completed',
    BookingStatus.refunded  => 'Refunded',
  };
}
