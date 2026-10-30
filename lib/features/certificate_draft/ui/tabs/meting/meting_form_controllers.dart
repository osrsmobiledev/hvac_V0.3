import 'package:flutter/material.dart';
import '../../../domain/boiler_draft.dart';
import '../../../domain/operating_conditions_draft.dart';
import 'slot_form_controllers.dart';

export 'slot_form_controllers.dart';

/// Centralized controllers and state coordinator for Tab 6 (Meting).
class MetingFormControllers {
  final TextEditingController boilerTemp = TextEditingController();

  // Gas controllers
  final TextEditingController gasMeter = TextEditingController();
  final TextEditingController gasBlock = TextEditingController();
  final TextEditingController gasBurnerBed = TextEditingController();

  // Liquid / Oil controllers
  final TextEditingController nozzleBrandType = TextEditingController();
  final TextEditingController nozzleFlowRate = TextEditingController();
  final TextEditingController nozzleAngle = TextEditingController();
  final TextEditingController pumpPressure = TextEditingController();
  final TextEditingController smokeIndex = TextEditingController();
  bool? smokeIndexOk;

  // Separate controllers per slot
  final Map<String, SlotFormControllers> slots = {
    'proef1': SlotFormControllers(),
    'proef2_laaglast': SlotFormControllers(),
    'proef2_hooglast': SlotFormControllers(),
  };

  // Master override for the visit (null = auto, true = OK, false = NOK)
  bool? verbrandingscontroleOverride;

  void autoEvaluateAllSlots(BoilerDraft boiler) {
    for (final s in slots.values) {
      s.autoEvaluateCompliance(boiler);
    }
  }

  void populateOperatingConditions(OperatingConditionsDraft draft) {
    boilerTemp.text = draft.boilerTempCelsius?.toString() ?? '';
    gasMeter.text = draft.gasPressureMeterMbar?.toString() ?? '';
    gasBlock.text = draft.gasPressureBlockMbar?.toString() ?? '';
    gasBurnerBed.text = draft.gasPressureBurnerBedMbar?.toString() ?? '';
    nozzleBrandType.text = draft.nozzleBrandType ?? '';
    nozzleFlowRate.text = draft.nozzleFlowRate ?? '';
    nozzleAngle.text = draft.nozzleAngleDegrees?.toString() ?? '';
    pumpPressure.text = draft.pumpPressureBar?.toString() ?? '';
    smokeIndex.text = draft.smokeIndexBacharach?.toString() ?? '';
    smokeIndexOk = draft.smokeIndexOk;
  }

  /// Auto-derives official VEKA compliance from decisive slot.
  /// Proef II is legally decisive if entered; otherwise evaluates Proef I.
  bool? autoCombustionConform({bool isLiquidFuel = false}) {
    final laag = slots['proef2_laaglast'];
    final hoog = slots['proef2_hooglast'];
    final p1 = slots['proef1'];

    final bool p2HasData =
        (laag?.hasAnyValues ?? false) || (hoog?.hasAnyValues ?? false);

    if (p2HasData) {
      if (laag?.coOk == false || laag?.efficiencyHiOk == false) {
        return false;
      }
      if (hoog != null &&
          hoog.hasAnyValues &&
          (hoog.coOk == false || hoog.efficiencyHiOk == false)) {
        return false;
      }
      if (isLiquidFuel && smokeIndexOk == false) {
        return false;
      }

      if (laag?.coOk == true && laag?.efficiencyHiOk == true) {
        if (hoog != null &&
            hoog.hasAnyValues &&
            (hoog.coOk != true || hoog.efficiencyHiOk != true)) {
          return null;
        }
        if (isLiquidFuel && smokeIndexOk != true) {
          return null;
        }
        return true;
      }
      return null;
    }

    if (p1?.hasAnyValues ?? false) {
      if (p1?.coOk == false || p1?.efficiencyHiOk == false) return false;
      if (isLiquidFuel && smokeIndexOk == false) return false;
      if (p1?.coOk == true && p1?.efficiencyHiOk == true) {
        if (isLiquidFuel && smokeIndexOk != true) return null;
        return true;
      }
    }
    return null;
  }

  /// Authoritative combustion compliance verdict for the visit.
  bool? decisiveCombustionConform({bool isLiquidFuel = false}) =>
      verbrandingscontroleOverride ??
      autoCombustionConform(isLiquidFuel: isLiquidFuel);

  /// Derives official VEKA [verbrandingscontrole] string ('OK' / 'NOK').
  String? deriveVerbrandingscontrole({bool isLiquidFuel = false}) {
    final status = decisiveCombustionConform(isLiquidFuel: isLiquidFuel);
    if (status == true) return 'OK';
    if (status == false) return 'NOK';
    return null;
  }

  OperatingConditionsDraft buildOperatingConditions({
    required OperatingConditionsDraft base,
    bool isLiquidFuel = false,
  }) {
    int? parseInt(String text) => int.tryParse(text.trim());

    return base.copyWith(
      boilerTempCelsius: SlotFormControllers.parseClean(boilerTemp.text),
      gasPressureMeterMbar: SlotFormControllers.parseClean(gasMeter.text),
      gasPressureBlockMbar: SlotFormControllers.parseClean(gasBlock.text),
      gasPressureBurnerBedMbar:
          SlotFormControllers.parseClean(gasBurnerBed.text),
      nozzleBrandType: nozzleBrandType.text.trim(),
      nozzleFlowRate: nozzleFlowRate.text.trim(),
      nozzleAngleDegrees: SlotFormControllers.parseClean(nozzleAngle.text),
      pumpPressureBar: SlotFormControllers.parseClean(pumpPressure.text),
      smokeIndexBacharach: parseInt(smokeIndex.text),
      smokeIndexOk: smokeIndexOk,
      verbrandingscontrole:
          deriveVerbrandingscontrole(isLiquidFuel: isLiquidFuel),
    );
  }

  void dispose() {
    boilerTemp.dispose();
    gasMeter.dispose();
    gasBlock.dispose();
    gasBurnerBed.dispose();
    nozzleBrandType.dispose();
    nozzleFlowRate.dispose();
    nozzleAngle.dispose();
    pumpPressure.dispose();
    smokeIndex.dispose();
    for (final s in slots.values) {
      s.dispose();
    }
  }
}
