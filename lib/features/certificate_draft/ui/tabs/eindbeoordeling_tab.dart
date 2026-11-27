// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart
// Responsibility: Tab 7 — Eindbeoordeling & Handtekeningen coordinator.

import 'package:flutter/material.dart';
import '../draft_save_scope.dart';
import '../../../reporting_delivery/ui/veka_tracker.dart';
import '../../../reporting_delivery/ui/veka_assessments.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import '../boiler_draft_notifier.dart';
import '../measurement_assessment_notifier.dart';
import 'eindbeoordeling/eindbeoordeling_loader.dart';
import 'eindbeoordeling/eindbeoordeling_pdf_actions.dart';
import 'eindbeoordeling/eindbeoordeling_tab_body.dart';

class EindbeoordelingTab extends StatefulWidget {
  final int visitId;
  final String certificateType;
  final BoilerDraftNotifier? boilerNotifier;
  final MeasurementAssessmentNotifier? assessmentNotifier;
  final VoidCallback? onComplete;
  final EindbeoordelingRepository? repositoryOverride;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const EindbeoordelingTab({
    super.key,
    required this.visitId,
    this.certificateType = 'verbranding',
    this.boilerNotifier,
    this.assessmentNotifier,
    this.onComplete,
    this.repositoryOverride,
    this.onFormKeyReady,
  });

  @override
  State<EindbeoordelingTab> createState() => _EindbeoordelingTabState();
}

class _EindbeoordelingTabState extends State<EindbeoordelingTab>
    with AutomaticKeepAliveClientMixin {
  late final EindbeoordelingRepository _repository;
  late final Debouncer _debouncer;

  final _formKey = GlobalKey<FormState>();
  final _defectsController = TextEditingController();
  final _remarksController = TextEditingController();
  final _remedialController = TextEditingController();

  EindbeoordelingDraft _draft = const EindbeoordelingDraft();
  String _fuelType = '';
  String _visitDate = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repositoryOverride ?? EindbeoordelingRepository();
    _debouncer = Debouncer(duration: const Duration(milliseconds: 350));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
    widget.boilerNotifier?.addListener(_onBoilerChanged);
    widget.assessmentNotifier?.addListener(_onAssessmentChanged);

    EindbeoordelingLoader.load(
      visitId: widget.visitId,
      repository: _repository,
      boilerNotifier: widget.boilerNotifier,
      assessmentNotifier: widget.assessmentNotifier,
      certificateType: widget.certificateType,
      onLoaded: (draft, fuel, date) {
        if (!mounted) return;
        setState(() {
          _draft = draft;
          _fuelType = fuel;
          _visitDate = date;
          _defectsController.text = draft.defectsNotes ?? '';
          _remarksController.text = draft.generalRemarks ?? '';
          _remedialController.text = draft.remedialMeasuresNotes ?? '';
        });
      },
    );
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
    _remedialController.dispose();
    super.dispose();
  }

  void _onBoilerChanged() {
    if (widget.boilerNotifier == null || !mounted) return;
    final newFuel = widget.boilerNotifier!.draft.fuelCategory;
    if (newFuel != _fuelType) {
      setState(() {
        _fuelType = newFuel;
        if (_draft.isGood && _draft.isSafe && newFuel.isNotEmpty) {
          final newDate = EindbeoordelingDraft.calculateStatutoryNextDate(
            fuelType: newFuel,
            fromDate: EindbeoordelingDraft.parseDate(_visitDate),
          );
          _draft = _draft.copyWith(nextInspectionDate: newDate ?? '');
        } else if (newFuel.isEmpty && !_draft.hasNegativeAssessment) {
          _draft = _draft.copyWith(nextInspectionDate: '');
        }
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

  void _saveDirect(EindbeoordelingDraft updated) {
    setState(() => _draft = updated);
    _queueSave(immediate: true);
  }

  void _queueSave({bool immediate = false}) {
    final visitId = widget.visitId;
    final draft = _draft.copyWith(
      defectsNotes: _defectsController.text,
      generalRemarks: _remarksController.text,
      remedialMeasuresNotes: widget.certificateType == 'reiniging'
          ? _remedialController.text
          : _draft.remedialMeasuresNotes,
    );
    Future<void> save() =>
        _repository.updateDraft(visitId: visitId, draft: draft);
    if (immediate) {
      _debouncer.runNow(save);
    } else {
      _debouncer.run(save);
    }
  }

  void _onTextInputsChanged() => _queueSave();

  void _updateConclusion({String? goed, String? veilig, required bool isGoed}) {
    _saveDirect(_draft.withUpdatedConclusions(
      goed: goed,
      veilig: veilig,
      isGoed: isGoed,
      fuelType: _fuelType,
      visitDate: EindbeoordelingDraft.parseDate(_visitDate),
    ));
  }

  Future<void> _onTestPdfPressed() => EindbeoordelingPdfActions.handleTestPdf(
        context,
        visitId: widget.visitId,
        certificateType: widget.certificateType,
        debouncer: _debouncer,
      );

  Future<void> _onSaveDevicePressed() =>
      EindbeoordelingPdfActions.handleSaveDevice(
        context,
        visitId: widget.visitId,
        certificateType: widget.certificateType,
        debouncer: _debouncer,
      );

  void _onCompletePressed() {
    _debouncer.flush();
    if (widget.certificateType == 'reiniging') {
      TacticalFeedback.showInfo(
        context,
        ReinigingDictionary.toastPdfNotYetAvailable,
      );
      return;
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    DraftSaveScope.of(context)?.register(_debouncer);
    final isReiniging = widget.certificateType == 'reiniging';

    return Form(
      key: _formKey,
      child: EindbeoordelingTabBody(
        draft: _draft,
        certificateType: widget.certificateType,
        fuelType: _fuelType,
        visitDate: _visitDate,
        boilerType: widget.boilerNotifier?.draft.centraalType ?? 'C',
        defectsController: _defectsController,
        remarksController: _remarksController,
        remedialController: _remedialController,
        onGoedChanged: (val) => _updateConclusion(goed: val, isGoed: true),
        onVeiligChanged: (val) => _updateConclusion(veilig: val, isGoed: false),
        onDateChanged: (val) =>
            _saveDirect(_draft.copyWith(nextInspectionDate: val)),
        onChimneyDateChanged: (val) =>
            _saveDirect(_draft.copyWith(nextChimneyInspectionDate: val)),
        onDraftChanged: _saveDirect,
        onTextInputsChanged: _onTextInputsChanged,
        onTestPdfPressed: _onTestPdfPressed,
        onSaveDevicePressed: _onSaveDevicePressed,
        onCompletePressed: _onCompletePressed,
        reporting: (isReiniging || DraftSaveScope.of(context) == null)
            ? null
            : VekaTracker(
                key: ValueKey(widget.visitId),
                visitId: widget.visitId,
                conformity: VekaAssessments(
                    visitId: widget.visitId, boiler: widget.boilerNotifier)),
      ),
    );
  }
}
