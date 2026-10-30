import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Official Flutter Material 3 option card for Tab 2 (Start).
///
/// Features:
/// - Built with official Flutter [OutlinedButton] for standard ripple mechanics.
/// - Tactile haptic feedback on touch ([HapticFeedback.selectionClick]).
/// - Tactical geometry with 12px squircle radius matching DarkInputBox.
/// - Glowing amber-gold indicator pip and illuminated border when selected.
/// - Single-line auto-scaled typography matching the crisp 'Brandstof' label style.
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
    // Subtle antique-gold tonal blend over dark base when selected
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            AppColors.antiqueGold.withValues(alpha: 0.08),
            const Color(0xFF141414),
          )
        : const Color(0xFF0C0C0C);

    // Muted, non-glaring amber/antique gold border when selected (#8A6A1D), hairline when unselected
    final borderColor = isSelected
        ? AppColors.amberGoldBorder
        : Colors.white.withValues(alpha: 0.16);

    return OutlinedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: isSelected ? 1.2 : 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        splashFactory: InkSparkle.splashFactory,
        foregroundColor: Colors.white,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
