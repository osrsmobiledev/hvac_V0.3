import 'package:flutter/material.dart';
import '../draft_save_scope.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import 'package:hvac_app/features/certificate_draft/data/measurement_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/operating_conditions_draft.dart';
import '../boiler_draft_notifier.dart';
import '../measurement_assessment_notifier.dart';
import 'meting/measurement_slots_card.dart';
import 'meting/meting_form_controllers.dart';
import 'meting/meting_fuel_banner.dart';
import 'meting/meting_slot_actions.dart';
import 'meting/operating_conditions_card.dart';
import 'meting/safety_checks_card.dart';

/// Tab 6: Meting (Combustion measurements & safety checks).
class MetingTab extends StatefulWidget {
  final int visitId;
  final BoilerDraftNotifier? boilerNotifier;
  final MeasurementAssessmentNotifier? assessmentNotifier;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;
  const MetingTab({
    super.key,
    this.visitId = 1,
    this.boilerNotifier,
    this.assessmentNotifier,
    this.onFormKeyReady,
  });
  @override
  State<MetingTab> createState() => _MetingTabState();
}

class _MetingTabState extends State<MetingTab>
    with AutomaticKeepAliveClientMixin {
  final MeasurementDraftRepository _repository = MeasurementDraftRepository();
  final MetingFormControllers _controllers = MetingFormControllers();

  final _formKey = GlobalKey<FormState>();
  BoilerDraft _boiler = BoilerDraft.initial();
  OperatingConditionsDraft _operatingConditions =
      OperatingConditionsDraft.empty();
  var _activeSlot = 'proef1';
  bool _isLoading = true;
  final _debouncer = Debouncer();
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onFormKeyReady?.call(_formKey));
    widget.boilerNotifier?.addListener(_onBoilerChanged);
    final cached = AppWarmupService.instance.cachedResult;
    if (cached?.operatingConditions != null &&
        cached?.measurementSlots != null) {
      final boiler = widget.boilerNotifier?.draft ??
          cached!.activeBoiler ??
          BoilerDraft.initial();
      _populateInitialData(
          boiler, cached!.operatingConditions!, cached.measurementSlots!);
    } else {
      _loadInitialData();
    }
  }

  void _populateInitialData(
    BoilerDraft boiler,
    OperatingConditionsDraft conditions,
    Map<String, MeasurementSlotDraft> slots,
  ) {
    _boiler = boiler;
    _operatingConditions = conditions;
    _controllers.populateOperatingConditions(conditions);
    slots.forEach((k, v) => _controllers.slots[k]?.populate(v));
    _controllers.autoEvaluateAllSlots(_boiler);
    _syncAssessment();
    _isLoading = false;
  }

  @override
  void didUpdateWidget(covariant MetingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boilerNotifier != widget.boilerNotifier) {
      oldWidget.boilerNotifier?.removeListener(_onBoilerChanged);
      widget.boilerNotifier?.addListener(_onBoilerChanged);
    }
  }

  @override
  void dispose() {
    widget.boilerNotifier?.removeListener(_onBoilerChanged);
    _debouncer.dispose();
    _controllers.dispose();
    super.dispose();
  }

  void _onBoilerChanged() {
    if (widget.boilerNotifier != null && mounted) {
      final next = widget.boilerNotifier!.draft;
      final fuelChanged = next.fuelCategory != _boiler.fuelCategory ||
          next.fuelSubtype != _boiler.fuelSubtype;
      setState(() {
        _boiler = next;
        _controllers.autoEvaluateAllSlots(_boiler);
        if (fuelChanged) {
          _controllers.verbrandingscontroleOverride = null;
        }
      });
      _syncAssessment();
      if (fuelChanged && !_isLoading) _queueSave();
    }
  }

  void _syncAssessment() {
    final isLiquid = _boiler.fuelCategory == 'vloeibaar';
    widget.assessmentNotifier?.updateAssessment(
      combustionPassed:
          _controllers.decisiveCombustionConform(isLiquidFuel: isLiquid),
      safetyChecksPassed:
          _controllers.safetyChecksConform(_operatingConditions, _boiler),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      final boiler = widget.boilerNotifier?.draft ??
          await _repository.loadActiveBoilerDraft();
      final conditions =
          await _repository.loadOperatingConditions(widget.visitId);
      final slots = await _repository.loadMeasurementSlots(widget.visitId);
      if (mounted) {
        setState(() => _populateInitialData(boiler, conditions, slots));
      }
    } catch (e, stack) {
      debugPrint('[MetingTab] _loadInitialData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFormChanged() {
    _controllers.autoEvaluateAllSlots(_boiler);
    _syncAssessment();
    if (mounted) setState(() {});
    _queueSave();
  }

  void _queueSave() {
    final visitId = widget.visitId;
    _operatingConditions = _controllers.buildOperatingConditions(
      base: _operatingConditions,
      isLiquidFuel: _boiler.fuelCategory == 'vloeibaar',
    );
    final conditions = _operatingConditions;
    final slots = {
      for (final entry in _controllers.slots.entries)
        entry.key:
            entry.value.hasAnyValues ? entry.value.buildDraft(entry.key) : null,
    };
    _debouncer.run(() => _repository.saveMeting(visitId, conditions, slots));
  }

  void _trigger(Function fn) => fn(
      context: context,
      repository: _repository,
      visitId: widget.visitId,
      controllers: _controllers,
      activeSlot: _activeSlot,
      onFormChanged: _onFormChanged);
  @override
  Widget build(BuildContext context) {
    super.build(context);
    DraftSaveScope.of(context)?.register(_debouncer);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    bool hasData(String slot) =>
        _controllers.slots[slot]?.hasAnyValues ?? false;
    final p2Laag = hasData('proef2_laaglast');
    final p2Hoog = hasData('proef2_hooglast');
    return Form(
      key: _formKey,
      child: WorkflowTabContainer(
        scrollKey: 'meting_tab_scroll',
        children: [
          MetingFuelBanner(boiler: _boiler),
          OperatingConditionsCard(
            boiler: _boiler,
            boilerTempController: _controllers.boilerTemp,
            gasMeterController: _controllers.gasMeter,
            gasBlockController: _controllers.gasBlock,
            gasBurnerBedController: _controllers.gasBurnerBed,
            nozzleBrandTypeController: _controllers.nozzleBrandType,
            nozzleFlowRateController: _controllers.nozzleFlowRate,
            nozzleAngleController: _controllers.nozzleAngle,
            pumpPressureController: _controllers.pumpPressure,
            smokeIndexController: _controllers.smokeIndex,
            smokeIndexOk: _controllers.smokeIndexOk,
            onSmokeIndexOkChanged: (v) {
              setState(() => _controllers.smokeIndexOk = v);
              _onFormChanged();
            },
            onChanged: _onFormChanged,
          ),
          MeasurementSlotsCard(
            boiler: _boiler,
            activeSlot: _activeSlot,
            onSlotChanged: (s) {
              _debouncer.flush();
              setState(() => _activeSlot = s);
            },
            slots: _controllers.slots,
            onCopyFromDataTab: () =>
                _trigger(MetingSlotActions.copyFromDataTab),
            onScanEurolyzer: () => _trigger(MetingSlotActions.scanEurolyzer),
            onClearSlot: () => _trigger(MetingSlotActions.clearSlot),
            canClear: hasData(_activeSlot),
            proef1HasData: hasData('proef1'),
            proef2HasData: p2Laag || p2Hoog,
            proef2LaagHasData: p2Laag,
            proef2HoogHasData: p2Hoog,
            onChanged: _onFormChanged,
          ),
          SafetyChecksCard(
            boiler: _boiler,
            draft: _operatingConditions,
            onDraftChanged: (updated) {
              setState(() => _operatingConditions = updated);
              _onFormChanged();
            },
          ),
        ],
      ),
    );
  }
}
