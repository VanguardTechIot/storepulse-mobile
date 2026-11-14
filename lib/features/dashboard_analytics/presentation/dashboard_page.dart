import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/status_colors.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_state.dart';
import 'dashboard_view_model.dart';

class DashboardPage extends StatelessWidget {
  final String currentRole;

  const DashboardPage({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardViewModel>()..loadSummary(),
      child: BlocBuilder<DashboardViewModel, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
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
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<DashboardViewModel>().loadSummary(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as DashboardLoaded;
          final isAdmin = currentRole == 'GALLERY_ADMINISTRATOR';

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardViewModel>().loadSummary(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SegmentBanner(isGalleryAdmin: isAdmin),
                const SizedBox(height: 16),
                if (isAdmin)
                  _GalleryAdminDashboardView(summary: loaded.summary)
                else
                  _TenantDashboardView(summary: loaded.summary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SegmentBanner extends StatelessWidget {
  final bool isGalleryAdmin;

  const _SegmentBanner({required this.isGalleryAdmin});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGalleryAdmin
              ? [colorScheme.primaryContainer, colorScheme.secondaryContainer]
              : [colorScheme.tertiaryContainer, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGalleryAdmin ? Icons.domain : Icons.storefront,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGalleryAdmin
                      ? 'SEGMENTO 1 · ADMINISTRADOR DE GALERÍA'
                      : 'SEGMENTO 2 · INQUILINO DE LOCAL COMERCIAL',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGalleryAdmin
                      ? 'Dashboard Consolidado Multi-Local'
                      : 'Estado Operativo y Consumo de Mi Local',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGalleryAdmin
                      ? 'Supervisión global de alertas críticas y servicios de toda la galería.'
                      : 'Monitoreo preventivo 24/7 de tu mercadería y consumo eléctrico/agua.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// TARGET SEGMENT 1 VIEW: COMMERCIAL GALLERY ADMINISTRATOR OR OWNER
/// ============================================================================
class _GalleryAdminDashboardView extends StatelessWidget {
  final DashboardSummary summary;

  const _GalleryAdminDashboardView({required this.summary});

  @override
  Widget build(BuildContext context) {
    final alerts = summary.alerts;
    final consumption = summary.consumption;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final sectionTitleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado Global de Alertas en la Galería',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _MetricCard(
              title: 'Alertas Abiertas',
              value: '${alerts.open}',
              subtitle: 'Requieren atención',
              color: colorScheme.error,
              icon: Icons.warning_amber_rounded,
            ),
            _MetricCard(
              title: 'Activas Sin Atender',
              value: '${alerts.active}',
              subtitle: 'En estado crítico',
              color: statusColors.warning,
              icon: Icons.notifications_active_outlined,
            ),
            _MetricCard(
              title: 'Reconocidas',
              value: '${alerts.acknowledged}',
              subtitle: 'En revisión técnica',
              color: statusColors.info,
              icon: Icons.visibility_outlined,
            ),
            _MetricCard(
              title: 'Resueltas',
              value: '${alerts.resolved}',
              subtitle: 'Mitigadas con éxito',
              color: statusColors.success,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Incidencias Abiertas por Tipo de Sensor (Galería)',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 10),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: alerts.openBySensorType.isEmpty
                ? Row(
                    children: [
                      Icon(Icons.verified_user, color: statusColors.success),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sin incidencias abiertas por tipo de sensor en los locales monitoreados.',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: alerts.openBySensorType.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    _sensorIcon(entry.key),
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _sensorLabel(entry.key),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${entry.value} abiertas',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Consumo Consolidado de Suministros (Galería)',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ConsumptionCard(
                label: 'Energía Eléctrica Total',
                value: '${consumption.electricityKwh.toStringAsFixed(1)} kWh',
                caption: 'Acumulado en medidores de galería',
                icon: Icons.bolt,
                accentColor: statusColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConsumptionCard(
                label: 'Consumo de Agua Total',
                value: '${consumption.waterCubicMeters.toStringAsFixed(2)} m³',
                caption: 'Flujo acumulado en red general',
                icon: Icons.water_drop,
                accentColor: colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================================================
/// TARGET SEGMENT 2 VIEW: COMMERCIAL UNIT TENANT
/// ============================================================================
class _TenantDashboardView extends StatelessWidget {
  final DashboardSummary summary;

  const _TenantDashboardView({required this.summary});

  @override
  Widget build(BuildContext context) {
    final alerts = summary.alerts;
    final consumption = summary.consumption;
    final hasEmergency = alerts.open > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final stateColor = hasEmergency ? colorScheme.error : statusColors.success;
    final sectionTitleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: stateColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                hasEmergency ? Icons.gpp_maybe : Icons.shield_outlined,
                size: 36,
                color: stateColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasEmergency
                          ? 'Atención: ${alerts.open} alerta(s) abierta(s) en tu local'
                          : 'Tu local comercial opera con normalidad',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stateColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasEmergency
                          ? 'Activas: ${alerts.active} · En seguimiento: ${alerts.acknowledged}'
                          : 'Sensores ambientales y de seguridad reportando en rango seguro.',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Consumo Acumulado de Mi Local Comercial',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ConsumptionCard(
                label: 'Electricidad del Local',
                value: '${consumption.electricityKwh.toStringAsFixed(1)} kWh',
                caption: 'Monitoreo continuo contra sobrecargas',
                icon: Icons.electrical_services,
                accentColor: statusColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConsumptionCard(
                label: 'Agua del Local',
                value: '${consumption.waterCubicMeters.toStringAsFixed(2)} m³',
                caption: 'Control preventivo de fugas nocturnas',
                icon: Icons.plumbing,
                accentColor: statusColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Sensores de Protección en Mi Unidad Comercial',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 10),
        _TenantSensorStatusTile(
          sensorName: 'Detector de Humo e Incendio (SMOKE)',
          openCount: alerts.openBySensorType['SMOKE'] ?? 0,
          icon: Icons.local_fire_department_outlined,
        ),
        const SizedBox(height: 8),
        _TenantSensorStatusTile(
          sensorName: 'Sensor de Temperatura Ambiental (TEMPERATURE)',
          openCount: alerts.openBySensorType['TEMPERATURE'] ?? 0,
          icon: Icons.thermostat_outlined,
        ),
        const SizedBox(height: 8),
        _TenantSensorStatusTile(
          sensorName:
              'Sensor de Apertura / Intrusión Fuera de Horario (INTRUSION)',
          openCount: alerts.openBySensorType['INTRUSION'] ?? 0,
          icon: Icons.sensor_door_outlined,
        ),
        const SizedBox(height: 8),
        _TenantSensorStatusTile(
          sensorName: 'Sensor de Inundación y Humedad Crítica (FLOOD)',
          openCount: alerts.openBySensorType['FLOOD'] ?? 0,
          icon: Icons.water_damage_outlined,
        ),
      ],
    );
  }
}

class _TenantSensorStatusTile extends StatelessWidget {
  final String sensorName;
  final int openCount;
  final IconData icon;

  const _TenantSensorStatusTile({
    required this.sensorName,
    required this.openCount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isAlert = openCount > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final chipColor = isAlert ? colorScheme.error : statusColors.success;

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAlert
              ? colorScheme.error.withValues(alpha: 0.12)
              : colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: isAlert ? colorScheme.error : colorScheme.primary,
          ),
        ),
        title: Text(
          sensorName,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isAlert ? '$openCount ALERTA' : 'NORMAL',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color accentColor;

  const _ConsumptionCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withValues(alpha: 0.14),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _sensorIcon(String type) {
  switch (type.toUpperCase()) {
    case 'SMOKE':
      return Icons.local_fire_department_outlined;
    case 'TEMPERATURE':
      return Icons.thermostat_outlined;
    case 'INTRUSION':
      return Icons.sensor_door_outlined;
    case 'FLOOD':
      return Icons.water_damage_outlined;
    case 'ELECTRICITY':
      return Icons.bolt_outlined;
    case 'WATER':
      return Icons.water_drop_outlined;
    default:
      return Icons.sensors;
  }
}

String _sensorLabel(String type) {
  switch (type.toUpperCase()) {
    case 'SMOKE':
      return 'Humo e Incendio (SMOKE)';
    case 'TEMPERATURE':
      return 'Temperatura Crítica (TEMPERATURE)';
    case 'INTRUSION':
      return 'Intrusión / Puerta (INTRUSION)';
    case 'FLOOD':
      return 'Inundación / Fuga (FLOOD)';
    case 'ELECTRICITY':
      return 'Anomalía Eléctrica (ELECTRICITY)';
    case 'WATER':
      return 'Flujo de Agua (WATER)';
    default:
      return type;
  }
}
