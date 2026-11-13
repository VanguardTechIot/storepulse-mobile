import 'package:flutter_bloc/flutter_bloc.dart';
import '../../iam/data/token_manager.dart';
import '../domain/payment.dart';
import '../domain/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionViewModel extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;
  final TokenManager _tokenManager;

  SubscriptionViewModel(this._repository, this._tokenManager)
      : super(SubscriptionInitial());

  Future<void> loadData({int? customGalleryId}) async {
    emit(SubscriptionLoading());
    try {
      final role = await _tokenManager.getRole();
      final galleryId = customGalleryId ?? await _tokenManager.getGalleryId();
      if (customGalleryId != null) {
        await _tokenManager.setGalleryId(customGalleryId);
      }

      final plans = await _repository.getPlans();
      final subscription =
          await _repository.getSubscriptionByGallery(galleryId);

      var payments = <Payment>[];
      if (subscription != null) {
        payments = await _repository.getPayments(subscription.id);
      }

      emit(
        SubscriptionLoaded(
          plans: plans,
          currentSubscription: subscription,
          payments: payments,
          activeRole: role,
          galleryId: galleryId,
        ),
      );
    } catch (e) {
      emit(SubscriptionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> subscribeToPlan({
    required int galleryId,
    required int monitoredUnitCount,
    required int planId,
    required String billingCycle,
    required String paymentMethod,
    String? cardNumber,
    String? cardExpiry,
  }) async {
    emit(SubscriptionLoading());
    try {
      await _repository.requestSubscription(
        galleryId: galleryId,
        monitoredUnitCount: monitoredUnitCount,
        planId: planId,
        billingCycle: billingCycle,
        paymentMethod: paymentMethod,
        cardNumber: cardNumber,
        cardExpiry: cardExpiry,
      );
      await loadData(customGalleryId: galleryId);
    } catch (e) {
      emit(SubscriptionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleAutoRenewal(
    int subscriptionId,
    bool enableAutoRenewal,
  ) async {
    try {
      await _repository.toggleAutoRenewal(
        subscriptionId: subscriptionId,
        enableAutoRenewal: enableAutoRenewal,
      );
      await loadData();
    } catch (e) {
      emit(SubscriptionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}