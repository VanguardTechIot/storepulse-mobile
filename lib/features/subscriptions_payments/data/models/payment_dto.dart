import '../../domain/payment.dart';

class PaymentDto {
  final int id;
  final int subscriptionId;
  final String receiptNumber;
  final int planId;
  final String billingCycle;
  final double amount;
  final String currency;
  final String method;
  final String methodLabel;
  final String status;
  final String gatewayReference;
  final String registeredAt;

  const PaymentDto({
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

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subscriptionId: (json['subscriptionId'] as num?)?.toInt() ?? 0,
      receiptNumber: json['receiptNumber'] as String? ?? '',
      planId: (json['planId'] as num?)?.toInt() ?? 1,
      billingCycle: json['billingCycle'] as String? ?? 'MONTHLY',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PEN',
      method: json['method'] as String? ?? 'CARD',
      methodLabel: json['methodLabel'] as String? ?? '',
      status: json['status'] as String? ?? 'ACCEPTED',
      gatewayReference: json['gatewayReference'] as String? ?? '',
      registeredAt: json['registeredAt']?.toString() ?? '',
    );
  }

  Payment toDomain() => Payment(
        id: id,
        subscriptionId: subscriptionId,
        receiptNumber: receiptNumber,
        planId: planId,
        billingCycle: billingCycle,
        amount: amount,
        currency: currency,
        method: method,
        methodLabel: methodLabel,
        status: status,
        gatewayReference: gatewayReference,
        registeredAt: registeredAt,
      );
}