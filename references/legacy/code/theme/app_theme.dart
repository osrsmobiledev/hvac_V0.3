// File: lib/core/theme/app_theme.dart
// Line Count: ~22 lines
// Responsibility: Constructs the global ThemeData using BO2 tokens

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    // TUNE HERE [UI/UX]: Global typography and core Material 3 behavior
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldAccent,
        surface: AppColors.charcoalGlass,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoalGlass,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}