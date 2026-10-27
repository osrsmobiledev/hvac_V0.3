import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';

void main() {
  group('Slice 3.1 — BoilerDraft Domain Model', () {
    test('Default initial model has expected regulatory defaults', () {
      final draft = BoilerDraft.initial();

      expect(draft.isCentral, isTrue);
      expect(draft.centraalType, 'C');
      expect(draft.heatingType, 'individueel');
      expect(draft.boilerOperation, 'condenserend');
      expect(draft.fuelCategory, 'gas');
      expect(draft.fuelSubtype, 'aardgas');
      expect(draft.burnerTechnology, 'premix');
      expect(draft.boilerSerialNumberUnknown, isFalse);
    });

    test('Serialization toMap and fromMap preserves all fields', () {
      const draft = BoilerDraft(
        id: 42,
        serviceLocationId: 10,
        isCentral: true,
        centraalType: 'C',
        typeCText: 'C13',
        heatingType: 'individueel',
        boilerOperation: 'condenserend',
        fuelCategory: 'gas',
        fuelSubtype: 'aardgas',
        burnerTechnology: 'premix',
        boilerBrand: 'Vaillant',
        boilerModel: 'ecoTEC plus',
        boilerConstructionYear: 2022,
        boilerSerialNumber: 'SN123456789',
        boilerNominalPowerKw: 24.5,
        burnerBrand: 'Integrated',
      );

      final map = draft.toMap();
      final restored = BoilerDraft.fromMap(map);

      expect(restored.id, 42);
      expect(restored.serviceLocationId, 10);
      expect(restored.isCentral, isTrue);
      expect(restored.centraalType, 'C');
      expect(restored.typeCText, 'C13');
      expect(restored.fuelCategory, 'gas');
      expect(restored.boilerBrand, 'Vaillant');
      expect(restored.boilerModel, 'ecoTEC plus');
      expect(restored.boilerConstructionYear, 2022);
      expect(restored.boilerSerialNumber, 'SN123456789');
      expect(restored.boilerNominalPowerKw, 24.5);
    });

    test(
        'Effective burner getters return "/" for integrated burner and raw values for separate burner',
        () {
      // Integrated burner default: empty fields become '/' for official PDF
      final integratedDraft = BoilerDraft.initial();
      expect(integratedDraft.burnerType, 'geintegreerd');
      expect(integratedDraft.effectiveBurnerBrand, '/');
      expect(integratedDraft.effectiveBurnerModel, '/');
      expect(integratedDraft.effectiveBurnerYear, '/');
      expect(integratedDraft.effectiveBurnerSerialNumber, '/');
      expect(integratedDraft.effectiveBurnerFlowRate, '/');

      // Separate burner with actual values
      const separateDraft = BoilerDraft(
        burnerType: 'afzonderlijk',
        burnerBrand: 'Weishaupt',
        burnerModel: 'WL5/1-B',
        burnerConstructionYear: 2019,
        burnerSerialNumber: 'SN987654',
        burnerFlowRate: '2.4 kg/h',
      );
      expect(separateDraft.effectiveBurnerBrand, 'Weishaupt');
      expect(separateDraft.effectiveBurnerModel, 'WL5/1-B');
      expect(separateDraft.effectiveBurnerYear, '2019');
      expect(separateDraft.effectiveBurnerSerialNumber, 'SN987654');
      expect(separateDraft.effectiveBurnerFlowRate, '2.4 kg/h');
    });
  });
}
