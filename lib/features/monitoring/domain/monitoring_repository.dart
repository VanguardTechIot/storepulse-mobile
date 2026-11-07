import 'consumption.dart';
import 'monitored_location.dart';
import 'sensor_status.dart';

abstract class MonitoringRepository {
  Future<List<MonitoredLocation>> getLocations();

  Future<List<Consumption>> getConsumption(int resourceId);

  Future<List<SensorStatus>> getSensorStatus(int deviceId);
}
