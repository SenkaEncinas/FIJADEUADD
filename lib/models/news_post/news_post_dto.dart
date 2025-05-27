class NewsPostDto {
  final int id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final DateTime publishDate;
  final String category;

  NewsPostDto({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.publishDate,
    required this.category,
  });

  factory NewsPostDto.fromJson(Map<String, dynamic> json) {
    return NewsPostDto(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      imageUrl: json['imageUrl'],
      publishDate: DateTime.parse(json['publishDate']),
      category: json['category'] ?? '', // Optional field
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'location': location,
      'imageUrl': imageUrl,
      'publishDate': publishDate.toIso8601String(),
      'category': category,
    };
  }
}