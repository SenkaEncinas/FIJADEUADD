class EventDetailDto {
  int id;
  String title;
  String description;
  DateTime date;
  String location;
  String imageUrl;
  int createdByUserId;

  EventDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.createdByUserId,
  });
  

  factory EventDetailDto.fromJson(Map<String, dynamic> json) {
    return EventDetailDto(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageUrl: json['imageUrl'],
      createdByUserId: json['createdByUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'createdByUserId': createdByUserId,
    };
  }
}