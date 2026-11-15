class Payment {
  final int id;
  final int subscriptionId;
  final String receiptNumber;
  final int planId;
  final String billingCycle;
  final double amount;
  final String currency;
  final String method;
  final String methodLabel;
  final String status; // 'ACCEPTED' | 'PENDING' | 'REJECTED'
  final String gatewayReference;
  final String registeredAt;

  const Payment({
    required this.id,
    required this.subscriptionId,
    required this.receiptNumber,
    required this.planId,
    required this.billingCycle,
    required this.amount,
    required this.currency,
    required this.method,
    required this.methodLabel,
    required this.status,
    required this.gatewayReference,
    required this.registeredAt,
  });
}