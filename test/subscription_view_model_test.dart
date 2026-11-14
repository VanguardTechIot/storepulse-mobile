import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storepulse_mobile/core/di/dependency_injection.dart';
import 'package:storepulse_mobile/core/theme/status_colors.dart';
import 'package:storepulse_mobile/features/iam/data/token_manager.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/domain/payment.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/domain/subscription.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/domain/subscription_plan.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/domain/subscription_repository.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/presentation/subscription_page.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/presentation/subscription_state.dart';
import 'package:storepulse_mobile/features/subscriptions_payments/presentation/subscription_view_model.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  int getPlansCalls = 0;
  int getSubscriptionCalls = 0;
  int getPaymentsCalls = 0;
  bool throwOnAdminQueries = false;

  final List<SubscriptionPlan> plans = const [
    SubscriptionPlan(
      id: 1,
      code: 'BASIC',
      monitoredUnitLimit: 10,
      monthlyPrice: 99,
      annualPrice: 990,
      currency: 'PEN',
      features: ['Monitoreo 24/7', 'Alertas tempranas'],
      published: true,
    ),
  ];

  final Subscription subscription = const Subscription(
    id: 42,
    galleryId: 1,
    galleryAdministratorId: 1,
    planId: 1,
    status: 'ACTIVE',
    billingCycle: 'MONTHLY',
    startDate: '2026-01-01',
    endDate: '2026-02-01',
    monitoredUnitCount: 8,
    autoRenewal: true,
    paymentMethodLabel: 'Visa •••• 4242',
  );

  final List<Payment> payments = const [
    Payment(
      id: 7,
      subscriptionId: 42,
      receiptNumber: 'REC-0007',
      planId: 1,
      billingCycle: 'MONTHLY',
      amount: 99,
      currency: 'PEN',
      method: 'CARD',
      methodLabel: 'Visa •••• 4242',
      status: 'ACCEPTED',
      gatewayReference: 'GW-7',
      registeredAt: '2026-01-01T10:00:00Z',
    ),
  ];

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    getPlansCalls++;
    return plans;
  }

  @override
  Future<Subscription?> getSubscriptionByGallery(int galleryId) async {
    getSubscriptionCalls++;
    if (throwOnAdminQueries) {
      throw Exception('Error al consultar suscripción de la galería (403)');
    }
    return subscription;
  }

  @override
  Future<List<Payment>> getPayments(int subscriptionId) async {
    getPaymentsCalls++;
    if (throwOnAdminQueries) {
      throw Exception('Error al consultar historial de pagos (403)');
    }
    return payments;
  }

  @override
  Future<Subscription> requestSubscription({
    required int galleryId,
    required int monitoredUnitCount,
    required int planId,
    required String billingCycle,
    required String paymentMethod,
    String? cardNumber,
    String? cardExpiry,
  }) async {
    return subscription;
  }

  @override
  Future<Subscription> toggleAutoRenewal({
    required int subscriptionId,
    required bool enableAutoRenewal,
  }) async {
    return subscription;
  }
}

void main() {
  group('SubscriptionViewModel', () {
    test('skips admin-only subscription and payment calls for TENANT', () async {
      SharedPreferences.setMockInitialValues({
        'user_role': 'TENANT',
        'active_gallery_id': 1,
      });
      final repository = _FakeSubscriptionRepository()
        ..throwOnAdminQueries = true;
      final viewModel = SubscriptionViewModel(repository, TokenManager());

      await viewModel.loadData();

      expect(viewModel.state, isA<SubscriptionLoaded>());
      final loaded = viewModel.state as SubscriptionLoaded;
      expect(loaded.activeRole, 'TENANT');
      expect(loaded.currentSubscription, isNull);
      expect(loaded.payments, isEmpty);
      expect(loaded.plans, hasLength(1));
      expect(repository.getPlansCalls, 1);
      expect(repository.getSubscriptionCalls, 0);
      expect(repository.getPaymentsCalls, 0);

      await viewModel.close();
    });

    test('loads gallery subscription and payments for GALLERY_ADMINISTRATOR', () async {
      SharedPreferences.setMockInitialValues({
        'user_role': 'GALLERY_ADMINISTRATOR',
        'active_gallery_id': 1,
      });
      final repository = _FakeSubscriptionRepository();
      final viewModel = SubscriptionViewModel(repository, TokenManager());

      await viewModel.loadData();

      expect(viewModel.state, isA<SubscriptionLoaded>());
      final loaded = viewModel.state as SubscriptionLoaded;
      expect(loaded.activeRole, 'GALLERY_ADMINISTRATOR');
      expect(loaded.currentSubscription?.id, 42);
      expect(loaded.payments, hasLength(1));
      expect(repository.getPlansCalls, 1);
      expect(repository.getSubscriptionCalls, 1);
      expect(repository.getPaymentsCalls, 1);

      await viewModel.close();
    });
  });

  group('SubscriptionPage tenant coverage view', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('shows active IoT coverage without guessing a plan code', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_role': 'TENANT',
        'active_gallery_id': 1,
      });
      final repository = _FakeSubscriptionRepository()
        ..throwOnAdminQueries = true;
      getIt.registerFactory<SubscriptionViewModel>(
        () => SubscriptionViewModel(repository, TokenManager()),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            extensions: const [StatusColors.light],
          ),
          home: const Scaffold(
            body: SubscriptionPage(currentRole: 'TENANT'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('COBERTURA IOT ACTIVA EN TU LOCAL'), findsOneWidget);
      expect(find.text('Servicio de Telemetría StorePulse'), findsOneWidget);
      expect(find.text('Respaldado por Plan BASIC de la Galería'), findsNothing);
      expect(find.text('Monitoreo 24/7'), findsOneWidget);
      expect(
        find.text(
          'La facturación y renovación comercial del servicio IoT son gestionadas directamente por la Administración de la Galería Comercial.',
        ),
        findsOneWidget,
      );
    });
  });
}
