class RequestSubscriptionDto {
  final int galleryId;
  final int monitoredUnitCount;
  final int planId;
  final String billingCycle; // 'MONTHLY' | 'ANNUAL'
  final String paymentMethod; // 'CARD' | 'YAPE' | 'BANK_TRANSFER'
  final String? cardNumber;
  final String? cardExpiry;

  const RequestSubscriptionDto({
    required this.galleryId,
    required this.monitoredUnitCount,
    required this.planId,
    required this.billingCycle,
    required this.paymentMethod,
    this.cardNumber,
    this.cardExpiry,
  });

  Map<String, dynamic> toJson() => {
        'galleryId': galleryId,
        'monitoredUnitCount': monitoredUnitCount,
        'planId': planId,
        'billingCycle': billingCycle,
        'paymentMethod': paymentMethod,
        if (cardNumber != null && cardNumber!.isNotEmpty)
          'cardNumber': cardNumber,
        if (cardExpiry != null && cardExpiry!.isNotEmpty)
          'cardExpiry': cardExpiry,
      };
}