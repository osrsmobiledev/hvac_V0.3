import 'package:flutter/material.dart';
import '../../../domain/boiler_draft.dart';
import '../../../domain/combustion_statutory_rules.dart';
import '../../../domain/measurement_slot_draft.dart';

/// Form controllers for a single measurement slot.
class SlotFormControllers {
  final TextEditingController o2 = TextEditingController();
  final TextEditingController co2 = TextEditingController();
  final TextEditingController coMgKwh = TextEditingController();
  final TextEditingController flueTempTg = TextEditingController();
  final TextEditingController ambientTempTa = TextEditingController();
  final TextEditingController efficiencyHi = TextEditingController();
  final TextEditingController efficiencyHs = TextEditingController();

  bool? coOk;
  bool? efficiencyHiOk;
  double? fluePressurePa;
  String _lastEvaluatedCo = '';
  String _lastEvaluatedHi = '';

  static double? parseClean(String? text) =>
      CombustionStatutoryRules.parseNumeric(text);

  void populate(MeasurementSlotDraft draft) {
    o2.text = draft.o2Percent != null ? '${draft.o2Percent} %' : '';
    co2.text = draft.co2Percent != null ? '${draft.co2Percent} %' : '';
    coMgKwh.text = draft.coMgKwh?.toString() ?? '';
    coOk = draft.coOk ?? draft.suggestedCoOk;
    _lastEvaluatedCo = coMgKwh.text.trim();
    flueTempTg.text = draft.flueTempTg != null ? '${draft.flueTempTg} °C' : '';
    ambientTempTa.text =
        draft.ambientTempTa != null ? '${draft.ambientTempTa} °C' : '';
    efficiencyHi.text = draft.efficiencyHi?.toString() ?? '';
    efficiencyHiOk = draft.efficiencyHiOk ?? draft.suggestedHiOk;
    _lastEvaluatedHi = efficiencyHi.text.trim();
    efficiencyHs.text =
        draft.efficiencyHs != null ? '${draft.efficiencyHs} %' : '';
    fluePressurePa = draft.fluePressurePa;
  }

  void clear() {
    o2.clear();
    co2.clear();
    coMgKwh.clear();
    coOk = null;
    _lastEvaluatedCo = '';
    flueTempTg.clear();
    ambientTempTa.clear();
    efficiencyHi.clear();
    efficiencyHiOk = null;
    _lastEvaluatedHi = '';
    efficiencyHs.clear();
    fluePressurePa = null;
  }

  void autoEvaluateCompliance(BoilerDraft boiler) {
    final currentCo = coMgKwh.text.trim();
    if (currentCo != _lastEvaluatedCo) {
      _lastEvaluatedCo = currentCo;
      final coVal = CombustionStatutoryRules.parseNumeric(currentCo);
      coOk = CombustionStatutoryRules.evaluateCo(coVal, boiler);
    }

    final currentHi = efficiencyHi.text.trim();
    if (currentHi != _lastEvaluatedHi) {
      _lastEvaluatedHi = currentHi;
      final hiVal = CombustionStatutoryRules.parseNumeric(currentHi);
      efficiencyHiOk =
          CombustionStatutoryRules.evaluateEfficiencyHi(hiVal, boiler);
    }
  }

  void setManualCoOk(bool? val, BoilerDraft boiler) {
    coOk = val;
    if (val == null) {
      _lastEvaluatedCo = '';
      autoEvaluateCompliance(boiler);
    }
  }

  void setManualHiOk(bool? val, BoilerDraft boiler) {
    efficiencyHiOk = val;
    if (val == null) {
      _lastEvaluatedHi = '';
      autoEvaluateCompliance(boiler);
    }
  }

  bool get hasAnyValues =>
      o2.text.trim().isNotEmpty ||
      co2.text.trim().isNotEmpty ||
      coMgKwh.text.trim().isNotEmpty ||
      flueTempTg.text.trim().isNotEmpty ||
      ambientTempTa.text.trim().isNotEmpty ||
      efficiencyHi.text.trim().isNotEmpty ||
      efficiencyHs.text.trim().isNotEmpty ||
      coOk != null ||
      efficiencyHiOk != null ||
      fluePressurePa != null;

  String get calculatedNetTemp {
    final tg = parseClean(flueTempTg.text);
    final ta = parseClean(ambientTempTa.text);
    if (tg != null && ta != null) {
      return (tg - ta).toStringAsFixed(1);
    }
    return '';
  }

  MeasurementSlotDraft buildDraft(String slot) {
    return MeasurementSlotDraft(
      slot: slot,
      o2Percent: parseClean(o2.text),
      co2Percent: parseClean(co2.text),
      coMgKwh: parseClean(coMgKwh.text),
      coOk: coOk,
      flueTempTg: parseClean(flueTempTg.text),
      ambientTempTa: parseClean(ambientTempTa.text),
      netTemp: parseClean(calculatedNetTemp),
      efficiencyHi: parseClean(efficiencyHi.text),
      efficiencyHiOk: efficiencyHiOk,
      efficiencyHs: parseClean(efficiencyHs.text),
      fluePressurePa: fluePressurePa,
    );
  }

  void dispose() {
    o2.dispose();
    co2.dispose();
    coMgKwh.dispose();
    flueTempTg.dispose();
    ambientTempTa.dispose();
    efficiencyHi.dispose();
    efficiencyHs.dispose();
  }
}
