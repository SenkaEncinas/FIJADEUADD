class NewsPostDetailDto {
  final String title;
  final double price;
  final String location;
  final String condition;
  final String paymentMethod;
  final String description;
  final String phoneNumber;
  final String email;
  final String whatsAppLink;
  final String imageUrl;
  final DateTime publishDate;

  NewsPostDetailDto({
    required this.title,
    required this.price,
    required this.location,
    required this.condition,
    required this.paymentMethod,
    required this.description,
    required this.phoneNumber,
    required this.email,
    required this.whatsAppLink,
    required this.imageUrl,
    required this.publishDate,
  });

  factory NewsPostDetailDto.fromJson(Map<String, dynamic> json) {
    return NewsPostDetailDto(
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      condition: json['condition'],
      paymentMethod: json['paymentMethod'],
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      whatsAppLink: json['whatsAppLink'],
      imageUrl: json['imageUrl'],
      publishDate: DateTime.parse(json['publishDate']),
    );
  }
}
