import 'package:flutter_test/flutter_test.dart';
import 'package:storepulse_mobile/core/di/dependency_injection.dart';
import 'package:storepulse_mobile/main.dart';

void main() {
  setUpAll(() {
    setupDependencyInjection();
  });

  testWidgets('StorePulseApp renders LoginPage on startup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StorePulseApp());
    expect(find.text('StorePulse Mobile'), findsOneWidget);
  });
}