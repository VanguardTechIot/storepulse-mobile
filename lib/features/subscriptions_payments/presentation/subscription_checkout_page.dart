import 'package:flutter/material.dart';
import '../domain/subscription_plan.dart';
import '../../../core/theme/status_colors.dart';

class SubscriptionCheckoutResult {
  final int galleryId;
  final int monitoredUnitCount;
  final int planId;
  final String billingCycle;
  final String paymentMethod;
  final String? cardNumber;
  final String? cardExpiry;

  const SubscriptionCheckoutResult({
    required this.galleryId,
    required this.monitoredUnitCount,
    required this.planId,
    required this.billingCycle,
    required this.paymentMethod,
    this.cardNumber,
    this.cardExpiry,
  });
}

class SubscriptionCheckoutPage extends StatefulWidget {
  final SubscriptionPlan plan;
  final int initialGalleryId;

  const SubscriptionCheckoutPage({
    super.key,
    required this.plan,
    required this.initialGalleryId,
  });

  @override
  State<SubscriptionCheckoutPage> createState() =>
      _SubscriptionCheckoutPageState();
}

class _SubscriptionCheckoutPageState extends State<SubscriptionCheckoutPage> {
  late final TextEditingController _galleryIdController;
  final _unitCountController = TextEditingController(text: '10');
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController(text: '12/28');

  String _billingCycle = 'MONTHLY'; // 'MONTHLY' | 'ANNUAL'
  String _paymentMethod = 'CARD'; // 'CARD' | 'YAPE' | 'BANK_TRANSFER'

  @override
  void initState() {
    super.initState();
    _galleryIdController = TextEditingController(
      text: widget.initialGalleryId.toString(),
    );
  }

  @override
  void dispose() {
    _galleryIdController.dispose();
    _unitCountController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = _billingCycle == 'ANNUAL'
        ? widget.plan.annualPrice
        : widget.plan.monthlyPrice;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final sectionTitleStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Contratar Plan ${widget.plan.code}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAN ${widget.plan.code}',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.plan.currency} ${price.toStringAsFixed(2)} / ${_billingCycle == 'ANNUAL' ? 'año' : 'mes'}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.plan.capacityLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _galleryIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID de la Galería Comercial',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _unitCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de Locales Comerciales a Monitorear',
                helperText: widget.plan.capacityLabel,
              ),
            ),
            const SizedBox(height: 16),
            Text('Ciclo de Facturación', style: sectionTitleStyle),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'MONTHLY',
                  label: Text('Mensual'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment(
                  value: 'ANNUAL',
                  label: Text('Anual (Ahorro)'),
                  icon: Icon(Icons.verified_outlined),
                ),
              ],
              selected: {_billingCycle},
              onSelectionChanged: (selection) {
                setState(() {
                  _billingCycle = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Método de Pago', style: sectionTitleStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'CARD',
                  child: Text('Tarjeta Corporativa / Crédito / Débito'),
                ),
                DropdownMenuItem(
                  value: 'YAPE',
                  child: Text('Billetera Digital (Yape Empresas)'),
                ),
                DropdownMenuItem(
                  value: 'BANK_TRANSFER',
                  child: Text('Transferencia Bancaria CCI'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),
            if (_paymentMethod == 'CARD') ...[
              const SizedBox(height: 14),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta (16 dígitos)',
                  hintText: '4557880011223344',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cardExpiryController,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento (MM/YY)',
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: statusColors.success,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: () {
                  final galleryId =
                      int.tryParse(_galleryIdController.text.trim()) ?? 1;
                  final unitCount =
                      int.tryParse(_unitCountController.text.trim()) ?? 1;

                  Navigator.pop(
                    context,
                    SubscriptionCheckoutResult(
                      galleryId: galleryId,
                      monitoredUnitCount: unitCount,
                      planId: widget.plan.id,
                      billingCycle: _billingCycle,
                      paymentMethod: _paymentMethod,
                      cardNumber: _paymentMethod == 'CARD'
                          ? _cardNumberController.text.trim()
                          : null,
                      cardExpiry: _paymentMethod == 'CARD'
                          ? _cardExpiryController.text.trim()
                          : null,
                    ),
                  );
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text(
                  'Confirmar Pago y Activar Suscripción',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}