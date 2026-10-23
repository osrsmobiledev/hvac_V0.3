import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Official Flutter Material 3 option button for Tab 2 (Start).
///
/// Features:
/// - Built with the official Flutter [OutlinedButton] (no reinvented gesture mechanics).
/// - Native Material 3 ripple and highlight on tap.
/// - Tactile haptic feedback on touch ([HapticFeedback.selectionClick]).
/// - Constant 1.0px hairline border and pill shape (BorderRadius.circular(26)).
/// - Tactical reticle indicator with gold pip when selected.
class ActivityOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Surface color: subtle antique-gold tonal blend over carbon when selected
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.08),
            const Color(0xFF141414),
          )
        : const Color(0xFF0C0C0C);

    final borderColor = isSelected
        ? AppColors.antiqueGold
        : Colors.white.withValues(alpha: 0.18);

    return OutlinedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        splashFactory: InkSparkle.splashFactory,
        foregroundColor: Colors.white,
      ),
      child: Row(
        children: [
          // Tactical HUD Selector Pip (Reticle)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.antiqueGold : Colors.white30,
                width: 1.4,
              ),
              color: isSelected
                  ? AppColors.antiqueGold.withValues(alpha: 0.16)
                  : Colors.transparent,
            ),
            child: Center(
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.antiqueGold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title with smooth text styling
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
