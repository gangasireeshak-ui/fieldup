class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.sport,
    required this.team1,
    required this.team2,
    required this.status,
    required this.recordedBy,
    this.tournamentId,
    this.venueId,
    this.venueName,
    this.umpire1,
    this.umpire2,
    this.scheduledAt,
    this.sportData,
    required this.createdAt,
  });

  final String id;
  final String sport;
  final String team1;
  final String team2;
  final String status; // 'scheduled' | 'live' | 'completed'
  final String recordedBy; // user_id
  final String? tournamentId;
  final String? venueId;
  final String? venueName;
  final String? umpire1;
  final String? umpire2;
  final DateTime? scheduledAt;
  final Map<String, dynamic>? sportData; // ball-by-ball, sets, etc.
  final DateTime createdAt;

  factory MatchRecord.fromJson(Map<String, dynamic> j) => MatchRecord(
        id: j['id'] as String,
        sport: j['sport'] as String? ?? '',
        team1: j['team1'] as String? ?? '',
        team2: j['team2'] as String? ?? '',
        status: j['status'] as String? ?? 'completed',
        recordedBy: j['recorded_by'] as String? ?? '',
        tournamentId: j['tournament_id'] as String?,
        venueId: j['venue_id'] as String?,
        venueName: (j['venues'] as Map?)?['name'] as String?,
        umpire1: j['umpire1'] as String?,
        umpire2: j['umpire2'] as String?,
        scheduledAt: j['scheduled_at'] != null
            ? DateTime.parse(j['scheduled_at'] as String)
            : null,
        sportData: j['sport_data'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'sport': sport,
        'team1': team1,
        'team2': team2,
        'status': status,
        'recorded_by': recordedBy,
        if (tournamentId != null) 'tournament_id': tournamentId,
        if (venueId != null) 'venue_id': venueId,
        if (umpire1 != null) 'umpire1': umpire1,
        if (umpire2 != null) 'umpire2': umpire2,
        if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
        if (sportData != null) 'sport_data': sportData,
      };
}
