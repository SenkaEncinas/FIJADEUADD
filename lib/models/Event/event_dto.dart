class EventDto {
  final int id;
  final String title;
  final DateTime date;
  final String location;
  final String imageUrl;

  EventDto({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
