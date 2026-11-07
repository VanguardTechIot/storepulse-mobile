import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../domain/payment.dart';
import '../domain/subscription.dart';
import '../domain/subscription_plan.dart';
import 'subscription_checkout_page.dart';
import 'subscription_state.dart';
import 'subscription_view_model.dart';

class SubscriptionPage extends StatelessWidget {
  final String currentRole;

  const SubscriptionPage({
    super.key,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubscriptionViewModel>()..loadData(),
      child: BlocBuilder<SubscriptionViewModel, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          }

          if (state is SubscriptionError) {
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
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
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
            color: const Color(0xFF0EA5E9),
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
                  context
                      .read<SubscriptionViewModel>()
                      .toggleAutoRenewal(currentSub.id, enable);
                },
        ),
        const SizedBox(height: 20),
        const Text(
          'Planes Comerciales para tu Galería',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ...loaded.plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(
              plan: plan,
              isCurrentPlan: currentSub?.planId == plan.id,
              onSelectPlan: () async {
                final viewModel = context.read<SubscriptionViewModel>();
                final result =
                    await Navigator.push<SubscriptionCheckoutResult>(
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
        const Text(
          'Historial de Pagos y Comprobantes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        if (loaded.payments.isEmpty)
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aún no se registran pagos para esta galería comercial.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ...loaded.payments.map((payment) => _PaymentReceiptTile(payment: payment)),
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
    final plan = loaded.activePlan ??
        (loaded.plans.isNotEmpty ? loaded.plans.first : null);
    final isCovered = sub == null || sub.isActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: Color(0xFF38BDF8),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCovered
                          ? 'COBERTURA IOT ACTIVA EN TU LOCAL'
                          : 'SUSCRIPCIÓN DE GALERÍA POR RENOVAR',
                      style: const TextStyle(
                        color: Color(0xFF7DD3FC),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sub != null
                    ? 'Vigencia operativa: ${sub.startDate} al ${sub.endDate} · ${sub.monitoredUnitCount} locales cubiertos'
                    : 'Tu unidad comercial cuenta con supervisión preventiva de siniestros y consumo 24/7.',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Alcances del Servicio Incluidos para Tu Tienda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        if (plan != null)
          ...plan.features.map(
            (feature) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                ),
                title: Text(
                  feature,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF475569)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La facturación y renovación comercial del servicio IoT son gestionadas directamente por la Administración de la Galería Comercial.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
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
    if (subscription == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFD97706)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'La Galería #$galleryId aún no tiene una suscripción activa. Selecciona un plan inferior para activarla.',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
        color: const Color(0xFF0F172A),
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
                style: const TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subscription!.status,
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${subscription!.monitoredUnitCount} locales monitoreados (${subscription!.billingCycle})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vigencia: ${subscription!.startDate} → ${subscription!.endDate}\nMedio de pago: ${subscription!.paymentMethodLabel}',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Renovación automática',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Switch(
                value: subscription!.autoRenewal,
                activeThumbColor: const Color(0xFF0EA5E9),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF0EA5E9)
              : const Color(0xFFE2E8F0),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${plan.currency} ${plan.monthlyPrice.toStringAsFixed(0)}/mes',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.capacityLabel} · Anual: ${plan.currency} ${plan.annualPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isCurrentPlan
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFF0F172A),
                foregroundColor: isCurrentPlan
                    ? const Color(0xFF0369A1)
                    : Colors.white,
              ),
              onPressed: onSelectPlan,
              child: Text(
                isCurrentPlan
                    ? 'Actualizar / Renovar Plan Actual'
                    : 'Seleccionar Plan ${plan.code}',
              ),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFD1FAE5),
          child: Icon(Icons.receipt_long, color: Color(0xFF047857)),
        ),
        title: Text(
          '${payment.receiptNumber} · ${payment.currency} ${payment.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          '${payment.methodLabel} (${payment.billingCycle})\nRef: ${payment.gatewayReference}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        trailing: Text(
          payment.status,
          style: const TextStyle(
            color: Color(0xFF10B981),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}