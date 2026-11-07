import '../domain/payment.dart';
import '../domain/subscription.dart';
import '../domain/subscription_plan.dart';

sealed class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  final Subscription? currentSubscription;
  final List<Payment> payments;
  final String activeRole;
  final int galleryId;

  SubscriptionLoaded({
    required this.plans,
    required this.currentSubscription,
    required this.payments,
    required this.activeRole,
    required this.galleryId,
  });

  SubscriptionPlan? get activePlan {
    if (currentSubscription == null) return null;
    for (final plan in plans) {
      if (plan.id == currentSubscription!.planId) return plan;
    }
    return null;
  }
}

class SubscriptionError extends SubscriptionState {
  final String message;
  SubscriptionError(this.message);
}