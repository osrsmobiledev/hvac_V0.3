import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Non-tappable locked activity status card for Reinigingsattest Tab 1 (Start).
class ReinigingLockedActivityCard extends StatelessWidget {
  const ReinigingLockedActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColors.antiqueGold.withValues(alpha: 0.08),
          const Color(0xFF141414),
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.amberGoldBorder,
          width: 1.2,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 20.0,
            color: AppColors.amberGold,
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              ReinigingDictionary.activityOnderhoudStooktoestel,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
