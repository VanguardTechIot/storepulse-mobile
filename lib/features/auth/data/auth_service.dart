import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import 'models/auth_response_dto.dart';
import 'models/sign_in_request_dto.dart';
import 'models/sign_up_request_dto.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponseDto> signIn(SignInRequestDto request) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/authentication/sign-in');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthResponseDto.fromJson(data);
    } else {
      throw Exception('Credenciales inválidas (${response.statusCode})');
    }
  }

  Future<AuthResponseDto> signUp(SignUpRequestDto request) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/authentication/sign-up');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthResponseDto.fromJson(data);
    } else {
      throw Exception('Error al registrar cuenta (${response.statusCode})');
    }
  }
}