import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';
import 'app_shell_controller.dart';
import 'drawer_nav_tile.dart';
import 'drawer_sections.dart';

/// Navigation Drawer matching the owner's preferred theme.
///
/// Features:
/// - "HVAC" branding header with gold dashboard emblem.
/// - Clean uppercase section titles: DASHBOARD, APPLETS, BEHEER.
/// - Dark squircle tiles with custom colored rims (Amber, Terracotta, Slate, Steel).
/// - Automatically scrolls down and focuses on the selected item when opened.
class AppDrawer extends StatefulWidget {
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
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  /// Dedicated GlobalKey for each applet navigation item for robust scrolling.
  final Map<AppletType, GlobalKey> _itemKeys = {
    for (final type in AppletType.values) type: GlobalKey(),
  };

  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItem();
    });
  }

  @override
  void didUpdateWidget(covariant AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.activeApplet != widget.controller.activeApplet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedItem();
      });
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  /// Automatically scrolls down and centers the viewport on the selected applet.
  void _scrollToSelectedItem() {
    _scrollTimer?.cancel();
    // Start is already at the top edge of the drawer, no auto-scroll needed
    if (widget.controller.activeApplet == AppletType.home) return;

    // Delay ensures mobile drawer slide-in animation is active for visible smooth motion
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final key = _itemKeys[widget.controller.activeApplet];
      final targetContext = key?.currentContext;
      if (targetContext != null && mounted) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = widget.isPermanent ? 280.0 : 300.0;

    return Container(
      width: drawerWidth,
      decoration: const BoxDecoration(
        color: AppColors.charcoalGlass,
        border: Border(
          right: BorderSide(color: AppColors.goldHairline, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: widget.isPermanent,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeaderBranding(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  const DrawerSectionHeader(
                      title: AppDictionary.sectionDashboard),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.home],
                    label: AppDictionary.menuStart,
                    icon: Icons.home_rounded,
                    accentColor: Colors.white,
                    borderColor: const Color(0x44FFFFFF),
                    isSelected:
                        widget.controller.activeApplet == AppletType.home,
                    onTap: () => _handleSelection(AppletType.home),
                  ),
                  const DrawerSectionDivider(),
                  const DrawerSectionHeader(
                      title: AppDictionary.sectionApplets),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.combustion],
                    label: AppDictionary.menuCombustionMultiLine,
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.amberGold,
                    borderColor: AppColors.amberGoldBorder,
                    isSelected:
                        widget.controller.activeApplet == AppletType.combustion,
                    onTap: () => _handleSelection(AppletType.combustion),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.cleaning],
                    label: AppDictionary.menuCleaningMultiLine,
                    icon: Icons.cleaning_services_rounded,
                    accentColor: AppColors.terracotta,
                    borderColor: AppColors.terracottaBorder,
                    isSelected:
                        widget.controller.activeApplet == AppletType.cleaning,
                    onTap: () => _handleSelection(AppletType.cleaning),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.inspection],
                    label: AppDictionary.menuInspectionMultiLine,
                    icon: Icons.fact_check_rounded,
                    accentColor: AppColors.slate,
                    borderColor: AppColors.slateBorder,
                    isSelected:
                        widget.controller.activeApplet == AppletType.inspection,
                    onTap: () => _handleSelection(AppletType.inspection),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.measurement],
                    label: AppDictionary.menuMeasurement,
                    icon: Icons.factory_rounded,
                    accentColor: AppColors.steelMuted,
                    borderColor: AppColors.steelBorder,
                    isSelected: widget.controller.activeApplet ==
                        AppletType.measurement,
                    onTap: () => _handleSelection(AppletType.measurement),
                  ),
                  const DrawerSectionDivider(),
                  const DrawerSectionHeader(title: AppDictionary.sectionManage),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.technicianSettings],
                    label: AppDictionary.menuTechSettings,
                    icon: Icons.settings_outlined,
                    accentColor: AppColors.textSecondary,
                    borderColor: const Color(0xFF3A3A3C),
                    isSelected: widget.controller.activeApplet ==
                        AppletType.technicianSettings,
                    onTap: () =>
                        _handleSelection(AppletType.technicianSettings),
                  ),
                  const SizedBox(height: 4),
                  DrawerNavigationTile(
                    key: _itemKeys[AppletType.importExport],
                    label: AppDictionary.menuImportExport,
                    icon: Icons.swap_vert_rounded,
                    accentColor: AppColors.textSecondary,
                    borderColor: const Color(0xFF3A3A3C),
                    isSelected: widget.controller.activeApplet ==
                        AppletType.importExport,
                    onTap: () => _handleSelection(AppletType.importExport),
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
    widget.controller.selectApplet(applet);
    widget.onItemTapped?.call();
  }
}
