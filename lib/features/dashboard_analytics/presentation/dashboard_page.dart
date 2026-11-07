import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../domain/dashboard_summary.dart';
import 'dashboard_state.dart';
import 'dashboard_view_model.dart';

class DashboardPage extends StatelessWidget {
  final String currentRole;

  const DashboardPage({
    super.key,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardViewModel>()..loadSummary(),
      child: BlocBuilder<DashboardViewModel, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
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
            color: const Color(0xFF0EA5E9),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGalleryAdmin
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFF0369A1), const Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGalleryAdmin ? Icons.domain : Icons.storefront,
              color: Colors.white,
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
                  style: const TextStyle(
                    color: Color(0xFF7DD3FC),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGalleryAdmin
                      ? 'Dashboard Consolidado Multi-Local'
                      : 'Estado Operativo y Consumo de Mi Local',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGalleryAdmin
                      ? 'Supervisión global de alertas críticas y servicios de toda la galería.'
                      : 'Monitoreo preventivo 24/7 de tu mercadería y consumo eléctrico/agua.',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado Global de Alertas en la Galería',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
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
              color: const Color(0xFFEF4444),
              icon: Icons.warning_amber_rounded,
            ),
            _MetricCard(
              title: 'Activas Sin Atender',
              value: '${alerts.active}',
              subtitle: 'En estado crítico',
              color: const Color(0xFFF59E0B),
              icon: Icons.notifications_active_outlined,
            ),
            _MetricCard(
              title: 'Reconocidas',
              value: '${alerts.acknowledged}',
              subtitle: 'En revisión técnica',
              color: const Color(0xFF3B82F6),
              icon: Icons.visibility_outlined,
            ),
            _MetricCard(
              title: 'Resueltas',
              value: '${alerts.resolved}',
              subtitle: 'Mitigadas con éxito',
              color: const Color(0xFF10B981),
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Incidencias Abiertas por Tipo de Sensor (Galería)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: alerts.openBySensorType.isEmpty
                ? const Row(
                    children: [
                      Icon(Icons.verified_user, color: Color(0xFF10B981)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sin incidencias abiertas por tipo de sensor en los locales monitoreados.',
                          style: TextStyle(color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: alerts.openBySensorType.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _sensorIcon(entry.key),
                                  color: const Color(0xFF0EA5E9),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _sensorLabel(entry.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${entry.value} abiertas',
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
        const Text(
          'Consumo Consolidado de Suministros (Galería)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
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
                accentColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConsumptionCard(
                label: 'Consumo de Agua Total',
                value: '${consumption.waterCubicMeters.toStringAsFixed(2)} m³',
                caption: 'Flujo acumulado en red general',
                icon: Icons.water_drop,
                accentColor: const Color(0xFF0EA5E9),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasEmergency
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasEmergency
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFA7F3D0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasEmergency ? Icons.gpp_maybe : Icons.shield_outlined,
                size: 36,
                color: hasEmergency
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: hasEmergency
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF065F46),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasEmergency
                          ? 'Activas: ${alerts.active} · En seguimiento: ${alerts.acknowledged}'
                          : 'Sensores ambientales y de seguridad reportando en rango seguro.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Consumo Acumulado de Mi Local Comercial',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
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
                accentColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ConsumptionCard(
                label: 'Agua del Local',
                value: '${consumption.waterCubicMeters.toStringAsFixed(2)} m³',
                caption: 'Control preventivo de fugas nocturnas',
                icon: Icons.plumbing,
                accentColor: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Sensores de Protección en Mi Unidad Comercial',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
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
          sensorName: 'Sensor de Apertura / Intrusión Fuera de Horario (INTRUSION)',
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAlert
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFE0F2FE),
          child: Icon(
            icon,
            color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
          ),
        ),
        title: Text(
          sensorName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAlert
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isAlert ? '$openCount ALERTA' : 'NORMAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAlert
                  ? const Color(0xFFB91C1C)
                  : const Color(0xFF047857),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
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