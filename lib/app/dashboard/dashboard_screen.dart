import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../shell/app_shell_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'applet_bento_tile.dart';

/// Home Dashboard screen displaying the compact 2-column squircle tile launcher.
///
/// Features:
/// - Centered "Kies een applet" title in Libron font.
/// - Balanced 2-column grid scaled nicely on phones (Pixel 10 Pro, S23).
/// - Proportioned squircle tiles matching the legacy reference sizing.
class DashboardScreen extends StatelessWidget {
  final AppShellController controller;

  const DashboardScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          children: [
            // Centered "Kies een applet" title in Libron font
            const Text(
              AppDictionary.dashboardTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            // 32dp spacing (4x 8dp grid) following Material 3 guidelines to establish
            // a clear visual hierarchy between the section headline and content grid.
            const SizedBox(height: 32),
            // 2-column grid matching the legacy reference image proportions
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 22.0,
              crossAxisSpacing: 18.0,
              childAspectRatio: 0.70,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Row 1, Col 1: Verbrandingsattest Vlaanderen
                AppletBentoTile(
                  title: 'Verbrandingsattest',
                  subtitle: 'Vlaanderen',
                  icon: Icons.local_fire_department_rounded,
                  accentColor: AppColors.amberGold,
                  borderColor: AppColors.amberGoldBorder,
                  onTap: () => controller.selectApplet(AppletType.combustion),
                ),
                // Row 1, Col 2: Reinigingsattest Vlaanderen
                AppletBentoTile(
                  title: 'Reinigingsattest',
                  subtitle: 'Vlaanderen',
                  icon: Icons.cleaning_services_rounded,
                  accentColor: AppColors.terracotta,
                  borderColor: AppColors.terracottaBorder,
                  onTap: () => controller.selectApplet(AppletType.cleaning),
                ),
                // Row 2, Col 1: Keuringsrapport Vlaanderen
                AppletBentoTile(
                  title: 'Keuringsrapport',
                  subtitle: 'Vlaanderen',
                  icon: Icons.fact_check_rounded,
                  accentColor: AppColors.slate,
                  borderColor: AppColors.slateBorder,
                  onTap: () => controller.selectApplet(AppletType.inspection),
                ),
                // Row 2, Col 2: Meetrapport
                AppletBentoTile(
                  title: 'Meetrapport',
                  icon: Icons.factory_rounded,
                  accentColor: AppColors.steelMuted,
                  borderColor: AppColors.steelBorder,
                  onTap: () => controller.selectApplet(AppletType.measurement),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
