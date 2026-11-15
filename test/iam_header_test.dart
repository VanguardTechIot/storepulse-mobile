import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storepulse_mobile/features/iam/presentation/widgets/iam_header.dart';

void main() {
  testWidgets('IamHeader renders the StorePulse brand logo by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IamHeader(
            title: 'StorePulse Mobile',
            subtitle: 'Monitoreo IoT',
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de StorePulse'), findsOneWidget);
    expect(find.byIcon(Icons.sensors), findsNothing);
  });

  testWidgets('IamHeader renders the explicit icon when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IamHeader(
            icon: Icons.lock_reset,
            title: 'Recuperar contraseña',
            subtitle: 'Ingresa tu correo',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
