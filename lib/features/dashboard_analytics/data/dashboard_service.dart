import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../auth/data/token_manager.dart';
import 'models/dashboard_summary_dto.dart';

class DashboardService {
  final http.Client _client;
  final TokenManager _tokenManager;

  DashboardService(this._tokenManager, {http.Client? client})
      : _client = client ?? http.Client();

  Future<DashboardSummaryDto> fetchDashboardSummary() async {
    final token = await _tokenManager.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/summary');

    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardSummaryDto.fromJson(data);
    } else {
      throw Exception(
        'Error al obtener resumen del dashboard (${response.statusCode})',
      );
    }
  }
}