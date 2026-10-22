import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_shell_controller.dart';
import 'drawer_nav_tile.dart';

/// Navigation Drawer matching the owner's preferred theme.
///
/// Features:
/// - "HVAC" branding header with gold gear emblem.
/// - Clean uppercase section titles: DASHBOARD, APPLETS, BEHEER.
/// - Dark squircle tiles with custom colored rims (Amber, Terracotta, Slate, Steel).
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
      decoration: const BoxDecoration(
        color: AppColors.charcoalGlass,
        border: Border(
          right: BorderSide(color: AppColors.goldHairline, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: isPermanent,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerHeaderBranding(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  const _SectionHeader(title: 'DASHBOARD'),
                  DrawerNavigationTile(
                    label: AppDictionary.menuStart,
                    icon: Icons.home_rounded,
                    accentColor: Colors.white,
                    borderColor: const Color(0x44FFFFFF),
                    isSelected: controller.activeApplet == AppletType.home,
                    onTap: () => _handleSelection(AppletType.home),
                  ),
                  const _SectionDivider(),
                  const _SectionHeader(title: 'APPLETS'),
                  DrawerNavigationTile(
                    label: 'Verbrandingsattest\nVlaanderen',
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.amberGold,
                    borderColor: AppColors.amberGoldBorder,
                    isSelected:
                        controller.activeApplet == AppletType.combustion,
                    onTap: () => _handleSelection(AppletType.combustion),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    label: 'Reinigingsattest\nVlaanderen',
                    icon: Icons.cleaning_services_rounded,
                    accentColor: AppColors.terracotta,
                    borderColor: AppColors.terracottaBorder,
                    isSelected: controller.activeApplet == AppletType.cleaning,
                    onTap: () => _handleSelection(AppletType.cleaning),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    label: 'Keuringsrapport\nVlaanderen',
                    icon: Icons.fact_check_rounded,
                    accentColor: AppColors.slate,
                    borderColor: AppColors.slateBorder,
                    isSelected:
                        controller.activeApplet == AppletType.inspection,
                    onTap: () => _handleSelection(AppletType.inspection),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    label: 'Meetrapport',
                    icon: Icons.factory_rounded,
                    accentColor: AppColors.steelMuted,
                    borderColor: AppColors.steelBorder,
                    isSelected:
                        controller.activeApplet == AppletType.measurement,
                    onTap: () => _handleSelection(AppletType.measurement),
                  ),
                  const _SectionDivider(),
                  const _SectionHeader(title: 'BEHEER'),
                  DrawerNavigationTile(
                    label: 'Instellingen Technicus',
                    icon: Icons.settings_outlined,
                    accentColor: AppColors.textSecondary,
                    borderColor: const Color(0xFF3A3A3C),
                    isSelected: false,
                    onTap: () {
                      onItemTapped?.call();
                    },
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    label: 'Import / Export',
                    icon: Icons.swap_vert_rounded,
                    accentColor: AppColors.textSecondary,
                    borderColor: const Color(0xFF3A3A3C),
                    isSelected: false,
                    onTap: () {
                      onItemTapped?.call();
                    },
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

/// Header for the Drawer featuring the gold gear emblem and "HVAC" title.
class _DrawerHeaderBranding extends StatelessWidget {
  const _DrawerHeaderBranding();

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
              Icons.miscellaneous_services_rounded,
              color: AppColors.amberGold,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'HVAC',
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
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

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
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

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
