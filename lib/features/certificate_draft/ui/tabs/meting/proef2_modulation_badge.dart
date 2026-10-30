import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Stacked dual-status modulation badge for Proef II (Eindmeting).
///
/// Features:
/// - Vertically stacked 'L' (Laaglast) above and 'H' (Hooglast) below.
/// - Highlights the active modulation mode in antique gold.
/// - Shows a crisp checkmark (✓) next to each letter when that modulation has captured data.
/// - Shows chevron indicating whether the sub-tier modulation selector is expanded.
/// - Maintains constant dimensions whether selected or unselected to prevent layout shift.
class Proef2ModulationBadge extends StatelessWidget {
  final bool isLaaglast;
  final bool isSubMenuExpanded;
  final bool hasLaagData;
  final bool hasHoogData;
  final bool isSelected;

  const Proef2ModulationBadge({
    super.key,
    required this.isLaaglast,
    required this.isSubMenuExpanded,
    required this.hasLaagData,
    required this.hasHoogData,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool anyHasData = hasLaagData || hasHoogData;

    final Color badgeBg = isSelected
        ? AppColors.amberGold.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.04);

    final Color badgeBorder = isSelected
        ? AppColors.amberGoldBorder.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.10);

    // Letter 'L' (Laaglast) styling:
    // Stays gold amber with checkmark when a measurement is taken, even on Proef I.
    final bool lIsActive = isSelected && isLaaglast;
    final Color colorL;
    final FontWeight weightL;
    if (lIsActive) {
      colorL = AppColors.amberGold;
      weightL = FontWeight.w800;
    } else if (hasLaagData) {
      colorL = AppColors.amberGold;
      weightL = FontWeight.w700;
    } else {
      colorL = const Color(0xFF555555);
      weightL = FontWeight.w500;
    }

    // Letter 'H' (Hooglast) styling:
    // Stays gold amber with checkmark when a measurement is taken, even on Proef I.
    final bool hIsActive = isSelected && !isLaaglast;
    final Color colorH;
    final FontWeight weightH;
    if (hIsActive) {
      colorH = AppColors.amberGold;
      weightH = FontWeight.w800;
    } else if (hasHoogData) {
      colorH = AppColors.amberGold;
      weightH = FontWeight.w700;
    } else {
      colorH = const Color(0xFF555555);
      weightH = FontWeight.w500;
    }

    final Color chevronColor = isSelected
        ? AppColors.amberGold
        : (anyHasData
            ? AppColors.antiqueGold.withValues(alpha: 0.7)
            : const Color(0xFF555555));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: badgeBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: L (Laaglast)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                    child: Text(
                      'L',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        height: 1.1,
                        fontWeight: weightL,
                        color: colorL,
                      ),
                    ),
                  ),
                  if (hasLaagData) ...[
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: AppColors.amberGold,
                    ),
                  ] else if (anyHasData) ...[
                    const SizedBox(width: 13),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              // Bottom: H (Hooglast)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                    child: Text(
                      'H',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        height: 1.1,
                        fontWeight: weightH,
                        color: colorH,
                      ),
                    ),
                  ),
                  if (hasHoogData) ...[
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: AppColors.amberGold,
                    ),
                  ] else if (anyHasData) ...[
                    const SizedBox(width: 13),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(width: 3),
          Icon(
            isSubMenuExpanded
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded,
            size: 12,
            color: chevronColor,
          ),
        ],
      ),
    );
  }
}
