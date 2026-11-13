import '../../domain/role.dart';
import '../../domain/user_account.dart';
import '../../domain/user_status.dart';

class UserAccountDto {
  final int id;
  final String email;
  final String role;
  final String status;

  const UserAccountDto({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserAccountDto.fromJson(Map<String, dynamic> json) => UserAccountDto(
    id: (json['id'] as num?)?.toInt() ?? 0,
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    status: json['status'] as String? ?? '',
  );

  UserAccount toDomain() => UserAccount(
    id: id,
    email: email,
    role: Role.fromValue(role),
    status: UserStatus.fromValue(status),
  );
}
