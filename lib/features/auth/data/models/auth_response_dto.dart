import '../../domain/user.dart';

class AuthResponseDto {
  final int id;
  final String email;
  final String role;
  final String status;
  final String accessToken;

  const AuthResponseDto({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.accessToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    return AuthResponseDto(
      id: (userJson['id'] as num?)?.toInt() ?? 0,
      email: userJson['email'] as String? ?? '',
      role: userJson['role'] as String? ?? 'GALLERY_ADMINISTRATOR',
      status: userJson['status'] as String? ?? 'ACTIVE',
      accessToken: json['accessToken'] as String? ?? '',
    );
  }

  User toDomain() => User(
        id: id,
        email: email,
        role: role,
        status: status,
      );
}