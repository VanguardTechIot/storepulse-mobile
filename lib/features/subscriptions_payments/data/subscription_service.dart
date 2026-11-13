import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../iam/data/token_manager.dart';
import 'models/payment_dto.dart';
import 'models/request_subscription_dto.dart';
import 'models/subscription_dto.dart';
import 'models/subscription_plan_dto.dart';

class SubscriptionService {
  final http.Client _client;
  final TokenManager _tokenManager;

  SubscriptionService(this._tokenManager, {http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<SubscriptionPlanDto>> fetchPlans() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscription-plans');
    final response = await _client.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) =>
              SubscriptionPlanDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar planes (${response.statusCode})');
    }
  }

  Future<SubscriptionDto?> fetchSubscriptionByGallery(int galleryId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/subscriptions?galleryId=$galleryId',
    );
    final response = await _client.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SubscriptionDto.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Error al consultar suscripción de la galería (${response.statusCode})',
      );
    }
  }

  Future<SubscriptionDto> requestSubscription(
    RequestSubscriptionDto dto,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions');
    final response = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SubscriptionDto.fromJson(data);
    } else {
      throw Exception(
        'No se pudo procesar la suscripción (${response.statusCode})',
      );
    }
  }

  Future<SubscriptionDto> cancelAutoRenewal(int subscriptionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/subscriptions/$subscriptionId/cancel-renewal',
    );
    final response = await _client.post(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SubscriptionDto.fromJson(data);
    } else {
      throw Exception(
        'No se pudo cancelar la renovación automática (${response.statusCode})',
      );
    }
  }

  Future<SubscriptionDto> reactivateAutoRenewal(int subscriptionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/subscriptions/$subscriptionId/reactivate-renewal',
    );
    final response = await _client.post(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SubscriptionDto.fromJson(data);
    } else {
      throw Exception(
        'No se pudo reactivar la renovación automática (${response.statusCode})',
      );
    }
  }

  Future<List<PaymentDto>> fetchPayments(int subscriptionId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/subscriptions/$subscriptionId/payments',
    );
    final response = await _client.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => PaymentDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }
}