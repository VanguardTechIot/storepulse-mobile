import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? colorScheme.errorContainer : null,
        content: Text(
          message,
          style: error ? TextStyle(color: colorScheme.onErrorContainer) : null,
        ),
      ),
    );
}
