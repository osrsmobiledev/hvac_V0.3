import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Reusable tactical single-choice selection button with zero-jump error highlighting.
///
/// Visual States:
/// - Resting (Unselected): Dark container (#0C0C0C) with hairline white outline.
/// - Selected (Active): Amber-gold illuminated border and subtle gold background.
/// - Error ([isError] = true): Crisp red border ([AppColors.errorRed]) indicating
///   that selection is required before finalization.
class TacticalSelectButton extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isError;
  final VoidCallback onTap;
  final double height;
  final Widget? icon;

  const TacticalSelectButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    this.isError = false,
    required this.onTap,
    this.height = 50.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Background tinting
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.08),
            const Color(0xFF141414),
          )
        : isError
            ? Color.alphaBlend(
                AppColors.errorRed.withValues(alpha: 0.05),
                const Color(0xFF0C0C0C),
              )
            : const Color(0xFF0C0C0C);

    // Border: amber-gold when selected, red on error, subtle white otherwise
    final borderColor = isSelected
        ? AppColors.amberGoldBorder
        : isError
            ? AppColors.errorRed
            : Colors.white.withValues(alpha: 0.16);

    final borderWidth = isSelected || isError ? 1.2 : 1.0;

    return OutlinedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        splashFactory: InkSparkle.splashFactory,
        foregroundColor: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                subtitle!,
                maxLines: 1,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.white38,
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
