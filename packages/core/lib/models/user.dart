class FieldUpUser {
  const FieldUpUser({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.avatarUrl,
    this.karmaPoints = 0,
    this.referralCode,
    this.sportPreferences = const [],
    this.city,
    this.isVerified = false,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final int karmaPoints;
  final String? referralCode;
  final List<String> sportPreferences;
  final String? city;
  final bool isVerified;

  factory FieldUpUser.fromJson(Map<String, dynamic> j) => FieldUpUser(
        id: j['id'] as String,
        phone: j['phone'] as String? ?? '',
        name: j['name'] as String?,
        email: j['email'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        karmaPoints: j['karma_points'] as int? ?? 0,
        referralCode: j['referral_code'] as String?,
        sportPreferences: (j['sport_preferences'] as List?)?.cast<String>() ?? [],
        city: j['city'] as String?,
        isVerified: j['is_verified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'karma_points': karmaPoints,
        if (referralCode != null) 'referral_code': referralCode,
        'sport_preferences': sportPreferences,
        if (city != null) 'city': city,
        'is_verified': isVerified,
      };

  FieldUpUser copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? karmaPoints,
    List<String>? sportPreferences,
    String? city,
  }) =>
      FieldUpUser(
        id: id,
        phone: phone,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        karmaPoints: karmaPoints ?? this.karmaPoints,
        referralCode: referralCode,
        sportPreferences: sportPreferences ?? this.sportPreferences,
        city: city ?? this.city,
        isVerified: isVerified,
      );
}
