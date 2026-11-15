class SensorStatus {
  final String type;
  final double value;
  final String unit;
  final DateTime recordedAt;

  const SensorStatus({
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  bool get isMotion => type == 'MOTION';

  bool get motionDetected => isMotion && value >= 1;
}
