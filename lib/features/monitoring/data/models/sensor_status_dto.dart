import '../../domain/sensor_status.dart';

class SensorStatusDto {
  final String type;
  final double value;
  final String unit;
  final String recordedAt;

  const SensorStatusDto({
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
  });

  factory SensorStatusDto.fromJson(Map<String, dynamic> json) {
    return SensorStatusDto(
      type: json['type'] as String,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      recordedAt: json['recordedAt'] as String,
    );
  }

  SensorStatus toDomain() => SensorStatus(
    type: type,
    value: value,
    unit: unit,
    recordedAt: DateTime.parse(recordedAt).toLocal(),
  );
}
