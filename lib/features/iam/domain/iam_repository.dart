import 'password_recovery.dart';
import 'request_password_reset_command.dart';
import 'reset_password_command.dart';
import 'sign_in_command.dart';
import 'sign_up_command.dart';
import 'user_account.dart';

abstract class IamRepository {
  Future<UserAccount> signIn(SignInCommand command);

  Future<UserAccount> signUp(SignUpCommand command);

  Future<void> signOut();

  Future<PasswordRecovery> requestPasswordReset(
    RequestPasswordResetCommand command,
  );

  Future<void> resetPassword(ResetPasswordCommand command);

  Future<UserAccount?> restoreSession();

  Future<UserAccount?> currentUser();

  Future<void> syncAccountEmail(String email);
}
