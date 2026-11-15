import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/status_colors.dart';
import '../domain/consumption.dart';
import '../domain/monitored_location.dart';
import '../domain/sensor_status.dart';
import 'monitoring_state.dart';
import 'monitoring_view_model.dart';

const _months = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String _two(int value) => value.toString().padLeft(2, '0');

String _formatDateTime(DateTime instant) {
  final local = instant.toLocal();
  return '${_two(local.day)}/${_two(local.month)}/${local.year} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _formatPeriod(DateTime periodStart) =>
    '${_months[periodStart.month - 1]} ${periodStart.year}';

String _sensorLabel(String type) => switch (type) {
  'MOTION' => 'Movimiento',
  'SMOKE' => 'Humo',
  'TEMPERATURE' => 'Temperatura',
  'HUMIDITY' => 'Humedad',
  'ELECTRICITY' => 'Electricidad',
  'WATER' => 'Agua',
  _ => type,
};

IconData _sensorIcon(String type) => switch (type) {
  'MOTION' => Icons.directions_walk,
  'SMOKE' => Icons.local_fire_department,
  'TEMPERATURE' => Icons.thermostat,
  'HUMIDITY' => Icons.water,
  'ELECTRICITY' => Icons.bolt,
  'WATER' => Icons.water_drop,
  _ => Icons.sensors,
};

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MonitoringViewModel>()..load(),
      child: BlocBuilder<MonitoringViewModel, MonitoringState>(
        builder: (context, state) {
          if (state is MonitoringLoading || state is MonitoringInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MonitoringError) {
            return _ErrorView(message: state.message);
          }

          final loaded = state as MonitoringLoaded;
          final now = DateTime.now();

          return RefreshIndicator(
            onRefresh: () => context.read<MonitoringViewModel>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Monitoreo del local',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (loaded.locations.isEmpty)
                  const _InfoCard(
                    icon: Icons.store_outlined,
                    message: 'Aún no tienes locales monitoreados.',
                  )
                else ...[
                  if (loaded.locations.length > 1)
                    _LocationSelector(
                      locations: loaded.locations,
                      selected: loaded.selected,
                    )
                  else
                    _LocationName(name: loaded.selected?.name ?? ''),
                  const SizedBox(height: 20),
                  _SectionTitle('Consumo del periodo'),
                  const SizedBox(height: 10),
                  _CurrentConsumption(state: loaded, now: now),
                  const SizedBox(height: 20),
                  _SectionTitle('Estado de los sensores'),
                  const SizedBox(height: 10),
                  _SensorList(
                    location: loaded.selected,
                    sensors: loaded.sensors,
                  ),
                  if (loaded.history(now).isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Periodos anteriores'),
                    const SizedBox(height: 10),
                    _ConsumptionHistory(items: loaded.history(now)),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<MonitoringViewModel>().load(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final List<MonitoredLocation> locations;
  final MonitoredLocation? selected;

  const _LocationSelector({required this.locations, required this.selected});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selected?.resourceId,
      decoration: InputDecoration(
        labelText: 'Local',
        prefixIcon: Icon(
          Icons.storefront,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      items: locations
          .map(
            (location) => DropdownMenuItem(
              value: location.resourceId,
              child: Text(location.name),
            ),
          )
          .toList(),
      onChanged: (resourceId) {
        final location = locations
            .where((l) => l.resourceId == resourceId)
            .firstOrNull;
        if (location != null) {
          context.read<MonitoringViewModel>().select(location);
        }
      },
    );
  }
}

class _LocationName extends StatelessWidget {
  final String name;

  const _LocationName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CurrentConsumption extends StatelessWidget {
  final MonitoringLoaded state;
  final DateTime now;

  const _CurrentConsumption({required this.state, required this.now});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final current = state.currentPeriod(now);
    Consumption? ofType(String type) =>
        current.where((c) => c.measurementType == type).firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ConsumptionCard(
            label: 'Energía',
            consumption: ofType('ELECTRICITY'),
            fallbackUnit: 'kWh',
            decimals: 1,
            lastReading: state.lastReadingOf('ELECTRICITY'),
            icon: Icons.bolt,
            accent: statusColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ConsumptionCard(
            label: 'Agua',
            consumption: ofType('WATER'),
            fallbackUnit: 'm³',
            decimals: 2,
            lastReading: state.lastReadingOf('WATER'),
            icon: Icons.water_drop,
            accent: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  final String label;
  final Consumption? consumption;
  final String fallbackUnit;
  final int decimals;
  final DateTime? lastReading;
  final IconData icon;
  final Color accent;

  const _ConsumptionCard({
    required this.label,
    required this.consumption,
    required this.fallbackUnit,
    required this.decimals,
    required this.lastReading,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final value = consumption;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value == null
                  ? 'Sin lecturas'
                  : '${value.totalValue.toStringAsFixed(decimals)} '
                        '${value.unit.isEmpty ? fallbackUnit : value.unit}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value == null
                  ? 'Aún no hay lecturas del periodo'
                  : lastReading == null
                  ? 'Última lectura no disponible'
                  : 'Última lectura: ${_formatDateTime(lastReading!)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorList extends StatelessWidget {
  final MonitoredLocation? location;
  final List<SensorStatus> sensors;

  const _SensorList({required this.location, required this.sensors});

  @override
  Widget build(BuildContext context) {
    if (location == null || !location!.hasDevice) {
      return const _InfoCard(
        icon: Icons.sensors_off,
        message: 'Este local no tiene un dispositivo activo.',
      );
    }
    if (sensors.isEmpty) {
      return const _InfoCard(
        icon: Icons.sensors,
        message: 'El dispositivo aún no envía lecturas.',
      );
    }
    return Card.outlined(
      child: Column(
        children: sensors.map((sensor) => _SensorTile(sensor: sensor)).toList(),
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final SensorStatus sensor;

  const _SensorTile({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final reading = sensor.isMotion
        ? (sensor.motionDetected ? 'Movimiento detectado' : 'Sin movimiento')
        : '${sensor.value.toStringAsFixed(1)} ${sensor.unit}';
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        _sensorIcon(sensor.type),
        color: sensor.motionDetected ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        _sensorLabel(sensor.type),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _formatDateTime(sensor.recordedAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        reading,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: sensor.motionDetected
              ? colorScheme.error
              : colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ConsumptionHistory extends StatelessWidget {
  final List<Consumption> items;

  const _ConsumptionHistory({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    return Card.outlined(
      child: Column(
        children: items.map((item) {
          final isElectricity = item.measurementType == 'ELECTRICITY';
          return ListTile(
            leading: Icon(
              isElectricity ? Icons.bolt : Icons.water_drop,
              color: isElectricity ? statusColors.warning : colorScheme.primary,
            ),
            title: Text(_formatPeriod(item.periodStart)),
            trailing: Text(
              '${item.totalValue.toStringAsFixed(isElectricity ? 1 : 2)} '
              '${item.unit}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InfoCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: statusColors.success),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
