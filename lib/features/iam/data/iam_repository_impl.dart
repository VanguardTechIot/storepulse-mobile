import '../domain/email.dart';
import '../domain/iam_error.dart';
import '../domain/iam_repository.dart';
import '../domain/password_recovery.dart';
import '../domain/password_reset_code.dart';
import '../domain/request_password_reset_command.dart';
import '../domain/reset_password_command.dart';
import '../domain/role.dart';
import '../domain/sign_in_command.dart';
import '../domain/sign_up_command.dart';
import '../domain/user_account.dart';
import '../domain/user_session.dart';
import '../domain/user_status.dart';
import 'iam_service.dart';
import 'models/request_password_reset_dto.dart';
import 'models/reset_password_request_dto.dart';
import 'models/sign_in_request_dto.dart';
import 'models/sign_up_request_dto.dart';
import 'token_manager.dart';

class IamRepositoryImpl implements IamRepository {
  static const Set<IamErrorCode> _revokedSessionCodes = {
    IamErrorCode.unauthorized,
    IamErrorCode.userNotFound,
    IamErrorCode.accountInactive,
  };

  final IamService _iamService;
  final TokenManager _tokenManager;

  IamRepositoryImpl(this._iamService, this._tokenManager);

  @override
  Future<UserAccount> signIn(SignInCommand command) async {
    final response = await _iamService.signIn(
      SignInRequestDto(
        email: Email.normalize(command.email),
        password: command.password,
      ),
    );
    return _start(response.toDomain());
  }

  @override
  Future<UserAccount> signUp(SignUpCommand command) async {
    final response = await _iamService.signUp(
      SignUpRequestDto(
        fullName: command.fullName.trim(),
        email: Email.normalize(command.email),
        password: command.password,
        role: Role.galleryAdministrator.value,
      ),
    );
    return _start(response.toDomain());
  }

  @override
  Future<void> signOut() async {
    final token = await _tokenManager.getToken();
    await _tokenManager.clearAll();
    if (token == null || token.isEmpty) return;
    try {
      await _iamService.signOut(token);
    } on IamError {
      return;
    }
  }

  @override
  Future<PasswordRecovery> requestPasswordReset(
    RequestPasswordResetCommand command,
  ) async {
    final email = Email.normalize(command.email);
    final response = await _iamService.requestPasswordReset(
      RequestPasswordResetDto(email: email),
    );
    return PasswordRecovery(email: email, expiresAt: response.expiresAt);
  }

  @override
  Future<void> resetPassword(ResetPasswordCommand command) async {
    if (!PasswordResetCode.isValid(command.code)) {
      throw const IamError(IamErrorCode.invalidResetCode);
    }
    await _iamService.resetPassword(
      ResetPasswordRequestDto(
        email: Email.normalize(command.email),
        code: PasswordResetCode(command.code).value,
        newPassword: command.newPassword,
      ),
    );
  }

  @override
  Future<UserAccount?> restoreSession() async {
    final token = await _tokenManager.getToken();
    if (token == null || token.isEmpty) return null;
    try {
      final user = (await _iamService.fetchAuthenticatedUser(token)).toDomain();
      if (!user.isActive) {
        await _tokenManager.clearAll();
        return null;
      }
      await _saveAccount(user);
      return user;
    } on IamError catch (error) {
      if (_revokedSessionCodes.contains(error.code)) {
        await _tokenManager.clearAll();
        return null;
      }
      return currentUser();
    }
  }

  @override
  Future<UserAccount?> currentUser() async {
    final token = await _tokenManager.getToken();
    final userId = await _tokenManager.getUserId();
    final email = await _tokenManager.getEmail();
    if (token == null || token.isEmpty || userId == null || email == null) {
      return null;
    }
    return UserAccount(
      id: userId,
      email: email,
      role: Role.fromValue(await _tokenManager.getRole()),
      status: UserStatus.fromValue(await _tokenManager.getStatus()),
    );
  }

  @override
  Future<void> syncAccountEmail(String email) =>
      _tokenManager.setEmail(Email.normalize(email));

  Future<UserAccount> _start(UserSession session) async {
    if (!session.user.isActive) {
      throw const IamError(IamErrorCode.accountInactive);
    }
    await _tokenManager.saveSession(
      token: session.accessToken,
      userId: session.user.id,
      email: session.user.email,
      role: session.user.role.value,
      status: session.user.status.value,
    );
    return session.user;
  }

  Future<void> _saveAccount(UserAccount user) => _tokenManager.saveAccount(
    userId: user.id,
    email: user.email,
    role: user.role.value,
    status: user.status.value,
  );
}
