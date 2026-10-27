import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'tabs/data_tab.dart';
import 'tabs/firma_technicus_tab.dart';
import 'tabs/klant_tab.dart';
import 'tabs/start_tab.dart';
import 'tabs/stooktoestel_tab.dart';

/// The 7-tab workflow screen for 'Verbrandingsattest Vlaanderen'.
///
/// Features:
/// - Scrollable top navigation bar matching the preferred theme style.
/// - Tab 1 (Data) fully active with collapsible Meetgegevens / Rookgassen cards.
/// - Swipable TabBarView allowing fluid gesture and tap navigation between tabs.
/// - Clean modular placeholder views for upcoming slices.
class VerbrandingsattestScreen extends StatefulWidget {
  final AppShellController controller;

  const VerbrandingsattestScreen({
    super.key,
    required this.controller,
  });

  @override
  State<VerbrandingsattestScreen> createState() =>
      _VerbrandingsattestScreenState();
}

class _VerbrandingsattestScreenState extends State<VerbrandingsattestScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Tab titles sourced from [AppDictionary.combustionTabs] to keep UI labels
  /// centralized in the single Dutch dictionary. Edit labels there, not here.
  static List<String> get _tabTitles => AppDictionary.combustionTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Horizontal Navigation Bar (Tactical Ribbon: 40dp height)
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF101010),
            border: Border(
              bottom: BorderSide(
                color: AppColors.goldHairline,
                width: 1.0,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                color: AppColors.amberGold,
                width: 2.5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(2.5)),
              insets: EdgeInsets.only(bottom: 1.5),
            ),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelColor: AppColors.amberGold,
            unselectedLabelColor: Colors.white,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
            ),
            tabs: _tabTitles
                .map((title) => Tab(height: 40.0, text: title))
                .toList(),
          ),
        ),

        // Swipable Tab Content Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Tab 1: Data (Active in Slice 2.1)
              DataTab(),

              // Tab 2: Start (Active in Slice 2.2)
              StartTab(),

              // Tab 3: Firma - Technicus (Active in Slice 2.3)
              FirmaTechnicusTab(),

              // Tab 4: Klant (Active in Slice 2.4)
              KlantTab(),

              // Tab 5: Stooktoestel (Active in Slice 3.1)
              StooktoestelTab(),

              // Tab 6: Meting (Slice 3.2)
              _DraftTabPlaceholder(
                tabName: 'Meting',
                sliceInfo: 'Wordt geïmplementeerd in Slice 3.2',
                icon: Icons.speed_rounded,
              ),

              // Tab 7: Eindbeoordeling (Slice 3.3)
              _DraftTabPlaceholder(
                tabName: 'Eindbeoordeling',
                sliceInfo: 'Wordt geïmplementeerd in Slice 3.3',
                icon: Icons.verified_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple clean placeholder displayed on unbuilt tabs until their slice is reached.
class _DraftTabPlaceholder extends StatelessWidget {
  final String tabName;
  final String sliceInfo;
  final IconData icon;

  const _DraftTabPlaceholder({
    required this.tabName,
    required this.sliceInfo,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.carbonCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, color: AppColors.amberGold, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                tabName,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                sliceInfo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
