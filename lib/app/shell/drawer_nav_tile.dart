import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Single navigation tile inside the Drawer featuring glowing applet icon badge.
///
/// Designed to provide visual feedback with tonal background and edge indicator on selection.
class DrawerNavigationTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerNavigationTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? AppColors.carbonCardElevated : Colors.transparent;

    final borderColor =
        isSelected ? accentColor.withValues(alpha: 0.4) : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // Glowing applet icon badge container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
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
