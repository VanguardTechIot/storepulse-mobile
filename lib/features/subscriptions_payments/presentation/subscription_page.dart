import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/status_colors.dart';
import '../domain/payment.dart';
import '../domain/subscription.dart';
import '../domain/subscription_plan.dart';
import 'subscription_checkout_page.dart';
import 'subscription_state.dart';
import 'subscription_view_model.dart';

class SubscriptionPage extends StatelessWidget {
  final String currentRole;

  const SubscriptionPage({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubscriptionViewModel>()..loadData(),
      child: BlocBuilder<SubscriptionViewModel, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionError) {
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
                          context.read<SubscriptionViewModel>().loadData(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loaded = state as SubscriptionLoaded;
          final isAdmin = currentRole == 'GALLERY_ADMINISTRATOR';

          return RefreshIndicator(
            onRefresh: () => context.read<SubscriptionViewModel>().loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (isAdmin)
                  _GalleryAdminSubscriptionView(loaded: loaded)
                else
                  _TenantSubscriptionCoverageView(loaded: loaded),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================================================================
/// TARGET SEGMENT 1 VIEW: GALLERY ADMINISTRATOR (SUBSCRIPTION MANAGEMENT)
/// ============================================================================
class _GalleryAdminSubscriptionView extends StatelessWidget {
  final SubscriptionLoaded loaded;

  const _GalleryAdminSubscriptionView({required this.loaded});

  @override
  Widget build(BuildContext context) {
    final currentSub = loaded.currentSubscription;
    final activePlan = loaded.activePlan;
    final sectionTitleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActiveSubscriptionBanner(
          subscription: currentSub,
          plan: activePlan,
          galleryId: loaded.galleryId,
          onToggleRenewal: currentSub == null
              ? null
              : (enable) {
                  context.read<SubscriptionViewModel>().toggleAutoRenewal(
                    currentSub.id,
                    enable,
                  );
                },
        ),
        const SizedBox(height: 20),
        Text('Planes Comerciales para tu Galería', style: sectionTitleStyle),
        const SizedBox(height: 10),
        ...loaded.plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(
              plan: plan,
              isCurrentPlan: currentSub?.planId == plan.id,
              onSelectPlan: () async {
                final viewModel = context.read<SubscriptionViewModel>();
                final result = await Navigator.push<SubscriptionCheckoutResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionCheckoutPage(
                      plan: plan,
                      initialGalleryId: loaded.galleryId,
                    ),
                  ),
                );
                if (result != null) {
                  await viewModel.subscribeToPlan(
                    galleryId: result.galleryId,
                    monitoredUnitCount: result.monitoredUnitCount,
                    planId: result.planId,
                    billingCycle: result.billingCycle,
                    paymentMethod: result.paymentMethod,
                    cardNumber: result.cardNumber,
                    cardExpiry: result.cardExpiry,
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Historial de Pagos y Comprobantes', style: sectionTitleStyle),
        const SizedBox(height: 10),
        if (loaded.payments.isEmpty)
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aún no se registran pagos para esta galería comercial.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...loaded.payments.map(
            (payment) => _PaymentReceiptTile(payment: payment),
          ),
      ],
    );
  }
}

/// ============================================================================
/// TARGET SEGMENT 2 VIEW: COMMERCIAL UNIT TENANT (SERVICE COVERAGE)
/// ============================================================================
class _TenantSubscriptionCoverageView extends StatelessWidget {
  final SubscriptionLoaded loaded;

  const _TenantSubscriptionCoverageView({required this.loaded});

  @override
  Widget build(BuildContext context) {
    final sub = loaded.currentSubscription;
    final plan =
        loaded.activePlan ??
        (loaded.plans.isNotEmpty ? loaded.plans.first : null);
    final isCovered = sub == null || sub.isActive;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCovered
                          ? 'COBERTURA IOT ACTIVA EN TU LOCAL'
                          : 'SUSCRIPCIÓN DE GALERÍA POR RENOVAR',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                plan != null
                    ? 'Respaldado por Plan ${plan.code} de la Galería'
                    : 'Servicio de Telemetría StorePulse',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sub != null
                    ? 'Vigencia operativa: ${sub.startDate} al ${sub.endDate} · ${sub.monitoredUnitCount} locales cubiertos'
                    : 'Tu unidad comercial cuenta con supervisión preventiva de siniestros y consumo 24/7.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Alcances del Servicio Incluidos para Tu Tienda',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (plan != null)
          ...plan.features.map(
            (feature) => Card.outlined(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: statusColors.success),
                title: Text(
                  feature,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La facturación y renovación comercial del servicio IoT son gestionadas directamente por la Administración de la Galería Comercial.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveSubscriptionBanner extends StatelessWidget {
  final Subscription? subscription;
  final SubscriptionPlan? plan;
  final int galleryId;
  final ValueChanged<bool>? onToggleRenewal;

  const _ActiveSubscriptionBanner({
    required this.subscription,
    required this.plan,
    required this.galleryId,
    this.onToggleRenewal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    if (subscription == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColors.warning.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: statusColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'La Galería #$galleryId aún no tiene una suscripción activa. Selecciona un plan inferior para activarla.',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GALERÍA #$galleryId · PLAN ${plan?.code ?? subscription!.planId}',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subscription!.status,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${subscription!.monitoredUnitCount} locales monitoreados (${subscription!.billingCycle})',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vigencia: ${subscription!.startDate} → ${subscription!.endDate}\nMedio de pago: ${subscription!.paymentMethodLabel}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Renovación automática',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Switch(
                value: subscription!.autoRenewal,
                onChanged: onToggleRenewal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final VoidCallback onSelectPlan;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentPlan
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PLAN ${plan.code}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${plan.currency} ${plan.monthlyPrice.toStringAsFixed(0)}/mes',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.capacityLabel} · Anual: ${plan.currency} ${plan.annualPrice.toStringAsFixed(0)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: statusColors.success),
                  const SizedBox(width: 6),
                  Expanded(child: Text(f, style: textTheme.bodySmall)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isCurrentPlan
                ? FilledButton.tonal(
                    onPressed: onSelectPlan,
                    child: const Text('Actualizar / Renovar Plan Actual'),
                  )
                : FilledButton(
                    onPressed: onSelectPlan,
                    child: Text('Seleccionar Plan ${plan.code}'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentReceiptTile extends StatelessWidget {
  final Payment payment;

  const _PaymentReceiptTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColors.success.withValues(alpha: 0.15),
          child: Icon(Icons.receipt_long, color: statusColors.success),
        ),
        title: Text(
          '${payment.receiptNumber} · ${payment.currency} ${payment.amount.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${payment.methodLabel} (${payment.billingCycle})\nRef: ${payment.gatewayReference}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          payment.status,
          style: textTheme.labelSmall?.copyWith(
            color: statusColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}