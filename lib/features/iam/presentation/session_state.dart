import '../domain/user_account.dart';

sealed class SessionState {}

class SessionChecking extends SessionState {}

class SessionAuthenticated extends SessionState {
  final UserAccount user;
  SessionAuthenticated(this.user);
}

class SessionUnauthenticated extends SessionState {}
