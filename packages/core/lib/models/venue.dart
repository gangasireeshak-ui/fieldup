class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.ownerId,
    this.description,
    this.state,
    this.lat,
    this.lng,
    this.sports = const [],
    this.amenities = const [],
    this.photos = const [],
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String? ownerId;
  final String? description;
  final String? state;
  final double? lat;
  final double? lng;
  final List<String> sports;
  final List<String> amenities;
  final List<String> photos;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;

  factory Venue.fromJson(Map<String, dynamic> j) => Venue(
        id: j['id'] as String,
        name: j['name'] as String,
        address: j['address'] as String,
        city: j['city'] as String,
        ownerId: j['owner_id'] as String?,
        description: j['description'] as String?,
        state: j['state'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        sports: (j['sports'] as List?)?.cast<String>() ?? [],
        amenities: (j['amenities'] as List?)?.cast<String>() ?? [],
        photos: (j['photos'] as List?)?.cast<String>() ?? [],
        rating: (j['rating'] as num?)?.toDouble(),
        reviewCount: j['review_count'] as int? ?? 0,
        isVerified: j['is_verified'] as bool? ?? false,
        isActive: j['is_active'] as bool? ?? true,
      );
}

class Court {
  const Court({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    this.capacity,
    this.description,
    this.pricePerHour = 0,
    this.surface,
    this.hasLights = false,
    this.isActive = true,
  });

  final String id;
  final String venueId;
  final String name;
  final String sport;
  final int? capacity;
  final String? description;
  final int pricePerHour; // paise
  final String? surface;
  final bool hasLights;
  final bool isActive;

  factory Court.fromJson(Map<String, dynamic> j) => Court(
        id: j['id'] as String,
        venueId: j['venue_id'] as String,
        name: j['name'] as String,
        sport: j['sport'] as String,
        capacity: j['capacity'] as int?,
        description: j['description'] as String?,
        pricePerHour: j['price_per_hour'] as int? ?? 0,
        surface: j['surface'] as String?,
        hasLights: j['has_lights'] as bool? ?? false,
        isActive: j['is_active'] as bool? ?? true,
      );
}

class Slot {
  const Slot({
    required this.id,
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.pricePaise = 0,
    this.isBlocked = false,
    this.isBooked = false,
    this.blockedReason,
  });

  final String id;
  final String courtId;
  final DateTime date;
  final String startTime; // "09:00"
  final String endTime;   // "10:00"
  final int pricePaise;
  final bool isBlocked;
  final bool isBooked;
  final String? blockedReason;

  bool get isAvailable => !isBlocked && !isBooked;

  factory Slot.fromJson(Map<String, dynamic> j) => Slot(
        id: j['id'] as String,
        courtId: j['court_id'] as String,
        date: DateTime.parse(j['date'] as String),
        startTime: j['start_time'] as String,
        endTime: j['end_time'] as String,
        pricePaise: j['price_paise'] as int? ?? 0,
        isBlocked: j['is_blocked'] as bool? ?? false,
        isBooked: j['is_booked'] as bool? ?? false,
        blockedReason: j['blocked_reason'] as String?,
      );
}
