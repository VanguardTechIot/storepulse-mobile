import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/monitored_location.dart';
import '../domain/monitoring_repository.dart';
import '../domain/sensor_status.dart';
import 'monitoring_state.dart';

class MonitoringViewModel extends Cubit<MonitoringState> {
  final MonitoringRepository _monitoringRepository;

  MonitoringViewModel(this._monitoringRepository) : super(MonitoringInitial());

  Future<void> load() async {
    emit(MonitoringLoading());
    try {
      final locations = await _monitoringRepository.getLocations();
      await _show(locations, locations.firstOrNull);
    } catch (e) {
      emit(MonitoringError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> select(MonitoredLocation location) async {
    final current = state;
    final locations = current is MonitoringLoaded
        ? current.locations
        : [location];
    emit(MonitoringLoading());
    try {
      await _show(locations, location);
    } catch (e) {
      emit(MonitoringError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is MonitoringLoaded && current.selected != null) {
      await select(current.selected!);
    } else {
      await load();
    }
  }

  Future<void> _show(
    List<MonitoredLocation> locations,
    MonitoredLocation? selected,
  ) async {
    if (selected == null) {
      emit(
        MonitoringLoaded(
          locations: locations,
          selected: null,
          consumption: const [],
          sensors: const [],
        ),
      );
      return;
    }
    final consumption = await _monitoringRepository.getConsumption(
      selected.resourceId,
    );
    final sensors = selected.hasDevice
        ? await _monitoringRepository.getSensorStatus(selected.deviceId!)
        : <SensorStatus>[];
    emit(
      MonitoringLoaded(
        locations: locations,
        selected: selected,
        consumption: consumption,
        sensors: sensors,
      ),
    );
  }
}
