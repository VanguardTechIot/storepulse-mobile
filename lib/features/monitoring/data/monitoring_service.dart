import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../iam/data/token_manager.dart';
import 'models/consumption_dto.dart';
import 'models/monitored_resource_dto.dart';
import 'models/resource_dto.dart';
import 'models/sensor_status_dto.dart';

class MonitoringService {
  final http.Client _client;
  final TokenManager _tokenManager;

  MonitoringService(this._tokenManager, {http.Client? client})
    : _client = client ?? http.Client();

  Future<List<ResourceDto>> fetchResources() async {
    final items = await _getList('/resources');
    return items.map(ResourceDto.fromJson).toList();
  }

  Future<List<MonitoredResourceDto>> fetchMonitoredResources() async {
    final items = await _getList('/monitored-resources');
    return items.map(MonitoredResourceDto.fromJson).toList();
  }

  Future<List<ConsumptionDto>> fetchConsumption(int resourceId) async {
    final items = await _getList('/consumption?resourceId=$resourceId');
    return items.map(ConsumptionDto.fromJson).toList();
  }

  Future<List<SensorStatusDto>> fetchSensorStatus(int resourceId) async {
    final items = await _getList('/sensors/status?resourceId=$resourceId');
    return items.map(SensorStatusDto.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final token = await _tokenManager.getToken();
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al consultar el monitoreo (${response.statusCode})',
      );
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
