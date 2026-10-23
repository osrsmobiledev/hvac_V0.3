import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Global theme definition for the HVAC application.
///
/// Implements the owner's preferred "Dark Luxury Industrial" aesthetic:
/// - Custom "Libron" typography throughout the application.
/// - Deep #0E0E0E OLED background.
/// - 28px bento squircle card borders with signature colored rims.
/// - Golden hairline dividers and dark tonal surfaces.
abstract final class AppTheme {
  /// Corner radius for Bento Squircle cards throughout the applets.
  static const double bentoCornerRadius = 28.0;

  /// Default font family bundled in assets/fonts/.
  static const String fontFamily = 'Libron';

  /// Standard squircle card border shape with hairline outline.
  static final ShapeBorder bentoSquircleShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(bentoCornerRadius),
    side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
  );

  /// Constructs the global ThemeData using the preferred theme tokens.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
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
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
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
        color: AppColors.goldHairline,
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
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.goldHairline, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textMuted,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      textTheme: ThemeData.dark()
          .textTheme
          .apply(
            fontFamily: fontFamily,
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          )
          .copyWith(
            headlineMedium: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            titleLarge: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            titleMedium: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.4,
            ),
            bodyMedium: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            labelSmall: const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}
