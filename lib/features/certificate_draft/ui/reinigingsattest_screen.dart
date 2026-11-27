import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/shell/app_shell_controller.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/tactical_tab_bar_view.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'boiler_draft_notifier.dart';
import 'draft_save_scope.dart';
import 'tabs/data_tab.dart';
import 'tabs/eindbeoordeling_tab.dart';
import 'tabs/firma_technicus_tab.dart';
import 'tabs/klant_tab.dart';
import 'tabs/reiniging_controle_tab.dart';
import 'tabs/start_tab.dart';
import 'tabs/stooktoestel_tab.dart';
import 'widgets/tab_nav_overlay.dart';
import 'widgets/verbrandingsattest_loading_overlay.dart';
import 'widgets/workflow_tab_bar.dart';

/// The 7-tab standalone workflow screen for 'Reinigingsattest Vlaanderen'.
class ReinigingsattestScreen extends StatefulWidget {
  final AppShellController controller;
  final DraftRepository? draftRepository;

  const ReinigingsattestScreen({
    super.key,
    required this.controller,
    this.draftRepository,
  });

  @override
  State<ReinigingsattestScreen> createState() => _ReinigingsattestScreenState();
}

class _ReinigingsattestScreenState extends State<ReinigingsattestScreen>
    with SingleTickerProviderStateMixin {
  static const _certificateType = 'reiniging';
  static const _tabTitles = ReinigingDictionary.reinigingTabs;

  late final TabController _tabController;
  late final BoilerDraftNotifier _boilerNotifier;
  late final DraftRepository _draftRepository;
  late final _draftSaves = {_boilerNotifier.draftSaves};

  int? _activeVisitId =
      AppWarmupService.instance.activeDraftFor(_certificateType)?.id;
  bool _isAppletLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _boilerNotifier = BoilerDraftNotifier();
    _draftRepository = widget.draftRepository ?? DraftRepository();
    _warmupAndPreload();
  }

  Future<void> _warmupAndPreload() async {
    try {
      await AppWarmupService.instance.warmup();
      if (!mounted) return;
      await _boilerNotifier.loadInitial();
      final draft = await _draftRepository.getOrCreateActiveDraft(
        certificateType: _certificateType,
      );
      if (mounted && draft.id != _activeVisitId) {
        setState(() => _activeVisitId = draft.id);
      }
    } catch (e, stack) {
      debugPrint('[ReinigingsattestScreen] warmup error: $e\n$stack');
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
    super.dispose();
  }

  void _onCompleteStub() {
    TacticalFeedback.showInfo(
      context,
      ReinigingDictionary.toastPdfNotYetAvailable,
    );
  }

  @override
  Widget build(BuildContext context) =>
      DraftSaveScope(saves: _draftSaves, child: _screen);

  Widget get _screen {
    final visitId = _activeVisitId;
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            WorkflowTabBar(controller: _tabController, titles: _tabTitles),
            Expanded(
              child: visitId == null
                  ? const SizedBox.shrink()
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        TacticalTabBarView(
                          key: ValueKey('reiniging_$visitId'),
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            RepaintBoundary(
                              child: DataTab(visitId: visitId),
                            ),
                            RepaintBoundary(
                              child: StartTab(
                                visitId: visitId,
                                certificateType: _certificateType,
                              ),
                            ),
                            RepaintBoundary(
                              child: FirmaTechnicusTab(
                                visitId: visitId,
                                boilerNotifier: _boilerNotifier,
                                certificateType: _certificateType,
                              ),
                            ),
                            const RepaintBoundary(
                              child:
                                  KlantTab(certificateType: _certificateType),
                            ),
                            RepaintBoundary(
                              child: StooktoestelTab(
                                visitId: visitId,
                                boilerNotifier: _boilerNotifier,
                              ),
                            ),
                            RepaintBoundary(
                              child: ReinigingControleTab(
                                visitId: visitId,
                                boilerNotifier: _boilerNotifier,
                              ),
                            ),
                            RepaintBoundary(
                              child: EindbeoordelingTab(
                                visitId: visitId,
                                certificateType: _certificateType,
                                boilerNotifier: _boilerNotifier,
                                onComplete: _onCompleteStub,
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
        VerbrandingsattestLoadingOverlay(
          isLoading: _isAppletLoading || visitId == null,
        ),
      ],
    );
  }
}
