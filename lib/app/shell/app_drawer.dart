import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';
import 'app_shell_controller.dart';
import 'drawer_nav_tile.dart';

/// Navigation Drawer & Permanent Side Menu for the HVAC Application.
///
/// Implements the "BO2 Tactical HUD" styling with glowing applet icon badges.
/// - On phones: used inside the sliding Drawer underneath the AppBar.
/// - On tablets: used as a permanent left side menu.
class AppDrawer extends StatelessWidget {
  final AppShellController controller;
  final bool isPermanent;
  final VoidCallback? onItemTapped;

  const AppDrawer({
    super.key,
    required this.controller,
    required this.isPermanent,
    this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final drawerWidth = isPermanent ? 280.0 : 300.0;

    return Container(
      width: drawerWidth,
      color: AppColors.charcoalGlass,
      child: SafeArea(
        top: isPermanent,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerHeaderBranding(),
            const Divider(color: AppColors.hairlineBorder, height: 1.0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                children: [
                  DrawerNavigationTile(
                    label: AppDictionary.menuStart,
                    icon: Icons.dashboard_rounded,
                    accentColor: AppColors.amberGold,
                    isSelected: controller.activeApplet == AppletType.home,
                    onTap: () => _handleSelection(AppletType.home),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      'APPLETS VLAANDEREN',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  DrawerNavigationTile(
                    label: AppDictionary.menuCombustion,
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.amberGold,
                    isSelected:
                        controller.activeApplet == AppletType.combustion,
                    onTap: () => _handleSelection(AppletType.combustion),
                  ),
                  const SizedBox(height: 8),
                  DrawerNavigationTile(
                    label: AppDictionary.menuCleaning,
                    icon: Icons.cleaning_services_rounded,
                    accentColor: AppColors.terracotta,
                    isSelected: controller.activeApplet == AppletType.cleaning,
                    onTap: () => _handleSelection(AppletType.cleaning),
                  ),
                  const SizedBox(height: 8),
                  DrawerNavigationTile(
                    label: AppDictionary.menuInspection,
                    icon: Icons.fact_check_rounded,
                    accentColor: AppColors.slate,
                    isSelected:
                        controller.activeApplet == AppletType.inspection,
                    onTap: () => _handleSelection(AppletType.inspection),
                  ),
                  const SizedBox(height: 8),
                  DrawerNavigationTile(
                    label: AppDictionary.menuMeasurement,
                    icon: Icons.speed_rounded,
                    accentColor: AppColors.steelMuted,
                    isSelected:
                        controller.activeApplet == AppletType.measurement,
                    onTap: () => _handleSelection(AppletType.measurement),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelection(AppletType applet) {
    controller.selectApplet(applet);
    onItemTapped?.call();
  }
}

/// Header for the Drawer featuring the app branding and subtle status indicator.
class _DrawerHeaderBranding extends StatelessWidget {
  const _DrawerHeaderBranding();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.amberGold.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.amberGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppDictionary.appTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Vlaams Energie- en Klimaatagentschap',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
