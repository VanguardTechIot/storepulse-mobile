import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/iam_error.dart';
import '../domain/iam_repository.dart';
import '../domain/sign_in_command.dart';
import '../domain/sign_up_command.dart';
import '../domain/user_account.dart';
import 'authentication_state.dart';

class AuthenticationViewModel extends Cubit<AuthenticationState> {
  final IamRepository _iamRepository;

  AuthenticationViewModel(this._iamRepository) : super(AuthenticationIdle());

  Future<void> signIn(SignInCommand command) =>
      _authenticate(() => _iamRepository.signIn(command));

  Future<void> signUp(SignUpCommand command) =>
      _authenticate(() => _iamRepository.signUp(command));

  Future<void> _authenticate(Future<UserAccount> Function() operation) async {
    if (state is AuthenticationSubmitting) return;
    emit(AuthenticationSubmitting());
    try {
      emit(AuthenticationSucceeded(await operation()));
    } on IamError catch (error) {
      emit(AuthenticationFailed(error.code));
    } catch (_) {
      emit(AuthenticationFailed(IamErrorCode.unexpected));
    }
  }
}
