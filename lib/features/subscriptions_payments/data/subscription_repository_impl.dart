import '../domain/payment.dart';
import '../domain/subscription.dart';
import '../domain/subscription_plan.dart';
import '../domain/subscription_repository.dart';
import 'models/request_subscription_dto.dart';
import 'subscription_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionService _service;

  SubscriptionRepositoryImpl(this._service);

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final dtos = await _service.fetchPlans();
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Subscription?> getSubscriptionByGallery(int galleryId) async {
    final dto = await _service.fetchSubscriptionByGallery(galleryId);
    return dto?.toDomain();
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
    final dto = await _service.requestSubscription(
      RequestSubscriptionDto(
        galleryId: galleryId,
        monitoredUnitCount: monitoredUnitCount,
        planId: planId,
        billingCycle: billingCycle,
        paymentMethod: paymentMethod,
        cardNumber: cardNumber,
        cardExpiry: cardExpiry,
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<Subscription> toggleAutoRenewal({
    required int subscriptionId,
    required bool enableAutoRenewal,
  }) async {
    final dto = enableAutoRenewal
        ? await _service.reactivateAutoRenewal(subscriptionId)
        : await _service.cancelAutoRenewal(subscriptionId);
    return dto.toDomain();
  }

  @override
  Future<List<Payment>> getPayments(int subscriptionId) async {
    final dtos = await _service.fetchPayments(subscriptionId);
    return dtos.map((e) => e.toDomain()).toList();
  }
}