import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Global theme definition for the HVAC application.
///
/// Implements the "BO2 Tactical HUD" / Dark Luxury Industrial design language:
/// - Deep #121212 OLED background
/// - 28px bento squircle card borders
/// - Hairline dividers for razor-sharp industrial separation
/// - Amber gold accents with subtle tonal surfaces
abstract final class AppTheme {
  /// Corner radius for Bento Squircle cards throughout the applets.
  /// Edit this value to adjust the squircle roundness across all cards.
  static const double bentoCornerRadius = 28.0;

  /// Standard squircle card border shape with hairline outline.
  static final ShapeBorder bentoSquircleShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(bentoCornerRadius),
    side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
  );

  /// Constructs the global ThemeData using BO2 Tactical tokens.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amberGold,
        onPrimary: Colors.black,
        surface: AppColors.charcoalGlass,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorRed,
        onError: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoalGlass,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.carbonCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: bentoSquircleShape,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairlineBorder,
        thickness: 1.0,
        space: 1.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amberGold,
          foregroundColor: Colors.black,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.carbonCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.hairlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.hairlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.amberGold, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
