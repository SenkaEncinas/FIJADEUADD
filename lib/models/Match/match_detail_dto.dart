class MatchDetailDto {
  final int id;
  final String title;
  final String teamA;
  final String descriptionA;
  final String teamB;
  final String descriptionB;
  final DateTime matchDate;
  final String location;
  final String sportType;
  final String imageUrl;
  final int createdByUserId;

  MatchDetailDto({
    required this.id,
    required this.title,
    required this.teamA,
    required this.descriptionA,
    required this.teamB,
    required this.descriptionB,
    required this.matchDate,
    required this.location,
    required this.sportType,
    required this.imageUrl,
    required this.createdByUserId,
  });
  factory MatchDetailDto.fromJson(Map<String, dynamic> json) {
    return MatchDetailDto(
      id: json['id'],
      title: json['title'],
      teamA: json['teamA'],
      descriptionA: json['descriptionA'],
      teamB: json['teamB'],
      descriptionB: json['descriptionB'],
      matchDate: DateTime.parse(json['matchDate']),
      location: json['location'],
      sportType: json['sportType'],
      imageUrl: json['imageUrl'],
      createdByUserId: json['createdByUserId'],
    );
  }
}