class Subscription {
  final int id;
  final int galleryId;
  final int galleryAdministratorId;
  final int planId;
  final String status; // 'ACTIVE' | 'EXPIRED' | 'CANCELLED' | 'PENDING'
  final String billingCycle; // 'MONTHLY' | 'ANNUAL'
  final String startDate;
  final String endDate;
  final int monitoredUnitCount;
  final bool autoRenewal;
  final String paymentMethodLabel;

  const Subscription({
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

  bool get isActive => status == 'ACTIVE';
}