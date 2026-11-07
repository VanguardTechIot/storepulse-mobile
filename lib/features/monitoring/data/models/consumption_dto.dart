import '../../domain/consumption.dart';

class ConsumptionDto {
  final int resourceId;
  final String measurementType;
  final double totalValue;
  final String unit;
  final String periodStart;
  final String periodEnd;

  const ConsumptionDto({
    required this.resourceId,
    required this.measurementType,
    required this.totalValue,
    required this.unit,
    required this.periodStart,
    required this.periodEnd,
  });

  factory ConsumptionDto.fromJson(Map<String, dynamic> json) {
    return ConsumptionDto(
      resourceId: (json['resourceId'] as num).toInt(),
      measurementType: json['measurementType'] as String,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      periodStart: json['periodStart'] as String,
      periodEnd: json['periodEnd'] as String,
    );
  }

  Consumption toDomain() => Consumption(
    resourceId: resourceId,
    measurementType: measurementType,
    totalValue: totalValue,
    unit: unit,
    periodStart: DateTime.parse(periodStart).toUtc(),
    periodEnd: DateTime.parse(periodEnd).toUtc(),
  );
}
