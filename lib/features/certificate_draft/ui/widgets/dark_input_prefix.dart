import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Centralized reusable prefix component for input boxes across all workflow tabs.
///
/// Features:
/// - Single source of truth for text and icon prefixes (+32, BE, #, icons).
/// - Unified typography: 15px, FontWeight.w600, antique gold color palette.
/// - Matches standard M3 dark mode desaturation: uses [AppColors.antiqueGold].
/// - Automatically dims color to 45% alpha when [isMuted] is true (readOnly state).
class DarkInputPrefix extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool isMuted;

  const DarkInputPrefix.text(
    this.text, {
    super.key,
    this.isMuted = false,
  }) : icon = null;

  const DarkInputPrefix.icon(
    this.icon, {
    super.key,
    this.isMuted = false,
  }) : text = null;

  /// The standard prefix text style used across all workflow input boxes.
  static TextStyle style({bool isMuted = false}) => TextStyle(
        color: isMuted
            ? AppColors.antiqueGold.withValues(alpha: 0.45)
            : AppColors.antiqueGold,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final color = isMuted
        ? AppColors.antiqueGold.withValues(alpha: 0.45)
        : AppColors.antiqueGold;

    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 14.0, right: 10.0),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 1.0),
      child: Text(
        text ?? '',
        style: style(isMuted: isMuted),
      ),
    );
  }
}
