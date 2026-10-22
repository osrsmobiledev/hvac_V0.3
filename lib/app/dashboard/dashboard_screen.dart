import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../shell/app_shell_controller.dart';
import '../theme/app_colors.dart';
import 'applet_bento_tile.dart';

/// Home Dashboard screen displaying the 2-column squircle tile applet launcher.
///
/// Features:
/// - Centered "Kies een applet" title.
/// - 2-column grid of single squircle tiles with centered icon glyphs.
/// - Formatted 2-line title text beneath each tile.
/// - Order:
///   * Row 1: Verbrandingsattest Vlaanderen | Reinigingsattest Vlaanderen
///   * Row 2: Keuringsrapport Vlaanderen   | Meetrapport
class DashboardScreen extends StatelessWidget {
  final AppShellController controller;

  const DashboardScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Constrain width on tablets/wide screens for balanced, centered presentation
        final double maxWidth = constraints.maxWidth >= 720 ? 540 : 420;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              children: [
                // Centered "Kies een applet" header
                const Text(
                  AppDictionary.dashboardTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 24),
                // 2-column grid of squircle tiles matching the reference layout
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 0.76,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Row 1, Col 1: Verbrandingsattest Vlaanderen
                    AppletBentoTile(
                      title: 'Verbrandingsattest',
                      subtitle: 'Vlaanderen',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: AppColors.amberGold,
                      onTap: () =>
                          controller.selectApplet(AppletType.combustion),
                    ),
                    // Row 1, Col 2: Reinigingsattest Vlaanderen
                    AppletBentoTile(
                      title: 'Reinigingsattest',
                      subtitle: 'Vlaanderen',
                      icon: Icons.cleaning_services_rounded,
                      accentColor: AppColors.terracotta,
                      onTap: () => controller.selectApplet(AppletType.cleaning),
                    ),
                    // Row 2, Col 1: Keuringsrapport Vlaanderen
                    AppletBentoTile(
                      title: 'Keuringsrapport',
                      subtitle: 'Vlaanderen',
                      icon: Icons.fact_check_rounded,
                      accentColor: AppColors.slate,
                      onTap: () =>
                          controller.selectApplet(AppletType.inspection),
                    ),
                    // Row 2, Col 2: Meetrapport
                    AppletBentoTile(
                      title: 'Meetrapport',
                      icon: Icons.speed_rounded,
                      accentColor: AppColors.steelMuted,
                      onTap: () =>
                          controller.selectApplet(AppletType.measurement),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
