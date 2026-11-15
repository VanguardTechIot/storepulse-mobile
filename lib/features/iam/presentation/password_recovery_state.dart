import '../domain/iam_error.dart';
import '../domain/password_recovery.dart';

sealed class PasswordRecoveryState {}

class PasswordRecoveryIdle extends PasswordRecoveryState {}

class PasswordRecoverySubmitting extends PasswordRecoveryState {}

class PasswordResetCodeSent extends PasswordRecoveryState {
  final PasswordRecovery recovery;
  PasswordResetCodeSent(this.recovery);
}

class PasswordResetCompleted extends PasswordRecoveryState {}

class PasswordRecoveryFailed extends PasswordRecoveryState {
  final IamErrorCode error;
  PasswordRecoveryFailed(this.error);
}
