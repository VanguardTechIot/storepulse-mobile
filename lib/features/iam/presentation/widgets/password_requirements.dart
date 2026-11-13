import 'package:flutter/material.dart';
import '../../domain/password_policy.dart';

class PasswordRequirements extends StatelessWidget {
  final TextEditingController controller;

  const PasswordRequirements({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final evaluation = PasswordPolicy.evaluate(value.text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Requirement(
              label: 'Al menos ${PasswordPolicy.minimumLength} caracteres',
              satisfied: evaluation.hasMinimumLength,
            ),
            _Requirement(
              label: 'Al menos un número',
              satisfied: evaluation.hasNumber,
            ),
            if (!evaluation.withinMaximumLength)
              _Requirement(
                label: 'Máximo ${PasswordPolicy.maximumLength} caracteres',
                satisfied: false,
              ),
          ],
        );
      },
    );
  }
}

class _Requirement extends StatelessWidget {
  final String label;
  final bool satisfied;

  const _Requirement({required this.label, required this.satisfied});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = satisfied
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
