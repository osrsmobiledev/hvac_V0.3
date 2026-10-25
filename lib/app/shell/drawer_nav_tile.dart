import 'package:flutter/material.dart';
import 'package:hvac_app/core/widgets/tactical_squircle_box.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Single navigation tile inside the Drawer matching the owner's preferred theme.
///
/// Features:
/// - Follows the signature applet accent color when selected.
/// - Left indicator bar glows with the applet's accent color.
/// - Background adopts a subtle tonal tint of the accent color.
/// - Libron font typography.
class DrawerNavigationTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerNavigationTile({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tonal background tint matching the applet's accent color when selected
    final backgroundColor = isSelected
        ? Color.alphaBlend(
            accentColor.withValues(alpha: 0.12),
            AppColors.carbonCardElevated,
          )
        : Colors.transparent;

    return Container(
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left indicator bar glowing with the applet's accent color
                Container(
                  width: 4,
                  color: isSelected ? accentColor : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        // Squircle icon container using centralized TacticalSquircleBox
                        TacticalSquircleBox(
                          width: 42,
                          height: 42,
                          icon: icon,
                          accentColor: accentColor,
                          borderColor: borderColor,
                          borderRadius: 12,
                          iconSize: 22,
                          borderWidth: isSelected ? 1.5 : 1.2,
                          isSelected: isSelected,
                        ),
                        const SizedBox(width: 14),
                        // Label in Libron font
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary
                                      .withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
