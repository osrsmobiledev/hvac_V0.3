import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../../domain/boiler_draft.dart';

/// Clean tactical cosmetic banner displaying the active installation fuel and classification.
///
/// Derived automatically from Tab 5 (Stooktoestel). Eliminates redundant re-selection
/// and avoids clutter or chatty text.
class MetingFuelBanner extends StatelessWidget {
  final BoilerDraft boiler;

  const MetingFuelBanner({super.key, required this.boiler});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String fuelTitle) = switch (boiler.fuelCategory) {
      'vloeibaar' => (
          Icons.water_drop_rounded,
          'Stookolie (Mazout)',
        ),
      'vast' => (
          Icons.forest_rounded,
          boiler.fuelSubtype.isNotEmpty
              ? 'Vast (${boiler.fuelSubtype})'
              : 'Vaste brandstof',
        ),
      _ => (
          Icons.local_fire_department_rounded,
          boiler.fuelSubtype.isNotEmpty
              ? 'Gas (${boiler.fuelSubtype})'
              : 'Gasvormig (Aardgas)',
        ),
    };

    final String classificationText = boiler.isCentral
        ? (boiler.centraalType == 'B'
            ? 'Type B (Open) • ${boiler.boilerOperation}'
            : boiler.centraalType == 'C'
                ? 'Type C (Gesloten) • ${boiler.boilerOperation}'
                : 'Centraal • ${boiler.boilerOperation}')
        : 'Niet-centraal • ${boiler.heatingType}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.bentoCardSpacing),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.carbonCard,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.amberGold.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: AppColors.amberGold, size: 20),
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
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
