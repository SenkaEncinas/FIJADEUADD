class MatchCreateDto {
  final String title;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final String location;
  final String sportType;
  final String imageUrl;
  final int createdByUserId;

  MatchCreateDto({
    required this.title,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
    required this.location,
    required this.sportType,
    required this.imageUrl,
    required this.createdByUserId,
  });
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'teamA': teamA,
      'teamB': teamB,
      'matchDate': matchDate.toIso8601String(),
      'location': location,
      'sportType': sportType,
      'imageUrl': imageUrl,
      'createdByUserId': createdByUserId,
    };
  }
}