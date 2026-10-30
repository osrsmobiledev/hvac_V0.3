import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Secondary sub-slot modulation toggle (Laaglast vs Hooglast) under Proef II.
class SubSlotTab extends StatelessWidget {
  final String label;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasData;

  const SubSlotTab({
    super.key,
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
    this.hasData = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.antiqueGold.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color:
                  isSelected ? AppColors.amberGoldBorder : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF616161),
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_rounded,
                      size: 12.0,
                      color: isSelected
                          ? AppColors.amberGold
                          : const Color(0xFF7A6A3A),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                badge,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.amberGold
                      : const Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard full-width action button used in the flue-gas measurement ribbon.
class SlotActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const SlotActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
