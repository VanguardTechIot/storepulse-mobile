import 'package:flutter/material.dart';
import '../profiles_validators.dart';

Future<String?> showProfilePhotoDialog(
  BuildContext context, {
  String? currentUrl,
}) => showDialog<String>(
  context: context,
  builder: (_) => _ProfilePhotoDialog(currentUrl: currentUrl),
);

class _ProfilePhotoDialog extends StatefulWidget {
  final String? currentUrl;

  const _ProfilePhotoDialog({this.currentUrl});

  @override
  State<_ProfilePhotoDialog> createState() => _ProfilePhotoDialogState();
}

class _ProfilePhotoDialogState extends State<_ProfilePhotoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _urlController = TextEditingController(text: widget.currentUrl);

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _urlController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.add_a_photo_outlined),
      title: const Text('Foto de perfil'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _urlController,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          validator: ProfilesValidators.photoUrl,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Enlace de la imagen',
            helperText: 'Imagen JPG o PNG publicada en http(s).',
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
