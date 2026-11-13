import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/dependency_injection.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/iam/domain/password_recovery.dart';
import 'features/iam/presentation/forgot_password_page.dart';
import 'features/iam/presentation/reset_password_page.dart';
import 'features/iam/presentation/session_state.dart';
import 'features/iam/presentation/session_view_model.dart';
import 'features/iam/presentation/sign_in_page.dart';
import 'features/iam/presentation/sign_up_page.dart';
import 'features/iam/presentation/splash_page.dart';
import 'features/main/presentation/main_page.dart';
import 'features/profiles_preferences/presentation/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  runApp(const StorePulseApp());
}

class StorePulseApp extends StatefulWidget {
  const StorePulseApp({super.key});

  @override
  State<StorePulseApp> createState() => _StorePulseAppState();
}

class _StorePulseAppState extends State<StorePulseApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onSessionChanged(BuildContext context, SessionState state) {
    final route = switch (state) {
      SessionAuthenticated() => AppRoutes.main,
      SessionUnauthenticated() => AppRoutes.signIn,
      SessionChecking() => null,
    };
    if (route == null) return;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SessionViewModel>(),
      child: MaterialApp(
        title: 'StorePulse Mobile',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        theme: AppTheme.light,
        builder: (context, child) =>
            BlocListener<SessionViewModel, SessionState>(
              listenWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType,
              listener: _onSessionChanged,
              child: child!,
            ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashPage(),
          AppRoutes.signIn: (_) => const SignInPage(),
          AppRoutes.signUp: (_) => const SignUpPage(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
          AppRoutes.resetPassword: (context) => ResetPasswordPage(
            recovery:
                ModalRoute.of(context)!.settings.arguments as PasswordRecovery,
          ),
          AppRoutes.main: (_) => const MainPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
        },
      ),
    );
  }
}
