import '../../domain/dashboard_summary.dart';

class DashboardSummaryDto {
  final int open;
  final int active;
  final int acknowledged;
  final int resolved;
  final Map<String, int> openBySensorType;
  final double electricityKwh;
  final double waterCubicMeters;

  const DashboardSummaryDto({
    required this.open,
    required this.active,
    required this.acknowledged,
    required this.resolved,
    required this.openBySensorType,
    required this.electricityKwh,
    required this.waterCubicMeters,
  });

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    final alertsJson = json['alerts'] as Map<String, dynamic>? ?? {};
    final consumptionJson = json['consumption'] as Map<String, dynamic>? ?? {};
    final rawSensorMap =
        alertsJson['openBySensorType'] as Map<String, dynamic>? ?? {};

    final mappedSensorTypes = <String, int>{};
    rawSensorMap.forEach((key, value) {
      mappedSensorTypes[key] = (value as num?)?.toInt() ?? 0;
    });

    return DashboardSummaryDto(
      open: (alertsJson['open'] as num?)?.toInt() ?? 0,
      active: (alertsJson['active'] as num?)?.toInt() ?? 0,
      acknowledged: (alertsJson['acknowledged'] as num?)?.toInt() ?? 0,
      resolved: (alertsJson['resolved'] as num?)?.toInt() ?? 0,
      openBySensorType: mappedSensorTypes,
      electricityKwh:
          (consumptionJson['electricityKwh'] as num?)?.toDouble() ?? 0.0,
      waterCubicMeters:
          (consumptionJson['waterCubicMeters'] as num?)?.toDouble() ?? 0.0,
    );
  }

  DashboardSummary toDomain() => DashboardSummary(
        alerts: AlertSummary(
          open: open,
          active: active,
          acknowledged: acknowledged,
          resolved: resolved,
          openBySensorType: openBySensorType,
        ),
        consumption: ConsumptionSummary(
          electricityKwh: electricityKwh,
          waterCubicMeters: waterCubicMeters,
        ),
      );
}