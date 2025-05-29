class MatchDto {
  final int id;
  final String title;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final String location;
  final String sportType;
  final String imageUrl;

  MatchDto({
    required this.id,
    required this.title,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
    required this.location,
    required this.sportType,
    required this.imageUrl,
  });

  factory MatchDto.fromJson(Map<String, dynamic> json) {
    return MatchDto(
      id: json['id'],
      title: json['title'],
      teamA: json['teamA'],
      teamB: json['teamB'],
      matchDate: DateTime.parse(json['matchDate']),
      location: json['location'],
      sportType: json['sportType'],
      imageUrl: json['imageUrl'],
    );
  }

  get createdByUserId => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'teamA': teamA,
      'teamB': teamB,
      'matchDate': matchDate.toIso8601String(),
      'location': location,
      'sportType': sportType,
      'imageUrl': imageUrl,
    };
  }
}

