// File: lib/core/widgets/tactical_check_button.dart
// Responsibility: Reusable tactical button with haptic feedback, dark surface, and active glow.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable BO2 Tactical button with animated transitions and active border glow.
class TacticalCheckButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBackgroundColor;
  final Color activeBorderColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const TacticalCheckButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeBackgroundColor,
    required this.activeBorderColor,
    this.activeTextColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBackgroundColor : const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isActive
                ? activeBorderColor
                : Colors.white.withValues(alpha: 0.12),
            width: isActive ? 1.2 : 1.0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: isActive ? activeTextColor : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
