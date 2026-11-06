import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/auth_repository.dart';
import 'login_state.dart';

class LoginViewModel extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(LoginError('Por favor ingresa tu correo y contraseña.'));
      return;
    }

    emit(LoginLoading());
    try {
      final user = await _authRepository.login(email.trim(), password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register(String fullName, String email, String password) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      emit(LoginError('Completa todos los campos para registrarte.'));
      return;
    }

    emit(LoginLoading());
    try {
      final user = await _authRepository.register(
        fullName.trim(),
        email.trim(),
        password,
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}