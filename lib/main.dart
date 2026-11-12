import 'package:flutter/material.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_them.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/main/presentation/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  runApp(const StorePulseApp());
}

class StorePulseApp extends StatelessWidget {
  const StorePulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StorePulse Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}