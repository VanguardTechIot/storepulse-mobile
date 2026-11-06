import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_service.dart';
import 'models/sign_in_request_dto.dart';
import 'models/sign_up_request_dto.dart';
import 'token_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this._authService, this._tokenManager);

  @override
  Future<User> login(String email, String password) async {
    final response = await _authService.signIn(
      SignInRequestDto(email: email, password: password),
    );
    await _tokenManager.saveSession(
      token: response.accessToken,
      userId: response.id,
      email: response.email,
      role: response.role,
    );
    return response.toDomain();
  }

  @override
  Future<User> register(String fullName, String email, String password) async {
    final response = await _authService.signUp(
      SignUpRequestDto(fullName: fullName, email: email, password: password),
    );
    await _tokenManager.saveSession(
      token: response.accessToken,
      userId: response.id,
      email: response.email,
      role: response.role,
    );
    return response.toDomain();
  }

  @override
  Future<void> logout() async {
    await _tokenManager.clearAll();
  }
}