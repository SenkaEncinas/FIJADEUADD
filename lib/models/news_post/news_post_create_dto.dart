class NewsPostCreateDto {
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
  final String category;

  NewsPostCreateDto({
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
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'location': location,
      'condition': condition,
      'paymentMethod': paymentMethod,
      'description': description,
      'phoneNumber': phoneNumber,
      'email': email,
      'whatsAppLink': whatsAppLink,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
