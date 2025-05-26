class UserInfoDto {
  final int id;
  final String username;
  final String email;
  final String role;

  UserInfoDto({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}
