import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/combustion_statutory_rules.dart';

void main() {
  group('CombustionStatutoryRules Unit Tests', () {
    test(
        'Liquid fuel (Stookolie): min efficiency Hi is 90% and max CO is 150 mg/kWh',
        () {
      const boiler = BoilerDraft(
        fuelCategory: 'vloeibaar',
        fuelSubtype: 'stookolie',
      );

      expect(CombustionStatutoryRules.minEfficiencyHi(boiler), 90.0);
      expect(CombustionStatutoryRules.maxCoMgKwh(boiler), 150.0);

      // CO evaluation
      expect(CombustionStatutoryRules.evaluateCo(149.0, boiler), isTrue);
      expect(CombustionStatutoryRules.evaluateCo(150.0, boiler), isTrue);
      expect(CombustionStatutoryRules.evaluateCo(151.0, boiler), isFalse);

      // Efficiency Hi evaluation
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(89.9, boiler), isFalse);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(90.0, boiler), isTrue);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(93.4, boiler), isTrue);
    });

    test('Gas Type B (B1): min efficiency Hi is 88% and max CO is 150 mg/kWh',
        () {
      const boiler = BoilerDraft(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B11BS',
      );

      expect(CombustionStatutoryRules.minEfficiencyHi(boiler), 88.0);
      expect(CombustionStatutoryRules.maxCoMgKwh(boiler), 150.0);

      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(87.9, boiler), isFalse);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(88.0, boiler), isTrue);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(91.0, boiler), isTrue);
    });

    test(
        'Gas Type B2 (B23P): min efficiency Hi is 90% (non-B1 appliance under VLAREM)',
        () {
      const boiler = BoilerDraft(
        fuelCategory: 'gas',
        centraalType: 'B',
        typeBText: 'B23P',
      );

      // B23P has a mechanical fan and no draft hood -> legally Non-B1 (min 90%)
      expect(CombustionStatutoryRules.minEfficiencyHi(boiler), 90.0);
      expect(CombustionStatutoryRules.maxCoMgKwh(boiler), 150.0);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(89.5, boiler), isFalse);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(90.0, boiler), isTrue);
    });

    test(
        'Gas Type C (Condenserend): min efficiency Hi is 90% and max CO is 150 mg/kWh',
        () {
      const boiler = BoilerDraft(
        fuelCategory: 'gas',
        centraalType: 'C',
        boilerOperation: 'condenserend',
      );

      expect(CombustionStatutoryRules.minEfficiencyHi(boiler), 90.0);
      expect(CombustionStatutoryRules.maxCoMgKwh(boiler), 150.0);

      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(89.5, boiler), isFalse);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(90.0, boiler), isTrue);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(98.6, boiler), isTrue);
    });

    test('Solid fuel: min efficiency Hi is 80% and max CO is 500 mg/m3', () {
      const boiler = BoilerDraft(
        fuelCategory: 'vast',
        fuelSubtype: 'houtpellets',
      );

      expect(CombustionStatutoryRules.minEfficiencyHi(boiler), 80.0);
      expect(CombustionStatutoryRules.maxCoMgKwh(boiler), 500.0);

      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(79.0, boiler), isFalse);
      expect(
          CombustionStatutoryRules.evaluateEfficiencyHi(80.0, boiler), isTrue);
    });

    test('parseNumeric handles comma and dot decimal separators gracefully',
        () {
      expect(CombustionStatutoryRules.parseNumeric('98.4'), 98.4);
      expect(CombustionStatutoryRules.parseNumeric('98,4'), 98.4);
      expect(CombustionStatutoryRules.parseNumeric('  150  '), 150.0);
      expect(CombustionStatutoryRules.parseNumeric(''), isNull);
      expect(CombustionStatutoryRules.parseNumeric(null), isNull);
      expect(CombustionStatutoryRules.parseNumeric('abc'), isNull);
    });
  });
}
