import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
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

  const MetingTab({
    super.key,
    this.visitId = 1,
    this.boilerNotifier,
    this.assessmentNotifier,
  });

  @override
  State<MetingTab> createState() => _MetingTabState();
}

class _MetingTabState extends State<MetingTab>
    with AutomaticKeepAliveClientMixin {
  final MeasurementDraftRepository _repository = MeasurementDraftRepository();
  final MetingFormControllers _controllers = MetingFormControllers();

  BoilerDraft _boiler = BoilerDraft.initial();
  OperatingConditionsDraft _operatingConditions =
      OperatingConditionsDraft.empty();
  String _activeSlot = 'proef1';
  bool _isLoading = true;
  final _debouncer = Debouncer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _boiler = widget.boilerNotifier!.draft;
        _controllers.autoEvaluateAllSlots(_boiler);
      });
      _syncAssessment();
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
      if (!mounted) return;
      setState(() => _populateInitialData(boiler, conditions, slots));
    } catch (e, stack) {
      debugPrint('[MetingTab] _loadInitialData error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onFormChanged() {
    _controllers.autoEvaluateAllSlots(_boiler);
    _syncAssessment();
    if (mounted) setState(() {});
    _debouncer.run(_saveToDatabase);
  }

  Future<void> _saveToDatabase() async {
    if (!mounted) return;
    try {
      final updated = _controllers.buildOperatingConditions(
        base: _operatingConditions,
        isLiquidFuel: _boiler.fuelCategory == 'vloeibaar',
      );
      await _repository.saveOperatingConditions(widget.visitId, updated);
      if (!mounted) return;
      _operatingConditions = updated;
      final slotCtrl = _controllers.slots[_activeSlot];
      if (slotCtrl != null) {
        await _repository.saveMeasurementSlot(
            widget.visitId, slotCtrl.buildDraft(_activeSlot));
      }
    } catch (e, stack) {
      debugPrint('[MetingTab] _saveToDatabase error: $e\n$stack');
    }
  }

  void _trigger(Function fn) => fn(
        context: context,
        repository: _repository,
        visitId: widget.visitId,
        controllers: _controllers,
        activeSlot: _activeSlot,
        onFormChanged: _onFormChanged,
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final slotCtrl =
        _controllers.slots[_activeSlot] ?? _controllers.slots['proef1']!;
    final p1HasData = _controllers.slots['proef1']?.hasAnyValues ?? false;
    final p2Laag = _controllers.slots['proef2_laaglast']?.hasAnyValues ?? false;
    final p2Hoog = _controllers.slots['proef2_hooglast']?.hasAnyValues ?? false;

    return WorkflowTabContainer(
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
        const SizedBox(height: AppTheme.bentoCardSpacing),
        MeasurementSlotsCard(
          boiler: _boiler,
          activeSlot: _activeSlot,
          onSlotChanged: (s) => setState(() => _activeSlot = s),
          onCopyFromDataTab: () => _trigger(MetingSlotActions.copyFromDataTab),
          onScanEurolyzer: () => _trigger(MetingSlotActions.scanEurolyzer),
          onClearSlot: () => _trigger(MetingSlotActions.clearSlot),
          canClear: slotCtrl.hasAnyValues,
          proef1HasData: p1HasData,
          proef2HasData: p2Laag || p2Hoog,
          proef2LaagHasData: p2Laag,
          proef2HoogHasData: p2Hoog,
          o2Controller: slotCtrl.o2,
          co2Controller: slotCtrl.co2,
          coMgKwhController: slotCtrl.coMgKwh,
          coOk: slotCtrl.coOk,
          onCoOkChanged: (v) {
            setState(() => slotCtrl.setManualCoOk(v, _boiler));
            _onFormChanged();
          },
          flueTempTgController: slotCtrl.flueTempTg,
          ambientTempTaController: slotCtrl.ambientTempTa,
          calculatedNetTemp: slotCtrl.calculatedNetTemp,
          efficiencyHiController: slotCtrl.efficiencyHi,
          efficiencyHiOk: slotCtrl.efficiencyHiOk,
          onEfficiencyHiOkChanged: (v) {
            setState(() => slotCtrl.setManualHiOk(v, _boiler));
            _onFormChanged();
          },
          efficiencyHsController: slotCtrl.efficiencyHs,
          onChanged: _onFormChanged,
        ),
        const SizedBox(height: AppTheme.bentoCardSpacing),
        SafetyChecksCard(
          boiler: _boiler,
          draft: _operatingConditions,
          onDraftChanged: (updated) {
            setState(() => _operatingConditions = updated);
            _onFormChanged();
          },
        ),
      ],
    );
  }
}
