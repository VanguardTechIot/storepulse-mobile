import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/iam_error.dart';
import '../domain/iam_repository.dart';
import '../domain/request_password_reset_command.dart';
import '../domain/reset_password_command.dart';
import 'password_recovery_state.dart';

class PasswordRecoveryViewModel extends Cubit<PasswordRecoveryState> {
  final IamRepository _iamRepository;

  PasswordRecoveryViewModel(this._iamRepository)
    : super(PasswordRecoveryIdle());

  Future<void> requestPasswordReset(RequestPasswordResetCommand command) =>
      _execute(() async {
        final recovery = await _iamRepository.requestPasswordReset(command);
        return PasswordResetCodeSent(recovery);
      });

  Future<void> resetPassword(ResetPasswordCommand command) =>
      _execute(() async {
        await _iamRepository.resetPassword(command);
        return PasswordResetCompleted();
      });

  Future<void> _execute(
    Future<PasswordRecoveryState> Function() operation,
  ) async {
    if (state is PasswordRecoverySubmitting) return;
    emit(PasswordRecoverySubmitting());
    try {
      emit(await operation());
    } on IamError catch (error) {
      emit(PasswordRecoveryFailed(error.code));
    } catch (_) {
      emit(PasswordRecoveryFailed(IamErrorCode.unexpected));
    }
  }
}
