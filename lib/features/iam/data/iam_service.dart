import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/network/api_error_code.dart';
import '../domain/iam_error.dart';
import 'models/authenticated_user_dto.dart';
import 'models/password_reset_requested_dto.dart';
import 'models/request_password_reset_dto.dart';
import 'models/reset_password_request_dto.dart';
import 'models/sign_in_request_dto.dart';
import 'models/sign_up_request_dto.dart';
import 'models/user_account_dto.dart';

class IamService {
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  IamService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthenticatedUserDto> signIn(SignInRequestDto request) async {
    final response = await _post('/authentication/sign-in', request.toJson());
    return AuthenticatedUserDto.fromJson(_decode(response, const {200}));
  }

  Future<AuthenticatedUserDto> signUp(SignUpRequestDto request) async {
    final response = await _post('/authentication/sign-up', request.toJson());
    return AuthenticatedUserDto.fromJson(_decode(response, const {200, 201}));
  }

  Future<void> signOut(String token) async {
    final response = await _post(
      '/authentication/sign-out',
      null,
      token: token,
    );
    _ensure(response, const {200, 204});
  }

  Future<PasswordResetRequestedDto> requestPasswordReset(
    RequestPasswordResetDto request,
  ) async {
    final response = await _post('/password-recoveries', request.toJson());
    return PasswordResetRequestedDto.fromJson(
      _decode(response, const {200, 202}),
    );
  }

  Future<void> resetPassword(ResetPasswordRequestDto request) async {
    final response = await _post(
      '/password-recoveries/reset',
      request.toJson(),
    );
    _ensure(response, const {200, 204});
  }

  Future<UserAccountDto> fetchAuthenticatedUser(String token) async {
    final response = await _send(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/users/me'),
        headers: _headers(token),
      ),
    );
    return UserAccountDto.fromJson(_decode(response, const {200}));
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic>? body, {
    String? token,
  }) => _send(
    () => _client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    ),
  );

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on http.ClientException {
      throw const IamError(IamErrorCode.unreachable);
    } on TimeoutException {
      throw const IamError(IamErrorCode.unreachable);
    }
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _decode(http.Response response, Set<int> expected) {
    _ensure(response, expected);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _ensure(http.Response response, Set<int> expected) {
    if (expected.contains(response.statusCode)) return;
    final code = IamErrorCode.fromValue(apiErrorCodeOf(response));
    if (code == IamErrorCode.unexpected &&
        (response.statusCode == 401 || response.statusCode == 403)) {
      throw const IamError(IamErrorCode.unauthorized);
    }
    throw IamError(code);
  }
}
