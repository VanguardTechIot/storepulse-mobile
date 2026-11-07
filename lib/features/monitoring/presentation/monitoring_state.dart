import '../domain/consumption.dart';
import '../domain/monitored_location.dart';
import '../domain/sensor_status.dart';

sealed class MonitoringState {}

class MonitoringInitial extends MonitoringState {}

class MonitoringLoading extends MonitoringState {}

class MonitoringLoaded extends MonitoringState {
  final List<MonitoredLocation> locations;
  final MonitoredLocation? selected;
  final List<Consumption> consumption;
  final List<SensorStatus> sensors;

  MonitoringLoaded({
    required this.locations,
    required this.selected,
    required this.consumption,
    required this.sensors,
  });

  List<Consumption> currentPeriod(DateTime now) =>
      consumption.where((c) => c.isPeriodOf(now)).toList();

  List<Consumption> history(DateTime now) =>
      consumption.where((c) => !c.isPeriodOf(now)).toList();

  DateTime? lastReadingOf(String type) =>
      sensors.where((s) => s.type == type).firstOrNull?.recordedAt;
}

class MonitoringError extends MonitoringState {
  final String message;
  MonitoringError(this.message);
}
