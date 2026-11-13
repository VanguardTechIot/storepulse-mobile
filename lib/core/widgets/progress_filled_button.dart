import 'package:flutter/material.dart';

class ProgressFilledButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool inProgress;
  final VoidCallback? onPressed;

  const ProgressFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.inProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
    );
    final action = inProgress ? null : onPressed;

    if (icon == null) {
      return FilledButton(
        style: style,
        onPressed: action,
        child: inProgress ? indicator : Text(label),
      );
    }
    return FilledButton.icon(
      style: style,
      onPressed: action,
      icon: inProgress ? indicator : Icon(icon),
      label: Text(label),
    );
  }
}
