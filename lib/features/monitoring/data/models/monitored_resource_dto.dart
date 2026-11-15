class MonitoredResourceDto {
  final int resourceId;
  final List<int> deviceIds;

  const MonitoredResourceDto({
    required this.resourceId,
    required this.deviceIds,
  });

  factory MonitoredResourceDto.fromJson(Map<String, dynamic> json) {
    return MonitoredResourceDto(
      resourceId: (json['resourceId'] as num).toInt(),
      deviceIds: (json['deviceIds'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
    );
  }
}
