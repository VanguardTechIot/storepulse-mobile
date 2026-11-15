import '../../domain/subscription.dart';

class SubscriptionDto {
  final int id;
  final int galleryId;
  final int galleryAdministratorId;
  final int planId;
  final String status;
  final String billingCycle;
  final String startDate;
  final String endDate;
  final int monitoredUnitCount;
  final bool autoRenewal;
  final String paymentMethodLabel;

  const SubscriptionDto({
    required this.id,
    required this.galleryId,
    required this.galleryAdministratorId,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    required this.monitoredUnitCount,
    required this.autoRenewal,
    required this.paymentMethodLabel,
  });

  factory SubscriptionDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      galleryId: (json['galleryId'] as num?)?.toInt() ?? 1,
      galleryAdministratorId:
          (json['galleryAdministratorId'] as num?)?.toInt() ?? 0,
      planId: (json['planId'] as num?)?.toInt() ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      billingCycle: json['billingCycle'] as String? ?? 'MONTHLY',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      monitoredUnitCount: (json['monitoredUnitCount'] as num?)?.toInt() ?? 1,
      autoRenewal: json['autoRenewal'] as bool? ?? true,
      paymentMethodLabel: json['paymentMethodLabel'] as String? ?? '',
    );
  }

  Subscription toDomain() => Subscription(
        id: id,
        galleryId: galleryId,
        galleryAdministratorId: galleryAdministratorId,
        planId: planId,
        status: status,
        billingCycle: billingCycle,
        startDate: startDate,
        endDate: endDate,
        monitoredUnitCount: monitoredUnitCount,
        autoRenewal: autoRenewal,
        paymentMethodLabel: paymentMethodLabel,
      );
}