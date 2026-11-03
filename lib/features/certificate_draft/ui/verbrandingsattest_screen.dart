import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/widgets/tactical_tab_bar_view.dart';
import '../data/draft_repository.dart';
import 'boiler_draft_notifier.dart';
import 'measurement_assessment_notifier.dart';
import 'tabs/data_tab.dart';
import 'tabs/firma_technicus_tab.dart';
import 'tabs/klant_tab.dart';
import 'tabs/start_tab.dart';
import 'tabs/stooktoestel_tab.dart';
import 'tabs/meting_tab.dart';
import 'tabs/eindbeoordeling_tab.dart';
import 'widgets/tab_nav_overlay.dart';
import 'widgets/verbrandingsattest_loading_overlay.dart';

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
  late final BoilerDraftNotifier _boilerNotifier;
  late final MeasurementAssessmentNotifier _assessmentNotifier;
  final DraftRepository _draftRepository = DraftRepository();
  int _activeVisitId =
      AppWarmupService.instance.cachedResult?.activeDraft?.id ?? 1;
  bool _isAppletLoading = true;

  /// Tab titles sourced from [AppDictionary.combustionTabs] to keep UI labels
  /// centralized in the single Dutch dictionary. Edit labels there, not here.
  static List<String> get _tabTitles => AppDictionary.combustionTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _boilerNotifier = BoilerDraftNotifier()..loadInitial();
    _assessmentNotifier = MeasurementAssessmentNotifier();
    _warmupAndPreload();
  }

  Future<void> _warmupAndPreload() async {
    try {
      await AppWarmupService.instance.warmup();
      final draft = await _draftRepository.getOrCreateActiveDraft();
      if (mounted && draft.id != _activeVisitId) {
        setState(() => _activeVisitId = draft.id);
      }
    } catch (e, stack) {
      debugPrint(
          '[VerbrandingsattestScreen] _warmupAndPreload error: $e\n$stack');
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isAppletLoading = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _boilerNotifier.dispose();
    _assessmentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
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

            // Tactical Tab Content Views with Floating Navigation Arrows
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TacticalTabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Tab 1: Data (Active in Slice 2.1)
                      RepaintBoundary(child: DataTab(visitId: _activeVisitId)),

                      // Tab 2: Start (Active in Slice 2.2)
                      RepaintBoundary(child: StartTab(visitId: _activeVisitId)),

                      // Tab 3: Firma - Technicus (Active in Slice 2.3)
                      const RepaintBoundary(child: FirmaTechnicusTab()),

                      // Tab 4: Klant (Active in Slice 2.4)
                      const RepaintBoundary(child: KlantTab()),

                      // Tab 5: Stooktoestel (Active in Slice 3.1)
                      RepaintBoundary(
                        child: StooktoestelTab(boilerNotifier: _boilerNotifier),
                      ),

                      // Tab 6: Meting (Active in Slice 3.2)
                      RepaintBoundary(
                        child: MetingTab(
                          visitId: _activeVisitId,
                          boilerNotifier: _boilerNotifier,
                          assessmentNotifier: _assessmentNotifier,
                        ),
                      ),

                      // Tab 7: Eindbeoordeling (Slice 3.3)
                      RepaintBoundary(
                        child: EindbeoordelingTab(
                          visitId: _activeVisitId,
                          boilerNotifier: _boilerNotifier,
                          assessmentNotifier: _assessmentNotifier,
                        ),
                      ),
                    ],
                  ),
                  TabNavOverlay(
                    controller: _tabController,
                    tabCount: _tabTitles.length,
                  ),
                ],
              ),
            ),
          ],
        ),
        VerbrandingsattestLoadingOverlay(isLoading: _isAppletLoading),
      ],
    );
  }
}
