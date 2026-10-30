import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/operating_conditions_draft.dart';

void main() {
  group('Slice 3.2 — MeasurementSlotDraft Unit Tests', () {
    test('Default empty slot has expected defaults', () {
      final slot = MeasurementSlotDraft.empty('proef1');
      expect(slot.slot, 'proef1');
      expect(slot.o2Percent, isNull);
      expect(slot.co2Percent, isNull);
      expect(slot.coMgKwh, isNull);
      expect(slot.effectiveNetTemp, isNull);
      expect(slot.suggestedCoOk, isNull);
      expect(slot.suggestedHiOk, isNull);
    });

    test('Automatically calculates net temperature (tg - ta)', () {
      const slot = MeasurementSlotDraft(
        slot: 'proef1',
        flueTempTg: 54.2,
        ambientTempTa: 19.8,
      );

      expect(slot.effectiveNetTemp, 34.4);
    });

    test('Statutory compliance suggestions evaluate CO and Hi correctly', () {
      // Compliant reading (CO <= 100 mg/kWh, Hi >= 90%)
      const compliantSlot = MeasurementSlotDraft(
        slot: 'proef1',
        coMgKwh: 25.0,
        efficiencyHi: 98.4,
      );
      expect(compliantSlot.suggestedCoOk, isTrue);
      expect(compliantSlot.suggestedHiOk, isTrue);
      expect(compliantSlot.effectiveCoOk, isTrue);
      expect(compliantSlot.effectiveHiOk, isTrue);

      // Non-compliant reading (CO > 150 mg/kWh, Hi < 90%)
      const nonCompliantSlot = MeasurementSlotDraft(
        slot: 'proef1',
        coMgKwh: 175.0,
        efficiencyHi: 86.0,
      );
      expect(nonCompliantSlot.suggestedCoOk, isFalse);
      expect(nonCompliantSlot.suggestedHiOk, isFalse);
      expect(nonCompliantSlot.effectiveCoOk, isFalse);
      expect(nonCompliantSlot.effectiveHiOk, isFalse);

      // Manual technician override takes precedence over suggestion
      final manualOverrideSlot = nonCompliantSlot.copyWith(
        coOk: true, // Technician explicitly verified
      );
      expect(manualOverrideSlot.suggestedCoOk, isFalse);
      expect(manualOverrideSlot.effectiveCoOk, isTrue);
    });

    test('Serialization toMap and fromMap preserves all fields', () {
      const original = MeasurementSlotDraft(
        slot: 'proef2_laaglast',
        o2Percent: 4.8,
        co2Percent: 9.2,
        coMgKwh: 24.5,
        coOk: true,
        flueTempTg: 54.2,
        ambientTempTa: 19.8,
        netTemp: 34.4,
        efficiencyHi: 98.4,
        efficiencyHiOk: true,
        efficiencyHs: 88.6,
        fluePressurePa: 12.0,
      );

      final map = original.toMap(1);
      final restored = MeasurementSlotDraft.fromMap(map);

      expect(restored.slot, 'proef2_laaglast');
      expect(restored.o2Percent, 4.8);
      expect(restored.co2Percent, 9.2);
      expect(restored.coMgKwh, 24.5);
      expect(restored.coOk, isTrue);
      expect(restored.flueTempTg, 54.2);
      expect(restored.ambientTempTa, 19.8);
      expect(restored.netTemp, 34.4);
      expect(restored.efficiencyHi, 98.4);
      expect(restored.efficiencyHiOk, isTrue);
      expect(restored.efficiencyHs, 88.6);
      expect(restored.fluePressurePa, 12.0);
    });
  });

  group('Slice 3.2 — OperatingConditionsDraft Unit Tests', () {
    test('Default empty operating conditions has null fields', () {
      final draft = OperatingConditionsDraft.empty();
      expect(draft.boilerTempCelsius, isNull);
      expect(draft.gasPressureMeterMbar, isNull);
      expect(draft.fluePressureOk, isNull);
      expect(draft.ventilationOk, isNull);
    });

    test('Serialization toMap and fromMap preserves all fields', () {
      const original = OperatingConditionsDraft(
        boilerTempCelsius: 65.0,
        gasPressureMeterMbar: 22.5,
        gasPressureBlockMbar: 18.2,
        gasPressureBurnerBedMbar: 10.4,
        nozzleBrandType: 'Danfoss 0.60 60S',
        nozzleFlowRate: '0.60 USgal/h',
        nozzleAngleDegrees: 60.0,
        pumpPressureBar: 11.5,
        smokeIndexBacharach: 0,
        smokeIndexOk: true,
        noOilTraceOk: true,
        noUnwantedCondensationOk: true,
        rarelyPollutingSmokeOk: null,
        fluePressureOk: true,
        ventilationOk: true,
        flueTightnessOk: true,
        fuelSupplyTightnessOk: true,
      );

      final map = original.toMap();
      final restored = OperatingConditionsDraft.fromMap(map);

      expect(restored.boilerTempCelsius, 65.0);
      expect(restored.gasPressureMeterMbar, 22.5);
      expect(restored.nozzleBrandType, 'Danfoss 0.60 60S');
      expect(restored.smokeIndexBacharach, 0);
      expect(restored.smokeIndexOk, isTrue);
      expect(restored.noOilTraceOk, isTrue);
      expect(restored.noUnwantedCondensationOk, isTrue);
      expect(restored.fluePressureOk, isTrue);
      expect(restored.ventilationOk, isTrue);
      expect(restored.flueTightnessOk, isTrue);
      expect(restored.fuelSupplyTightnessOk, isTrue);
    });
  });
}
