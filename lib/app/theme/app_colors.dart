import 'package:flutter/material.dart';

/// Centralized color palette for the "BO2 Tactical HUD" / Dark Luxury Industrial aesthetic.
///
/// Tweak values here to adjust OLED background depth, tactical glow accents, or card colors.
abstract final class AppColors {
  // --- Core OLED Base & Carbon Surfaces ---
  /// Deep black base for maximum contrast on OLED displays.
  static const Color oledBase = Color(0xFF0A0A0A);

  /// Primary scaffold background (#121212).
  static const Color scaffoldBackground = Color(0xFF121212);

  /// Elevated surface for AppBar, Drawer, and Navigation elements.
  static const Color charcoalGlass = Color(0xFF161616);

  /// Primary surface for bento cards and form panels.
  static const Color carbonCard = Color(0xFF1C1C1E);

  /// Highlighted surface for elevated interactive elements.
  static const Color carbonCardElevated = Color(0xFF242426);

  // --- Hairline Borders & Dividers ---
  /// Subtle 12% white hairline divider.
  static const Color hairlineBorder = Color(0x1FFFFFFF);

  /// Active card border (18% white) for subtle edge definition.
  static const Color borderSubtle = Color(0x2EFFFFFF);

  // --- Tactical Applet Accents ---
  /// Amber gold accent for Verbrandingsattest / primary actions.
  static const Color amberGold = Color(0xFFFFB300);

  /// Translucent amber gold glow for focused states and halos.
  static const Color amberGoldGlow = Color(0x33FFB300);

  /// Terracotta accent for Reinigingsattest.
  static const Color terracotta = Color(0xFFF4511E);

  /// Translucent terracotta glow.
  static const Color terracottaGlow = Color(0x33F4511E);

  /// Slate accent for Keuringsrapport.
  static const Color slate = Color(0xFF546E7A);

  /// Translucent slate glow.
  static const Color slateGlow = Color(0x33546E7A);

  /// Steel/muted gray for general telemetry and measurement readings.
  static const Color steelMuted = Color(0xFF9E9E9E);

  // --- Status & Validation Alerts ---
  /// High-visibility red for errors, negative findings, or failed VEKA transmissions.
  static const Color errorRed = Color(0xFFFF5252);

  /// Vibrant green for passed checks, conform results, and locked drafts.
  static const Color successGreen = Color(0xFF69F0AE);

  /// Amber warning for incomplete sections or pending actions.
  static const Color warningOrange = Color(0xFFFF9800);

  // --- Typography Tokens ---
  /// High-contrast primary text for headers and input fields.
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Secondary muted text for labels, descriptions, and timestamps.
  static const Color textSecondary = Color(0xFFA1A1A6);

  /// Muted tertiary text for disabled hints and hairline captions.
  static const Color textMuted = Color(0xFF6E6E73);
}
