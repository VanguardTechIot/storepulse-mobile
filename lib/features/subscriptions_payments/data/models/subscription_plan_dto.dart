import '../../domain/subscription_plan.dart';

class SubscriptionPlanDto {
  final int id;
  final String code;
  final int? monitoredUnitLimit;
  final double monthlyPrice;
  final double annualPrice;
  final String currency;
  final List<String> features;
  final bool published;

  const SubscriptionPlanDto({
    required this.id,
    required this.code,
    required this.monitoredUnitLimit,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.currency,
    required this.features,
    required this.published,
  });

  factory SubscriptionPlanDto.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List<dynamic>? ?? [];
    return SubscriptionPlanDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code'] as String? ?? 'BASIC',
      monitoredUnitLimit: (json['monitoredUnitLimit'] as num?)?.toInt(),
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0.0,
      annualPrice: (json['annualPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PEN',
      features: rawFeatures.map((e) => e.toString()).toList(),
      published: json['published'] as bool? ?? true,
    );
  }

  SubscriptionPlan toDomain() => SubscriptionPlan(
        id: id,
        code: code,
        monitoredUnitLimit: monitoredUnitLimit,
        monthlyPrice: monthlyPrice,
        annualPrice: annualPrice,
        currency: currency,
        features: features,
        published: published,
      );
}