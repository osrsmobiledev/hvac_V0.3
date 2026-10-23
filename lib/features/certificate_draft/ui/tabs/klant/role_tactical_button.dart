import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Official Flutter Material 3 tactical selection button for customer role (Eigenaar / Huurder).
///
/// Features:
/// - Built with the official Flutter [OutlinedButton] (no reinvented gesture mechanics).
/// - Native Material 3 ripple and highlight on tap.
/// - Tactile haptic feedback on touch ([HapticFeedback.selectionClick]).
/// - Constant 1.0px hairline border and 8px rounded corners.
/// - Tactical indicator pip in antique gold when selected.
class RoleTacticalButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleTacticalButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.10),
            AppColors.charcoalGlass,
          )
        : AppColors.charcoalGlass;

    final borderColor =
        isSelected ? AppColors.antiqueGold : AppColors.goldHairline;

    return OutlinedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        splashFactory: InkSparkle.splashFactory,
        foregroundColor:
            isSelected ? AppColors.antiqueGold : AppColors.textSecondary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tactical indicator pip
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.antiqueGold : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.antiqueGold : AppColors.textMuted,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected ? AppColors.antiqueGold : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
