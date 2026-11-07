import '../domain/consumption.dart';
import '../domain/monitored_location.dart';
import '../domain/monitoring_repository.dart';
import '../domain/sensor_status.dart';
import 'models/iot_device_dto.dart';
import 'monitoring_service.dart';

class MonitoringRepositoryImpl implements MonitoringRepository {
  final MonitoringService _monitoringService;

  MonitoringRepositoryImpl(this._monitoringService);

  @override
  Future<List<MonitoredLocation>> getLocations() async {
    final resources = await _monitoringService.fetchResources();
    List<IoTDeviceDto>? devices;
    try {
      devices = await _monitoringService.fetchIoTDevices();
    } catch (_) {
      devices = null;
    }
    return resources.map((resource) {
      final device = devices
          ?.where((d) => d.resourceId == resource.id && d.isActive)
          .firstOrNull;
      return MonitoredLocation(
        resourceId: resource.id,
        name: resource.name,
        deviceId: device?.id,
        deviceUnknown: devices == null,
      );
    }).toList();
  }

  @override
  Future<List<Consumption>> getConsumption(int resourceId) async {
    final items = await _monitoringService.fetchConsumption(resourceId);
    return items.map((dto) => dto.toDomain()).toList()
      ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
  }

  @override
  Future<List<SensorStatus>> getSensorStatus(int deviceId) async {
    final items = await _monitoringService.fetchSensorStatus(deviceId);
    return items.map((dto) => dto.toDomain()).toList();
  }
}
