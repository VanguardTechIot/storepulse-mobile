class SubscriptionPlan {
  final int id;
  final String code; // 'BASIC' | 'STANDARD' | 'PRO'
  final int? monitoredUnitLimit;
  final double monthlyPrice;
  final double annualPrice;
  final String currency;
  final List<String> features;
  final bool published;

  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.monitoredUnitLimit,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.currency,
    required this.features,
    required this.published,
  });

  String get capacityLabel => monitoredUnitLimit == null
      ? 'Locales comerciales ilimitados'
      : 'Hasta $monitoredUnitLimit locales comerciales';
}