import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Tactical compliance badge displayed when the burner is integrated into the boiler.
class IntegratedBurnerBadge extends StatelessWidget {
  const IntegratedBurnerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.amberGoldBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.amberGold,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDictionary.lblBurnerIntegratedBadge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  AppDictionary.descBurnerIntegrated,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
