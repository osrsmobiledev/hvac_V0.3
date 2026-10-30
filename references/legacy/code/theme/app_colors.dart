// File: lib/core/theme/app_colors.dart
// Line Count: ~25 lines
// Responsibility: Centralized Single Source of Truth for the BO2 Dark Gold theme

import 'package:flutter/material.dart';

class AppColors {
  // TUNE HERE [UI/UX]: Core OLED Base & Surfaces
  static const Color oledBase = Color(0xFF0A0A0A);
  static const Color charcoalGlass = Color(0xFF161616);
  static const Color scaffoldBackground = Color(0xFF121212);

  // TUNE HERE [UI/UX]: Accent & Focus Elements
  static const Color goldAccent = Color(0xFFFFB300);

  // TUNE HERE [UI/UX]: Validation Alerts (Government API Status)
  static const Color errorRed = Color(0xFFFF5252);
  static const Color lockedGreen = Color(0xFF69F0AE);

  // TUNE HERE [UI/UX]: Applet Specific Brand Colors
  static const Color appletCombustion = Color(0xFFFFB300);
  static const Color appletCleaning = Color(0xFFF4511E);
  static const Color appletInspection = Color(0xFF546E7A);
  static const Color appletMeasurement = Color(0xFF9E9E9E);
}
