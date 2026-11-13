import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/progress_filled_button.dart';
import '../domain/sign_up_command.dart';
import 'authentication_state.dart';
import 'authentication_view_model.dart';
import 'iam_error_messages.dart';
import 'iam_validators.dart';
import 'session_view_model.dart';
import 'widgets/password_field.dart';
import 'widgets/password_requirements.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthenticationViewModel>().signUp(
      SignUpCommand(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            appBar: AppBar(title: const Text('Crear cuenta')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card.filled(
                          color: colorScheme.secondaryContainer,
                          child: ListTile(
                            leading: Icon(
                              Icons.domain,
                              color: colorScheme.onSecondaryContainer,
                            ),
                            title: Text(
                              'Administrador de Galería',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            subtitle: Text(
                              'Los inquilinos reciben su acceso desde la '
                              'administración de su galería.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _fullNameController,
                          enabled: !submitting,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          textInputAction: TextInputAction.next,
                          maxLength: IamValidators.fullNameMaxLength,
                          validator: IamValidators.fullName,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: !submitting,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
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
                          label: 'Crear cuenta',
                          icon: Icons.person_add_alt_1,
                          inProgress: submitting,
                          onPressed: () => _submit(context),
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
