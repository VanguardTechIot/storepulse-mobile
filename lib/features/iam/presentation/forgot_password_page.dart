import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/progress_filled_button.dart';
import '../domain/request_password_reset_command.dart';
import 'iam_error_messages.dart';
import 'iam_validators.dart';
import 'password_recovery_state.dart';
import 'password_recovery_view_model.dart';
import 'widgets/iam_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<PasswordRecoveryViewModel>().requestPasswordReset(
      RequestPasswordResetCommand(email: _emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PasswordRecoveryViewModel>(),
      child: BlocConsumer<PasswordRecoveryViewModel, PasswordRecoveryState>(
        listener: (context, state) {
          if (state is PasswordResetCodeSent) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.resetPassword,
              arguments: state.recovery,
            );
          } else if (state is PasswordRecoveryFailed) {
            showAppSnackBar(context, state.error.message, error: true);
          }
        },
        builder: (context, state) {
          final submitting = state is PasswordRecoverySubmitting;
          return Scaffold(
            appBar: AppBar(title: const Text('Recuperar contraseña')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const IamHeader(
                        icon: Icons.lock_reset,
                        title: '¿Olvidaste tu contraseña?',
                        subtitle:
                            'Ingresa el correo de tu cuenta y te enviaremos un '
                            'código de 6 dígitos para crear una nueva.',
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        enabled: !submitting,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.send,
                        validator: IamValidators.email,
                        onFieldSubmitted: (_) => _submit(context),
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProgressFilledButton(
                        label: 'Enviar código',
                        icon: Icons.send_outlined,
                        inProgress: submitting,
                        onPressed: () => _submit(context),
                      ),
                    ],
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
