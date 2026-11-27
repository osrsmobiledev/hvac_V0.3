import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Tactical selectable checklist tile for Tab 5 (Reiniging en controle).
///
/// Features:
/// - Minimum 48px touch target for gloved/field use.
/// - Charcoal resting surface with subtle hairline border.
/// - Illuminated `amberGold` check icon and border when active.
/// - Multi-line text wrapping without truncation for long Flemish labels.
class ReinigingChecklistTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isError;
  final VoidCallback onTap;

  const ReinigingChecklistTile({
    super.key,
    required this.label,
    required this.isSelected,
    this.isError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.08),
            AppColors.charcoalGlass,
          )
        : isError
            ? Color.alphaBlend(
                AppColors.errorRed.withValues(alpha: 0.04),
                const Color(0xFF0C0C0C),
              )
            : const Color(0xFF0C0C0C);

    final borderColor = isSelected
        ? AppColors.amberGoldBorder
        : isError
            ? AppColors.errorRed
            : Colors.white.withValues(alpha: 0.14);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(10.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 11.0,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 20.0,
                  color: isSelected
                      ? AppColors.amberGold
                      : isError
                          ? AppColors.errorRed
                          : AppColors.textMuted,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
