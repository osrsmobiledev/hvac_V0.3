// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/statutory_category_ribbon.dart
// Responsibility: Tactical horizontal pill filter ribbon for preset categories.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';

class StatutoryCategoryRibbon extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onCategorySelected;

  const StatutoryCategoryRibbon({
    super.key,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  static const _filters = [
    MapEntry('all', EindbeoordelingDictionary.filterCatAll),
    MapEntry('flue_vent', EindbeoordelingDictionary.filterCatFlueVent),
    MapEntry('fuel', EindbeoordelingDictionary.filterCatFuel),
    MapEntry('hydraulic', EindbeoordelingDictionary.filterCatHydraulic),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = _filters[i];
          final isActive = activeCategory == item.key;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onCategorySelected(item.key);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.amberGold.withValues(alpha: 0.18)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? AppColors.amberGoldBorder
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                item.value,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
