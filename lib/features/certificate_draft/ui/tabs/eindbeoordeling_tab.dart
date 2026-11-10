// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling_tab.dart
// Responsibility: Tab 7 — Eindbeoordeling & Handtekeningen coordinator.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/features/certificate_draft/data/eindbeoordeling_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/pdf_export/combustion_pdf_generator.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_data_mapper.dart';
import 'package:hvac_app/features/pdf_export/services/pdf_file_saver.dart';
import 'package:hvac_app/features/pdf_export/ui/pdf_preview_dialog.dart';
import '../boiler_draft_notifier.dart';
import '../measurement_assessment_notifier.dart';
import 'eindbeoordeling/eindbeoordeling_loader.dart';
import 'eindbeoordeling/eindbeoordeling_tab_body.dart';

class EindbeoordelingTab extends StatefulWidget {
  final int visitId;
  final BoilerDraftNotifier? boilerNotifier;
  final MeasurementAssessmentNotifier? assessmentNotifier;
  final VoidCallback? onComplete;
  final EindbeoordelingRepository? repositoryOverride;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const EindbeoordelingTab({
    super.key,
    required this.visitId,
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
      onLoaded: (draft, fuel, date) {
        if (!mounted) return;
        setState(() {
          _draft = draft;
          _fuelType = fuel;
          _visitDate = date;
          _defectsController.text = draft.defectsNotes ?? '';
          _remarksController.text = draft.generalRemarks ?? '';
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

  Future<void> _onTestPdfPressed() async {
    _debouncer.flush();
    final data = await PdfDataMapper.loadVisitData(widget.visitId);
    if (!mounted) return;
    await PdfPreviewDialog.show(context, data);
  }

  Future<void> _onSaveDevicePressed() async {
    _debouncer.flush();
    final data = await PdfDataMapper.loadVisitData(widget.visitId);
    final pdfBytes = await CombustionPdfGenerator.generateCertificate(data);
    final result = await PdfFileSaver.saveToDevice(
      pdfBytes: pdfBytes,
      attestNumber: data.volgnummerAttest,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      TacticalFeedback.showSuccess(
        context,
        '${EindbeoordelingDictionary.toastPdfSaved}${result.filePath}',
        duration: const Duration(seconds: 4),
      );
    } else {
      TacticalFeedback.showError(
        context,
        '${EindbeoordelingDictionary.toastPdfSaveFailed}${result.errorMessage}',
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _onCompletePressed() {
    _debouncer.flush();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: _formKey,
      child: EindbeoordelingTabBody(
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
        onTestPdfPressed: _onTestPdfPressed,
        onSaveDevicePressed: _onSaveDevicePressed,
        onCompletePressed: _onCompletePressed,
      ),
    );
  }
}
