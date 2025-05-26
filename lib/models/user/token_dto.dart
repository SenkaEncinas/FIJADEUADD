class TokenDto {
  final String token;

  TokenDto({required this.token});

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(token: json['token']);
  }
}
