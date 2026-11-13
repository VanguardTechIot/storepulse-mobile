import 'package:flutter/material.dart';
import '../../../../core/widgets/progress_filled_button.dart';
import '../../domain/profile.dart';
import '../../domain/update_profile_command.dart';
import '../profiles_validators.dart';

class ProfileDetailsForm extends StatefulWidget {
  final Profile profile;
  final bool saving;
  final ValueChanged<UpdateProfileCommand> onSubmit;

  const ProfileDetailsForm({
    super.key,
    required this.profile,
    required this.saving,
    required this.onSubmit,
  });

  @override
  State<ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<ProfileDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  List<TextEditingController> get _controllers => [
    _firstNameController,
    _lastNameController,
    _emailController,
    _phoneController,
  ];

  @override
  void initState() {
    super.initState();
    _reset();
    for (final controller in _controllers) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void didUpdateWidget(covariant ProfileDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.profile, widget.profile)) _reset();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _reset() {
    _firstNameController.text = widget.profile.firstName;
    _lastNameController.text = widget.profile.lastName;
    _emailController.text = widget.profile.email;
    _phoneController.text = widget.profile.phoneNumber ?? '';
  }

  bool get _isDirty =>
      _firstNameController.text.trim() != widget.profile.firstName ||
      _lastNameController.text.trim() != widget.profile.lastName ||
      _emailController.text.trim().toLowerCase() != widget.profile.email ||
      _phoneController.text.trim() != (widget.profile.phoneNumber ?? '');

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(
      UpdateProfileCommand(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dirty = _isDirty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos personales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _firstNameController,
            enabled: !widget.saving,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: Profile.nameMaxLength,
            validator: ProfilesValidators.firstName,
            decoration: const InputDecoration(
              labelText: 'Nombres',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            enabled: !widget.saving,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: Profile.nameMaxLength,
            validator: ProfilesValidators.lastName,
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            enabled: !widget.saving,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: ProfilesValidators.email,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              helperText: 'También es tu correo para iniciar sesión.',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            enabled: !widget.saving,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: ProfilesValidators.phoneNumber,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Teléfono (opcional)',
              hintText: '+51 987 654 321',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ProgressFilledButton(
            label: 'Guardar cambios',
            icon: Icons.save_outlined,
            inProgress: widget.saving,
            onPressed: dirty ? _submit : null,
          ),
          if (dirty && !widget.saving) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(_reset),
              child: const Text('Descartar cambios'),
            ),
          ],
        ],
      ),
    );
  }
}
