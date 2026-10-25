import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Top header for the Drawer featuring the gold dashboard emblem and "HVAC" title.
class DrawerHeaderBranding extends StatelessWidget {
  const DrawerHeaderBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.carbonCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.amberGoldBorder,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: AppColors.amberGold,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            AppDictionary.appBrand,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean uppercase section header inside the Drawer without extra spacing.
class DrawerSectionHeader extends StatelessWidget {
  final String title;

  const DrawerSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Subtle hairline divider separating drawer sections.
class DrawerSectionDivider extends StatelessWidget {
  const DrawerSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Divider(
        color: Color(0x22FFFFFF),
        height: 1.0,
        thickness: 1.0,
      ),
    );
  }
}
