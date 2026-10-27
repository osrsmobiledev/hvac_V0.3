import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Unified 3-way sliding category bar for primary fuel selection (Gas, Liquid, Solid).
class TacticalFuelCategoryBar extends StatelessWidget {
  final String selectedCategory; // 'gas', 'vloeibaar', 'vast'
  final ValueChanged<String> onCategoryChanged;

  const TacticalFuelCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('gas', AppDictionary.fuelGasShort, Icons.local_fire_department_rounded),
      ('vloeibaar', AppDictionary.fuelLiquidShort, Icons.water_drop_rounded),
      ('vast', AppDictionary.fuelSolidShort, Icons.forest_rounded),
    ];

    final int selectedIndex =
        categories.indexWhere((c) => c.$1 == selectedCategory);
    final int activeIndex = selectedIndex >= 0 ? selectedIndex : 0;
    // Map index 0, 1, 2 to Alignment -1.0, 0.0, 1.0
    final double alignX = -1.0 + (activeIndex * 1.0);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          // Sliding illuminated amber thumb
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment(alignX, 0.0),
            child: FractionallySizedBox(
              widthFactor: 1.0 / 3.0,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: AppColors.amberGold.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: AppColors.amberGoldBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amberGold.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3 interactive segments
          Row(
            children: categories.map((cat) {
              final bool isSelected = cat.$1 == selectedCategory;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onCategoryChanged(cat.$1);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.$3,
                            size: 16,
                            color: isSelected
                                ? AppColors.amberGold
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                cat.$2,
                                maxLines: 1,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontFamily: AppTheme.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A modern, unboxed tactical chip button for selecting fuel subtypes.
class TacticalOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TacticalOptionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amberGold.withValues(alpha: 0.18)
              : const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.amberGoldBorder
                : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
