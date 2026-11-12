import 'package:flutter/material.dart';
import 'status_colors.dart';

/// Material 3 theme of StorePulse Mobile, generated from a single seed color.

abstract final class AppTheme {

  static const Color _seed = Color(0xFF0EA5E9);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seed);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [StatusColors.light],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}