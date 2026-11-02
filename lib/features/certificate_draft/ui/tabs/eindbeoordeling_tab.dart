// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart
// Responsibility: Tab 7 — Eindbeoordeling & Handtekeningen coordinator.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import '../boiler_draft_notifier.dart';
import '../measurement_assessment_notifier.dart';
import 'eindbeoordeling/eindbeoordeling_tab_body.dart';

class EindbeoordelingTab extends StatefulWidget {
  final int visitId;
  final BoilerDraftNotifier? boilerNotifier;
  final MeasurementAssessmentNotifier? assessmentNotifier;
  final VoidCallback? onComplete;
  final EindbeoordelingRepository? repositoryOverride;

  const EindbeoordelingTab({
    super.key,
    required this.visitId,
    this.boilerNotifier,
    this.assessmentNotifier,
    this.onComplete,
    this.repositoryOverride,
  });

  @override
  State<EindbeoordelingTab> createState() => _EindbeoordelingTabState();
}

class _EindbeoordelingTabState extends State<EindbeoordelingTab>
    with AutomaticKeepAliveClientMixin {
  late final EindbeoordelingRepository _repository;
  late final Debouncer _debouncer;

  final _defectsController = TextEditingController();
  final _remarksController = TextEditingController();

  EindbeoordelingDraft _draft = const EindbeoordelingDraft();
  String _fuelType = 'gas';
  String _visitDate = '';
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repositoryOverride ?? EindbeoordelingRepository();
    _debouncer = Debouncer(duration: const Duration(milliseconds: 350));
    widget.boilerNotifier?.addListener(_onBoilerChanged);
    widget.assessmentNotifier?.addListener(_onAssessmentChanged);

    final cached = AppWarmupService.instance.cachedResult;
    if (cached?.eindbeoordeling != null && widget.repositoryOverride == null) {
      final nFuel = widget.boilerNotifier?.draft.fuelCategory;
      _applyInitialDraft(
        cached!.eindbeoordeling!,
        (nFuel != null && nFuel.isNotEmpty)
            ? nFuel
            : (cached.activeBoiler?.fuelCategory ?? 'gas'),
        cached.activeDraft?.visitDate ?? '',
      );
    } else {
      _loadInitialData();
    }
  }

  void _applyInitialDraft(
    EindbeoordelingDraft loaded,
    String fuel,
    String date, [
    String? customerName,
  ]) {
    _fuelType = fuel;
    _visitDate = date;
    _draft = loaded;
    _defectsController.text = loaded.defectsNotes ?? '';
    _remarksController.text = loaded.generalRemarks ?? '';
    _isLoading = false;
  }

  @override
  void didUpdateWidget(covariant EindbeoordelingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boilerNotifier != widget.boilerNotifier) {
      oldWidget.boilerNotifier?.removeListener(_onBoilerChanged);
      widget.boilerNotifier?.addListener(_onBoilerChanged);
    }
    if (oldWidget.assessmentNotifier != widget.assessmentNotifier) {
      oldWidget.assessmentNotifier?.removeListener(_onAssessmentChanged);
      widget.assessmentNotifier?.addListener(_onAssessmentChanged);
    }
  }

  @override
  void dispose() {
    widget.boilerNotifier?.removeListener(_onBoilerChanged);
    widget.assessmentNotifier?.removeListener(_onAssessmentChanged);
    _debouncer.dispose();
    _defectsController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onBoilerChanged() {
    if (widget.boilerNotifier == null || !mounted) return;
    final newFuel = widget.boilerNotifier!.draft.fuelCategory;
    if (newFuel.isNotEmpty && newFuel != _fuelType) {
      final newDate = EindbeoordelingDraft.calculateStatutoryNextDate(
        fuelType: newFuel,
        fromDate: EindbeoordelingDraft.parseDate(_visitDate),
      );
      setState(() {
        _fuelType = newFuel;
        _draft = _draft.copyWith(nextInspectionDate: newDate);
      });
      _saveDirect(_draft);
    }
  }

  void _onAssessmentChanged() {
    if (widget.assessmentNotifier == null || !mounted) return;
    final assessment = widget.assessmentNotifier!.state;
    final updated = _draft.withAssessmentState(
      combustionPassed: assessment.combustionPassed,
      safetyChecksPassed: assessment.safetyChecksPassed,
      fuelType: _fuelType,
      visitDate: EindbeoordelingDraft.parseDate(_visitDate),
    );
    if (updated != _draft) _saveDirect(updated);
  }

  Future<void> _loadInitialData() async {
    try {
      final summary =
          await _repository.loadVisitContext(visitId: widget.visitId);
      final loaded = await _repository.loadDraft(visitId: widget.visitId);
      final draft = await _repository.resolveInitialDraft(
        visitId: widget.visitId,
        summary: summary,
        notifierFuel: widget.boilerNotifier?.draft.fuelCategory,
      );

      if (mounted) {
        final nFuel = widget.boilerNotifier?.draft.fuelCategory;
        final f = (nFuel != null && nFuel.isNotEmpty) ? nFuel : summary.fuelType;
        setState(() {
          _applyInitialDraft(
            draft,
            f,
            summary.visitDate,
            loaded.customerSignatureName ?? summary.customerName,
          );
        });
      }
    } catch (e, stack) {
      debugPrint('[EindbeoordelingTab] _loadInitialData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDirect(EindbeoordelingDraft updated) async {
    setState(() => _draft = updated);
    try {
      await _repository.updateDraft(
        visitId: widget.visitId,
        draft: updated.copyWith(
          defectsNotes: _defectsController.text,
          generalRemarks: _remarksController.text,
        ),
      );
    } catch (e, stack) {
      debugPrint('[EindbeoordelingTab] _saveDirect error: $e\n$stack');
    }
  }

  void _onTextInputsChanged() => _debouncer.run(() => _saveDirect(_draft));

  void _updateConclusion({String? goed, String? veilig, required bool isGoed}) {
    _saveDirect(_draft.withUpdatedConclusions(
      goed: goed,
      veilig: veilig,
      isGoed: isGoed,
      fuelType: _fuelType,
      visitDate: EindbeoordelingDraft.parseDate(_visitDate),
    ));
  }

  void _onCompletePressed() {
    _debouncer.flush();
    if (_draft.toestelWerkingGoed == null ||
        _draft.toestelWerkingVeilig == null) {
      TacticalFeedback.showInfo(
          context, EindbeoordelingDictionary.toastValidationMissingConclusions);
      return;
    }
    TacticalFeedback.showSuccess(context, EindbeoordelingDictionary.toastSaved);
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }

    return EindbeoordelingTabBody(
      draft: _draft,
      fuelType: _fuelType,
      visitDate: _visitDate,
      boilerType: widget.boilerNotifier?.draft.centraalType ?? 'C',
      defectsController: _defectsController,
      remarksController: _remarksController,
      onGoedChanged: (val) => _updateConclusion(goed: val, isGoed: true),
      onVeiligChanged: (val) => _updateConclusion(veilig: val, isGoed: false),
      onDateChanged: (val) =>
          _saveDirect(_draft.copyWith(nextInspectionDate: val)),
      onDraftChanged: _saveDirect,
      onTextInputsChanged: _onTextInputsChanged,
      onCompletePressed: _onCompletePressed,
    );
  }
}
