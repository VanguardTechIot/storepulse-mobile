class Consumption {
  final int resourceId;
  final String measurementType;
  final double totalValue;
  final String unit;
  final DateTime periodStart;
  final DateTime periodEnd;

  const Consumption({
    required this.resourceId,
    required this.measurementType,
    required this.totalValue,
    required this.unit,
    required this.periodStart,
    required this.periodEnd,
  });

  bool isPeriodOf(DateTime instant) {
    final utc = instant.toUtc();
    return !utc.isBefore(periodStart) && utc.isBefore(periodEnd);
  }
}
