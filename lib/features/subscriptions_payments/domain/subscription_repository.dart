import 'payment.dart';
import 'subscription.dart';
import 'subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getPlans();
  Future<Subscription?> getSubscriptionByGallery(int galleryId);
  Future<Subscription> requestSubscription({
    required int galleryId,
    required int monitoredUnitCount,
    required int planId,
    required String billingCycle,
    required String paymentMethod,
    String? cardNumber,
    String? cardExpiry,
  });
  Future<Subscription> toggleAutoRenewal({
    required int subscriptionId,
    required bool enableAutoRenewal,
  });
  Future<List<Payment>> getPayments(int subscriptionId);
}