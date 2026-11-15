import '../../domain/user_session.dart';
import 'user_account_dto.dart';

class AuthenticatedUserDto {
  final UserAccountDto user;
  final String accessToken;

  const AuthenticatedUserDto({required this.user, required this.accessToken});

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) =>
      AuthenticatedUserDto(
        user: UserAccountDto.fromJson(
          json['user'] as Map<String, dynamic>? ?? const {},
        ),
        accessToken: json['accessToken'] as String? ?? '',
      );

  UserSession toDomain() =>
      UserSession(user: user.toDomain(), accessToken: accessToken);
}
