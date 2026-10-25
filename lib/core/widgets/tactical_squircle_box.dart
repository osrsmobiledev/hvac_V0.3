import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Centralized theme calculator for tactical squircle tiles and buttons.
///
/// Ensures a consistent visual hierarchy across homepage bento tiles,
/// drawer navigation items, and action buttons.
abstract final class TacticalTileTheme {
  /// Blends an accent tint over [AppColors.carbonCard] to create the signature OLED tonal glow.
  static Color tonalSurface(
    Color accentColor, {
    bool isSelected = false,
    bool isEnabled = true,
  }) {
    if (!isEnabled) {
      return const Color(0xFF141414);
    }
    final alpha = isSelected ? 0.16 : 0.08;
    return Color.alphaBlend(
      accentColor.withValues(alpha: alpha),
      AppColors.carbonCard,
    );
  }

  /// Calculates the active rim border color based on enabled and selected states.
  static Color rimBorder(
    Color borderColor,
    Color accentColor, {
    bool isSelected = false,
    bool isEnabled = true,
  }) {
    if (!isEnabled) {
      return Colors.white.withValues(alpha: 0.10);
    }
    if (isSelected) {
      return accentColor;
    }
    return borderColor;
  }

  /// Determines the active glyph or icon color.
  static Color iconColor(
    Color accentColor, {
    bool isEnabled = true,
  }) {
    return isEnabled ? accentColor : Colors.white24;
  }
}

/// Reusable Black Ops / Tactical squircle tile box.
///
/// Features:
/// - Signature tonal surface: blends 8% [accentColor] tint over [AppColors.carbonCard]
///   (elevates to 16% tint when [isSelected] is true).
/// - Crisp colored rim border with customizable width and radius.
/// - Tactile ink ripple with haptic click feedback when tapped.
/// - Recessed greyed-out appearance when [isEnabled] is false.
/// - Flexible sizing: explicit [width]/[height] or natural fill.
class TacticalSquircleBox extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final Color accentColor;
  final Color borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double borderWidth;
  final double iconSize;
  final bool isEnabled;
  final bool isSelected;
  final VoidCallback? onTap;

  const TacticalSquircleBox({
    super.key,
    this.icon,
    this.child,
    required this.accentColor,
    required this.borderColor,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.borderWidth = 1.2,
    this.iconSize = 24.0,
    this.isEnabled = true,
    this.isSelected = false,
    this.onTap,
  });

  void _handleTap() {
    HapticFeedback.selectionClick();
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = TacticalTileTheme.tonalSurface(
      accentColor,
      isSelected: isSelected,
      isEnabled: isEnabled,
    );

    final activeBorder = TacticalTileTheme.rimBorder(
      borderColor,
      accentColor,
      isSelected: isSelected,
      isEnabled: isEnabled,
    );

    final glyphColor = TacticalTileTheme.iconColor(
      accentColor,
      isEnabled: isEnabled,
    );

    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: activeBorder,
        width: isSelected ? borderWidth + 0.3 : borderWidth,
      ),
    );

    final content = Center(
      child: child ??
          (icon != null
              ? Icon(
                  icon,
                  color: glyphColor,
                  size: iconSize,
                )
              : const SizedBox.shrink()),
    );

    Widget result = Container(
      width: width,
      height: height,
      decoration: boxDecoration,
      child: content,
    );

    final canInteract = isEnabled && onTap != null;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: canInteract
          ? InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: accentColor.withValues(alpha: 0.16),
              highlightColor: accentColor.withValues(alpha: 0.08),
              onTap: _handleTap,
              child: result,
            )
          : result,
    );
  }
}
