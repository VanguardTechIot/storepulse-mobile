class IoTDeviceDto {
  final int id;
  final int? resourceId;
  final String status;

  const IoTDeviceDto({
    required this.id,
    required this.resourceId,
    required this.status,
  });

  factory IoTDeviceDto.fromJson(Map<String, dynamic> json) {
    return IoTDeviceDto(
      id: (json['id'] as num).toInt(),
      resourceId: (json['resourceId'] as num?)?.toInt(),
      status: json['status'] as String? ?? '',
    );
  }

  bool get isActive => status == 'ACTIVE';
}
