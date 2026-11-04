import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../../domain/boiler_draft.dart';

/// Clean tactical cosmetic banner displaying the active installation fuel and classification.
///
/// Derived automatically from Tab 5 (Stooktoestel). When no fuel has been chosen yet,
/// displays an unobtrusive neutral placeholder instructing the technician to select
/// the fuel on Tab Stooktoestel.
class MetingFuelBanner extends StatelessWidget {
  final BoilerDraft boiler;

  const MetingFuelBanner({super.key, required this.boiler});

  @override
  Widget build(BuildContext context) {
    final bool hasFuel = boiler.fuelCategory.isNotEmpty;

    final (IconData icon, String fuelTitle) = switch (boiler.fuelCategory) {
      'vloeibaar' => (
          Icons.water_drop_rounded,
          MetingDictionary.lblFuelOil,
        ),
      'vast' => (
          Icons.forest_rounded,
          MetingDictionary.formatSolidFuelTitle(
            boiler.fuelSubtype,
            otherText: boiler.fuelOtherText,
          ),
        ),
      'gas' => (
          Icons.local_fire_department_rounded,
          MetingDictionary.formatGasFuelTitle(
            boiler.fuelSubtype,
            otherText: boiler.fuelOtherText,
          ),
        ),
      _ => (
          Icons.help_outline_rounded,
          MetingDictionary.lblNoFuelSelected,
        ),
    };

    final String classificationText;
    if (!hasFuel) {
      classificationText = MetingDictionary.subNoFuelSelected;
    } else if (boiler.isCentral) {
      final String typePrefix = switch (boiler.centraalType) {
        'B' => 'Type B (Open)',
        'C' => 'Type C (Gesloten)',
        _ => 'Centraal',
      };
      classificationText = boiler.boilerOperation.isNotEmpty
          ? '$typePrefix • ${boiler.boilerOperation}'
          : typePrefix;
    } else {
      classificationText = boiler.heatingType.isNotEmpty
          ? 'Niet-centraal • ${boiler.heatingType}'
          : 'Niet-centraal';
    }

    final Color borderColor = hasFuel
        ? AppColors.amberGold.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.12);

    final Color iconBoxBg = hasFuel
        ? AppColors.amberGold.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.06);

    final Color iconColor = hasFuel ? AppColors.amberGold : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.bentoCardSpacing),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.carbonCard,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBoxBg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  fuelTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: hasFuel ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  classificationText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.0,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(width: 34),
        ],
      ),
    );
  }
}
