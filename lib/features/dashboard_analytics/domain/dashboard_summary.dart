class AlertSummary {
  final int open;
  final int active;
  final int acknowledged;
  final int resolved;
  final Map<String, int> openBySensorType;

  const AlertSummary({
    required this.open,
    required this.active,
    required this.acknowledged,
    required this.resolved,
    required this.openBySensorType,
  });

  int get totalEvents => open + resolved;
}

class ConsumptionSummary {
  final double electricityKwh;
  final double waterCubicMeters;

  const ConsumptionSummary({
    required this.electricityKwh,
    required this.waterCubicMeters,
  });
}

class DashboardSummary {
  final AlertSummary alerts;
  final ConsumptionSummary consumption;

  const DashboardSummary({
    required this.alerts,
    required this.consumption,
  });
}