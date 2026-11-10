import '../domain/consumption.dart';
import '../domain/monitored_location.dart';
import '../domain/monitoring_repository.dart';
import '../domain/sensor_status.dart';
import 'monitoring_service.dart';

class MonitoringRepositoryImpl implements MonitoringRepository {
  final MonitoringService _monitoringService;

  MonitoringRepositoryImpl(this._monitoringService);

  @override
  Future<List<MonitoredLocation>> getLocations() async {
    final monitored = await _monitoringService.fetchMonitoredResources();
    final resources = await _monitoringService.fetchResources();
    final names = {
      for (final resource in resources) resource.id: resource.name,
    };
    return monitored
        .where((item) => names.containsKey(item.resourceId))
        .map(
          (item) => MonitoredLocation(
            resourceId: item.resourceId,
            name: names[item.resourceId]!,
            hasDevice: item.deviceIds.isNotEmpty,
          ),
        )
        .toList();
  }

  @override
  Future<List<Consumption>> getConsumption(int resourceId) async {
    final items = await _monitoringService.fetchConsumption(resourceId);
    return items.map((dto) => dto.toDomain()).toList()
      ..sort((a, b) => b.periodStart.compareTo(a.periodStart));
  }

  @override
  Future<List<SensorStatus>> getSensorStatus(int resourceId) async {
    final items = await _monitoringService.fetchSensorStatus(resourceId);
    return items.map((dto) => dto.toDomain()).toList();
  }
}
