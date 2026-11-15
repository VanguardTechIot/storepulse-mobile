import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/progress_filled_button.dart';
import '../domain/sign_in_command.dart';
import 'authentication_state.dart';
import 'authentication_view_model.dart';
import 'iam_error_messages.dart';
import 'iam_validators.dart';
import 'session_view_model.dart';
import 'widgets/iam_header.dart';
import 'widgets/password_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthenticationViewModel>().signIn(
      SignInCommand(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => getIt<AuthenticationViewModel>(),
      child: BlocConsumer<AuthenticationViewModel, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSucceeded) {
            context.read<SessionViewModel>().authenticated(state.user);
          } else if (state is AuthenticationFailed) {
            showAppSnackBar(context, state.error.message, error: true);
          }
        },
        builder: (context, state) {
          final submitting = state is AuthenticationSubmitting;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const IamHeader(
                          title: 'StorePulse Mobile',
                          subtitle:
                              'Monitoreo IoT para Galerías Comerciales y Locales',
                        ),
                        const SizedBox(height: 32),
                        Card.outlined(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: AutofillGroup(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Iniciar sesión',
                                      style: textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _emailController,
                                      enabled: !submitting,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      textInputAction: TextInputAction.next,
                                      validator: IamValidators.email,
                                      decoration: const InputDecoration(
                                        labelText: 'Correo electrónico',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    PasswordField(
                                      controller: _passwordController,
                                      label: 'Contraseña',
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      validator: IamValidators.password,
                                      onFieldSubmitted: (_) => _submit(context),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: submitting
                                            ? null
                                            : () => Navigator.pushNamed(
                                                context,
                                                AppRoutes.forgotPassword,
                                              ),
                                        child: const Text(
                                          '¿Olvidaste tu contraseña?',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ProgressFilledButton(
                                      label: 'Ingresar',
                                      icon: Icons.login,
                                      inProgress: submitting,
                                      onPressed: () => _submit(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '¿Administras una galería?',
                              style: textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: submitting
                                  ? null
                                  : () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.signUp,
                                    ),
                              child: const Text('Crea tu cuenta'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
