class MonitoredLocation {
  final int resourceId;
  final String name;
  final int? deviceId;
  final bool deviceUnknown;

  const MonitoredLocation({
    required this.resourceId,
    required this.name,
    this.deviceId,
    this.deviceUnknown = false,
  });

  bool get hasDevice => deviceId != null;
}
