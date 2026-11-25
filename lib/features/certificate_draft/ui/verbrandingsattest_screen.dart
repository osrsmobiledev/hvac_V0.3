import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/form_scroll_helper.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/tactical_tab_bar_view.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'draft_save_scope.dart';
import '../../../app/localization/visit_history_dictionary.dart';
import 'visit_finalization.dart';
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
import 'widgets/workflow_tab_bar.dart';
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
  final _draftRepository = DraftRepository();
  late final _draftSaves = {_boilerNotifier.draftSaves};
  GlobalKey<FormState>? _tab2FormKey,
      _tab3FormKey,
      _tab4FormKey,
      _tab5FormKey,
      _tab6FormKey,
      _tab7FormKey;
  int _activeVisitId =
      AppWarmupService.instance.cachedResult?.activeDraft?.id ?? 1;
  bool _isAppletLoading = true;
  static const _tabTitles = AppDictionary.combustionTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _boilerNotifier = BoilerDraftNotifier();
    _assessmentNotifier = MeasurementAssessmentNotifier();
    _warmupAndPreload();
  }

  Future<void> _warmupAndPreload() async {
    try {
      await AppWarmupService.instance.warmup();
      if (!mounted) return;
      await _boilerNotifier.loadInitial();
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

  bool _finalizing = false;

  Future<void> _handleFinalizeAttempt() async {
    if (_finalizing) return;
    final keys = [
      _tab2FormKey,
      _tab3FormKey,
      _tab4FormKey,
      _tab5FormKey,
      _tab6FormKey,
      _tab7FormKey,
    ];
    for (var index = 0; index < keys.length; index++) {
      final key = keys[index];
      final formValid = key?.currentState?.validate() ?? false;
      // Tab 4 (index 2 in `keys`, tab index 3) must also have no active Klant edit session.
      final klantEditBlocked =
          index == 2 && DraftSaveScope.hasBlocked(_draftSaves);
      if (formValid && !klantEditBlocked) continue;
      _tabController.animateTo(index + 1);
      final tabTitle = _tabTitles[index + 1];
      final detail = !formValid
          ? FormScrollHelper.findFirstError(key?.currentContext)
          : null;
      final msg = klantEditBlocked && formValid
          ? VisitHistoryDictionary.customerEditing
          : detail != null
              ? '$tabTitle: $detail'
              : VisitHistoryDictionary.checkTab(tabTitle);
      TacticalFeedback.showError(context, msg);
      if (!formValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FormScrollHelper.scrollToFirstInvalid(key?.currentContext);
          }
        });
      }
      return;
    }
    _finalizing = true;
    try {
      final isFinalized = await VisitFinalization.executeWorkflow(
        context,
        visitId: _activeVisitId,
        saveScope: DraftSaveScope(saves: _draftSaves, child: const SizedBox()),
      );
      if (isFinalized && mounted) {
        widget.controller.visitFinalized();
      }
    } on VisitFinalizationException catch (error) {
      if (mounted) TacticalFeedback.showError(context, error.message);
    } finally {
      if (mounted) {
        setState(() {
          _finalizing = false;
          _isAppletLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      DraftSaveScope(saves: _draftSaves, child: _screen);

  Widget get _screen => Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              WorkflowTabBar(controller: _tabController, titles: _tabTitles),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TacticalTabBarView(
                      key: ValueKey(_activeVisitId),
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        RepaintBoundary(
                            child: DataTab(visitId: _activeVisitId)),
                        RepaintBoundary(
                          child: StartTab(
                            visitId: _activeVisitId,
                            onFormKeyReady: (key) => _tab2FormKey = key,
                          ),
                        ),
                        RepaintBoundary(
                          child: FirmaTechnicusTab(
                            visitId: _activeVisitId,
                            boilerNotifier: _boilerNotifier,
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
                            visitId: _activeVisitId,
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
