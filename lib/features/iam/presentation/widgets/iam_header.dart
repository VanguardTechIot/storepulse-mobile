import 'package:flutter/material.dart';

class IamHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const IamHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (icon != null)
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Icon(icon, size: 40),
          )
        else
          Image.asset(
            'assets/images/storepulse_logo.png',
            width: 84,
            height: 84,
            fit: BoxFit.contain,
            semanticLabel: 'Logo de StorePulse',
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
