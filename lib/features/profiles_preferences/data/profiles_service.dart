import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/network/api_error_code.dart';
import '../../iam/data/token_manager.dart';
import '../domain/profiles_error.dart';
import 'models/profile_dto.dart';
import 'models/update_profile_request_dto.dart';

class ProfilesService {
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;
  final TokenManager _tokenManager;

  ProfilesService(this._tokenManager, {http.Client? client})
    : _client = client ?? http.Client();

  Future<ProfileDto> fetchProfile(int userId) async {
    final headers = await _headers();
    final response = await _send(
      () => _client.get(_profileUri(userId), headers: headers),
    );
    return ProfileDto.fromJson(_decode(response));
  }

  Future<ProfileDto> updateProfile(
    int userId,
    UpdateProfileRequestDto request,
  ) async {
    final headers = await _headers();
    final response = await _send(
      () => _client.put(
        _profileUri(userId),
        headers: headers,
        body: jsonEncode(request.toJson()),
      ),
    );
    return ProfileDto.fromJson(_decode(response));
  }

  Uri _profileUri(int userId) =>
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/profile');

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on http.ClientException {
      throw const ProfilesError(ProfilesErrorCode.unreachable);
    } on TimeoutException {
      throw const ProfilesError(ProfilesErrorCode.unreachable);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final code = ProfilesErrorCode.fromValue(apiErrorCodeOf(response));
    if (code != ProfilesErrorCode.unexpected) throw ProfilesError(code);
    throw ProfilesError(switch (response.statusCode) {
      404 => ProfilesErrorCode.profileNotFound,
      401 || 403 => ProfilesErrorCode.accessDenied,
      _ => ProfilesErrorCode.unexpected,
    });
  }
}
