import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/progress_filled_button.dart';
import '../domain/password_recovery.dart';
import '../domain/password_reset_code.dart';
import '../domain/request_password_reset_command.dart';
import '../domain/reset_password_command.dart';
import 'iam_error_messages.dart';
import 'iam_validators.dart';
import 'password_recovery_state.dart';
import 'password_recovery_view_model.dart';
import 'widgets/password_field.dart';
import 'widgets/password_requirements.dart';

class ResetPasswordPage extends StatefulWidget {
  final PasswordRecovery recovery;

  const ResetPasswordPage({super.key, required this.recovery});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late PasswordRecovery _recovery = widget.recovery;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<PasswordRecoveryViewModel>().resetPassword(
      ResetPasswordCommand(
        email: _recovery.email,
        code: _codeController.text,
        newPassword: _passwordController.text,
      ),
    );
  }

  void _resend(BuildContext context) {
    _codeController.clear();
    context.read<PasswordRecoveryViewModel>().requestPasswordReset(
      RequestPasswordResetCommand(email: _recovery.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => getIt<PasswordRecoveryViewModel>(),
      child: BlocConsumer<PasswordRecoveryViewModel, PasswordRecoveryState>(
        listener: (context, state) {
          if (state is PasswordResetCompleted) {
            showAppSnackBar(
              context,
              'Contraseña actualizada. Inicia sesión con tu nueva contraseña.',
            );
            Navigator.popUntil(context, ModalRoute.withName(AppRoutes.signIn));
          } else if (state is PasswordResetCodeSent) {
            setState(() => _recovery = state.recovery);
            showAppSnackBar(context, 'Te enviamos un nuevo código.');
          } else if (state is PasswordRecoveryFailed) {
            showAppSnackBar(context, state.error.message, error: true);
          }
        },
        builder: (context, state) {
          final submitting = state is PasswordRecoverySubmitting;
          final expiresAt = TimeOfDay.fromDateTime(
            _recovery.expiresAt,
          ).format(context);

          return Scaffold(
            appBar: AppBar(title: const Text('Nueva contraseña')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card.filled(
                        color: colorScheme.secondaryContainer,
                        child: ListTile(
                          leading: Icon(
                            Icons.mark_email_read_outlined,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          title: Text(
                            _recovery.email,
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          subtitle: Text(
                            'Si la cuenta existe, recibirás un código que vence '
                            'a las $expiresAt.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codeController,
                        enabled: !submitting,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        textInputAction: TextInputAction.next,
                        maxLength: PasswordResetCode.length,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: IamValidators.resetCode,
                        decoration: const InputDecoration(
                          labelText: 'Código de verificación',
                          prefixIcon: Icon(Icons.pin_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PasswordField(
                        controller: _passwordController,
                        label: 'Nueva contraseña',
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.next,
                        validator: IamValidators.newPassword,
                      ),
                      const SizedBox(height: 8),
                      PasswordRequirements(controller: _passwordController),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _confirmationController,
                        label: 'Confirmar contraseña',
                        validator: IamValidators.confirmation(
                          () => _passwordController.text,
                        ),
                        onFieldSubmitted: (_) => _submit(context),
                      ),
                      const SizedBox(height: 24),
                      ProgressFilledButton(
                        label: 'Restablecer contraseña',
                        icon: Icons.check,
                        inProgress: submitting,
                        onPressed: () => _submit(context),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: submitting ? null : () => _resend(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reenviar código'),
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
