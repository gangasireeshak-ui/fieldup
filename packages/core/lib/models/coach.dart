class Coach {
  const Coach({
    required this.id,
    required this.userId,
    this.name,
    this.avatarUrl,
    this.sports = const [],
    this.bio,
    this.experienceYears = 0,
    this.certifications = const [],
    this.hourlyRatePaise = 0,
    this.sessionFormats = const [],
    this.isVerified = false,
    this.rating,
    this.sessionCount = 0,
    this.city,
  });

  final String id;
  final String userId;
  final String? name;
  final String? avatarUrl;
  final List<String> sports;
  final String? bio;
  final int experienceYears;
  final List<String> certifications;
  final int hourlyRatePaise;
  final List<String> sessionFormats;
  final bool isVerified;
  final double? rating;
  final int sessionCount;
  final String? city;

  factory Coach.fromJson(Map<String, dynamic> j) {
    final user = j['users'] as Map<String, dynamic>?;
    return Coach(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      name: user?['name'] as String? ?? j['name'] as String?,
      avatarUrl: user?['avatar_url'] as String?,
      sports: (j['sports'] as List?)?.cast<String>() ?? [],
      bio: j['bio'] as String?,
      experienceYears: j['experience_years'] as int? ?? 0,
      certifications: (j['certifications'] as List?)?.cast<String>() ?? [],
      hourlyRatePaise: j['hourly_rate_paise'] as int? ?? 0,
      sessionFormats: (j['session_formats'] as List?)?.cast<String>() ?? [],
      isVerified: j['is_verified'] as bool? ?? false,
      rating: (j['rating'] as num?)?.toDouble(),
      sessionCount: j['session_count'] as int? ?? 0,
      city: j['city'] as String?,
    );
  }
}
