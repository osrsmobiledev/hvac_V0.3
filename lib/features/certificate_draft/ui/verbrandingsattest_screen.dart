import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/form_scroll_helper.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/tactical_tab_bar_view.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'boiler_draft_notifier.dart';
import 'measurement_assessment_notifier.dart';
import 'tabs/data_tab.dart';
import 'tabs/eindbeoordeling_tab.dart';
import 'tabs/firma_technicus_tab.dart';
import 'tabs/klant_tab.dart';
import 'tabs/meting_tab.dart';
import 'tabs/start_tab.dart';
import 'tabs/stooktoestel_tab.dart';
import 'widgets/tab_nav_overlay.dart';
import 'widgets/verbrandingsattest_loading_overlay.dart';

/// The 7-tab workflow screen for 'Verbrandingsattest Vlaanderen'.
class VerbrandingsattestScreen extends StatefulWidget {
  final AppShellController controller;

  const VerbrandingsattestScreen({super.key, required this.controller});

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
  GlobalKey<FormState>? _tab2FormKey,
      _tab3FormKey,
      _tab4FormKey,
      _tab5FormKey,
      _tab6FormKey,
      _tab7FormKey;
  int _activeVisitId =
      AppWarmupService.instance.cachedResult?.activeDraft?.id ?? 1;
  bool _isAppletLoading = true;

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
      debugPrint('[VerbrandingsattestScreen] warmup error: $e\n$stack');
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isAppletLoading = false);
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

  void _handleFinalizeAttempt() {
    final t2Valid = _tab2FormKey?.currentState?.validate() ?? false;
    final t3Valid = _tab3FormKey?.currentState?.validate() ?? false;
    final t4Valid = _tab4FormKey?.currentState?.validate() ?? false;
    final t5Valid = _tab5FormKey?.currentState?.validate() ?? false;
    final t6Valid = _tab6FormKey?.currentState?.validate() ?? false;
    final t7Valid = _tab7FormKey?.currentState?.validate() ?? false;

    void notify(int idx, String msg, GlobalKey<FormState>? key) {
      _tabController.animateTo(idx);
      TacticalFeedback.showError(context, msg);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FormScrollHelper.scrollToFirstInvalid(key?.currentContext);
      });
    }

    if (!t2Valid) {
      return notify(
          1, 'Vul alle verplichte velden in op Tab 2: Start', _tab2FormKey);
    }
    if (!t3Valid) {
      return notify(
          2,
          'Vul alle verplichte velden in op Tab 3: Firma - Technicus',
          _tab3FormKey);
    }
    if (!t4Valid) {
      return notify(
          3, 'Vul alle verplichte velden in op Tab 4: Klant', _tab4FormKey);
    }
    if (!t5Valid) {
      return notify(4, 'Vul alle verplichte velden in op Tab 5: Stooktoestel',
          _tab5FormKey);
    }
    if (!t6Valid) {
      return notify(
          5, 'Vul alle verplichte velden in op Tab 6: Meting', _tab6FormKey);
    }
    if (!t7Valid) {
      return notify(
          6,
          'Vul alle verplichte velden in op Tab 7: Eindbeoordeling',
          _tab7FormKey);
    }

    TacticalFeedback.showSuccess(context,
        'Alle velden zijn geldig. PDF-generatie volgt in Milestone 4.');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TacticalTabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      RepaintBoundary(child: DataTab(visitId: _activeVisitId)),
                      RepaintBoundary(
                        child: StartTab(
                          visitId: _activeVisitId,
                          onFormKeyReady: (key) => _tab2FormKey = key,
                        ),
                      ),
                      RepaintBoundary(
                        child: FirmaTechnicusTab(
                          onFormKeyReady: (key) => _tab3FormKey = key,
                        ),
                      ),
                      RepaintBoundary(
                        child: KlantTab(
                          onFormKeyReady: (key) => _tab4FormKey = key,
                        ),
                      ),
                      RepaintBoundary(
                        child: StooktoestelTab(
                          boilerNotifier: _boilerNotifier,
                          onFormKeyReady: (key) => _tab5FormKey = key,
                        ),
                      ),
                      RepaintBoundary(
                        child: MetingTab(
                          visitId: _activeVisitId,
                          boilerNotifier: _boilerNotifier,
                          assessmentNotifier: _assessmentNotifier,
                          onFormKeyReady: (key) => _tab6FormKey = key,
                        ),
                      ),
                      RepaintBoundary(
                        child: EindbeoordelingTab(
                          visitId: _activeVisitId,
                          boilerNotifier: _boilerNotifier,
                          assessmentNotifier: _assessmentNotifier,
                          onComplete: _handleFinalizeAttempt,
                          onFormKeyReady: (key) => _tab7FormKey = key,
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
