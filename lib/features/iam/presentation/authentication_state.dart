import '../domain/iam_error.dart';
import '../domain/user_account.dart';

sealed class AuthenticationState {}

class AuthenticationIdle extends AuthenticationState {}

class AuthenticationSubmitting extends AuthenticationState {}

class AuthenticationSucceeded extends AuthenticationState {
  final UserAccount user;
  AuthenticationSucceeded(this.user);
}

class AuthenticationFailed extends AuthenticationState {
  final IamErrorCode error;
  AuthenticationFailed(this.error);
}
