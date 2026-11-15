import 'user_account.dart';

class UserSession {
  final UserAccount user;
  final String accessToken;

  const UserSession({required this.user, required this.accessToken});
}
