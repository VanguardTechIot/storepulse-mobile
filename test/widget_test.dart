import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storepulse_mobile/core/di/dependency_injection.dart';
import 'package:storepulse_mobile/main.dart';

void main() {
  setUpAll(() {
    setupDependencyInjection();
  });

  testWidgets('StorePulseApp shows the sign-in page without a stored session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StorePulseApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('StorePulse Mobile'), findsOneWidget);
  });
}
