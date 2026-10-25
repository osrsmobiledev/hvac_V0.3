import 'package:flutter/material.dart';

/// Centralized color palette for the "BO2 Tactical HUD" / Dark Luxury Industrial aesthetic.
///
/// Matches the owner's preferred theme references (Gold, Terracotta, Slate, Steel).
abstract final class AppColors {
  // --- Core OLED Base & Carbon Surfaces ---
  /// Deep black base for maximum contrast on OLED displays (#0E0E0E).
  static const Color oledBase = Color(0xFF0E0E0E);

  /// Primary scaffold background (#0E0E0E).
  static const Color scaffoldBackground = Color(0xFF0E0E0E);

  /// Elevated surface for AppBar, Drawer, and Navigation elements (#141414).
  static const Color charcoalGlass = Color(0xFF141414);

  /// Primary surface for bento cards and form panels (#1A1A1A).
  static const Color carbonCard = Color(0xFF1A1A1A);

  /// Highlighted surface for elevated interactive elements (#222222).
  static const Color carbonCardElevated = Color(0xFF222222);

  // --- Hairline Borders & Dividers ---
  /// Subtle white hairline divider.
  static const Color hairlineBorder = Color(0x1FFFFFFF);

  /// Golden hairline divider underneath persistent AppBar and Drawer edge.
  static const Color goldHairline = Color(0xFF554422);

  /// Active card border (18% white) for subtle edge definition.
  static const Color borderSubtle = Color(0x2EFFFFFF);

  // --- Tactical Applet Accents & Borders (Preferred Theme) ---
  /// Amber gold accent for Verbrandingsattest.
  static const Color amberGold = Color(0xFFFFB300);

  /// Toned-down antique gold accent for dark surfaces (M3 compliant desaturation).
  static const Color antiqueGold = Color(0xFFC89A3C);

  /// Antique gold border framing the Verbrandingsattest card.
  static const Color amberGoldBorder = Color(0xFF8A6A1D);

  /// Terracotta accent for Reinigingsattest.
  static const Color terracotta = Color(0xFFE65100);

  /// Brick red / terracotta border framing the Reinigingsattest card.
  static const Color terracottaBorder = Color(0xFF94341B);

  /// Slate accent for Keuringsrapport.
  static const Color slate = Color(0xFF546E7A);

  /// Steel slate border framing the Keuringsrapport card.
  static const Color slateBorder = Color(0xFF4A6572);

  /// Steel/muted gray for Meetrapport and general telemetry.
  static const Color steelMuted = Color(0xFF9E9E9E);

  /// Steel border framing the Meetrapport card (cool metallic steel, distinct from slate).
  static const Color steelBorder = Color(0xFF5A5D62);

  // --- Status & Validation Alerts ---
  /// High-visibility red for errors or negative findings.
  static const Color errorRed = Color(0xFFFF5252);

  /// Toned-down, rich tactical crimson for destructive buttons and surfaces (#B3261E).
  /// Eliminates glare on OLED displays while maintaining high contrast.
  static const Color destructiveRed = Color(0xFFB3261E);

  /// Vibrant green for passed checks and locked drafts.
  static const Color successGreen = Color(0xFF69F0AE);

  /// Amber warning for incomplete sections or pending actions.
  static const Color warningOrange = Color(0xFFFF9800);

  // --- Typography Tokens ---
  /// High-contrast primary text for headers and input fields (#F5F5F7).
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Secondary muted text for labels and timestamps (#A1A1A6).
  static const Color textSecondary = Color(0xFFA1A1A6);

  /// Muted tertiary text for section headers (#808080).
  static const Color textMuted = Color(0xFF808080);
}
