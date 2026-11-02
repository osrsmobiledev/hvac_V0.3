// File: test/eindbeoordeling_draft_test.dart
// Responsibility: Unit tests for Slice 3.3 Eindbeoordeling domain model & statutory date logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';

void main() {
  group('Slice 3.3 — EindbeoordelingDraft Domain Model', () {
    test('Default model has null properties and negative assessment is false',
        () {
      const draft = EindbeoordelingDraft();
      expect(draft.toestelWerkingGoed, isNull);
      expect(draft.toestelWerkingVeilig, isNull);
      expect(draft.nextInspectionDate, isNull);
      expect(draft.hasNegativeAssessment, isFalse);
      expect(draft.isTechnicianSigned, isFalse);
      expect(draft.isCustomerSigned, isFalse);
    });

    test('Serialization toMap and fromMap preserves all fields', () {
      const draft = EindbeoordelingDraft(
        toestelWerkingGoed: 'Goed',
        toestelWerkingVeilig: 'Veilig',
        nextInspectionDate: '21/10/2026',
        defectsNotes: 'Geen gebreken',
        generalRemarks: 'Ketel in prima staat',
        technicianSignaturePath: 'data:image/png;base64,tech123',
        customerSignaturePath: 'data:image/png;base64,cust456',
        customerSignatureName: 'J. Peeters',
      );

      final map = draft.toMap();
      final reconstructed = EindbeoordelingDraft.fromMap(map);

      expect(reconstructed.toestelWerkingGoed, 'Goed');
      expect(reconstructed.toestelWerkingVeilig, 'Veilig');
      expect(reconstructed.nextInspectionDate, '21/10/2026');
      expect(reconstructed.defectsNotes, 'Geen gebreken');
      expect(reconstructed.generalRemarks, 'Ketel in prima staat');
      expect(reconstructed.technicianSignaturePath,
          'data:image/png;base64,tech123');
      expect(
          reconstructed.customerSignaturePath, 'data:image/png;base64,cust456');
      expect(reconstructed.customerSignatureName, 'J. Peeters');
      expect(reconstructed.isGood, isTrue);
      expect(reconstructed.isSafe, isTrue);
      expect(reconstructed.hasNegativeAssessment, isFalse);
      expect(reconstructed.isTechnicianSigned, isTrue);
      expect(reconstructed.isCustomerSigned, isTrue);
    });

    test('hasNegativeAssessment triggers when Niet goed or Niet veilig is set',
        () {
      const draft1 = EindbeoordelingDraft(
          toestelWerkingGoed: 'Niet goed', toestelWerkingVeilig: 'Veilig');
      expect(draft1.hasNegativeAssessment, isTrue);

      const draft2 = EindbeoordelingDraft(
          toestelWerkingGoed: 'Goed', toestelWerkingVeilig: 'Niet veilig');
      expect(draft2.hasNegativeAssessment, isTrue);

      const draft3 = EindbeoordelingDraft(
          toestelWerkingGoed: 'Goed', toestelWerkingVeilig: 'Veilig');
      expect(draft3.hasNegativeAssessment, isFalse);
    });

    test('copyWith allows partial updates and clearing signatures cleanly', () {
      const initial = EindbeoordelingDraft(
        toestelWerkingGoed: 'Goed',
        technicianSignaturePath: 'path/to/sig',
        customerSignaturePath: 'path/to/cust_sig',
      );

      final updated = initial.copyWith(
        toestelWerkingGoed: 'Niet goed',
        clearTechnicianSignature: true,
      );

      expect(updated.toestelWerkingGoed, 'Niet goed');
      expect(updated.technicianSignaturePath, isNull);
      expect(updated.customerSignaturePath, 'path/to/cust_sig');
    });

    test('Statutory next inspection date calculation adheres to Flemish law',
        () {
      final baseDate = DateTime(2025, 10, 25);

      // Gas fuel -> exactly 2 years
      final gasDate = EindbeoordelingDraft.calculateStatutoryNextDate(
        fuelType: 'gas',
        fromDate: baseDate,
      );
      expect(gasDate, '25/10/2027');

      // Stookolie (liquid) -> exactly 1 year
      final oilDate = EindbeoordelingDraft.calculateStatutoryNextDate(
        fuelType: 'liquid',
        fromDate: baseDate,
      );
      expect(oilDate, '25/10/2026');

      // Solid fuel -> exactly 1 year
      final solidDate = EindbeoordelingDraft.calculateStatutoryNextDate(
        fuelType: 'solid',
        fromDate: baseDate,
      );
      expect(solidDate, '25/10/2026');
    });
  });
}
