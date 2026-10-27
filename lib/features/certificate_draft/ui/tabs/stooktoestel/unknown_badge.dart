import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../widgets/dark_input_label.dart';

/// Tactical header row with an input title on the left and a statutory
/// 'Onbekend' toggle chip on the right (matching Type verwarming & Werking ketel).
class HeaderWithUnknownChip extends StatelessWidget {
  final String title;
  final bool isUnknown;
  final ValueChanged<bool> onUnknownChanged;

  const HeaderWithUnknownChip({
    super.key,
    required this.title,
    required this.isUnknown,
    required this.onUnknownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: DarkInputLabel.style(isMuted: isUnknown),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onUnknownChanged(!isUnknown);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isUnknown
                    ? AppColors.amberGold.withValues(alpha: 0.20)
                    : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isUnknown
                      ? AppColors.amberGoldBorder
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                AppDictionary.optUnknown,
                style: TextStyle(
                  color: isUnknown ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isUnknown ? FontWeight.w700 : FontWeight.w500,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
