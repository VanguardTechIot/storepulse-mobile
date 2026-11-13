import 'role.dart';
import 'user_status.dart';

class UserAccount {
  final int id;
  final String email;
  final Role role;
  final UserStatus status;

  const UserAccount({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
  });

  bool get isGalleryAdministrator => role == Role.galleryAdministrator;

  bool get isTenant => role == Role.tenant;

  bool get isActive => status == UserStatus.active;

  UserAccount withEmail(String email) =>
      UserAccount(id: id, email: email, role: role, status: status);
}
