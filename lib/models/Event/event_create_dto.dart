  class EventCreateDto {
    final String title;
    final String description;
    final DateTime date;
    final String location;
    final String imageUrl;

  EventCreateDto({
      required this.title,
      required this.description,
      required this.date,
      required this.location,
      required this.imageUrl,
    });

    Map<String, dynamic> toJson() {
      return {
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'imageUrl': imageUrl,
      };
    }
  }
