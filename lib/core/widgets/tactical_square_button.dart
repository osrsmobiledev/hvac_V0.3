import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Reusable 40x40 (or customizable size) tactical square action button.
///
/// Features:
/// - Standard military/tactical aesthetics with 10px rounded corners and glowing border.
/// - Used for quick triggers such as QR scanning, barcode intake, and deletion.
/// - Supports enabled/disabled states with automatic dimmed opacity.
/// - Accessible with built-in [Tooltip].
class TacticalSquareButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color accentColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const TacticalSquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.accentColor = AppColors.amberGold,
    this.borderColor,
    this.backgroundColor,
    this.size = 40.0,
    this.iconSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final effectiveBorderColor = borderColor ??
        (isEnabled
            ? accentColor.withValues(alpha: 0.45)
            : Colors.white.withValues(alpha: 0.12));
    final effectiveBackgroundColor = backgroundColor ??
        (isEnabled
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.02));
    final effectiveIconColor = isEnabled ? accentColor : AppColors.textMuted;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        splashRadius: size / 2,
        onPressed: onPressed,
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: effectiveBorderColor,
              width: 1.0,
            ),
          ),
          child: Icon(
            icon,
            color: effectiveIconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
