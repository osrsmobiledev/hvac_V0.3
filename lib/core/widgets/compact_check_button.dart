// File: lib/core/widgets/compact_check_button.dart
// Responsibility: Private/compact check button item used for high-density slot toggles.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

class CompactCheckButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeBorder;
  final Color activeTextColor;
  final VoidCallback onTap;

  const CompactCheckButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeBorder,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: isActive ? Border.all(color: activeBorder, width: 1.0) : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeTextColor : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
