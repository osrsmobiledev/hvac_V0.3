import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/domain/reiniging_controls_draft.dart';
import 'package:hvac_app/features/pdf_export/builders/pdf_firma_builder.dart';
import 'package:hvac_app/features/pdf_export/certificate_pdf_dispatcher.dart';
import 'package:hvac_app/features/pdf_export/cleaning_pdf_generator.dart';
import 'package:hvac_app/features/pdf_export/combustion_pdf_generator.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_cleaning_data.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_data_mapper.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';
import 'package:hvac_app/features/pdf_export/services/pdf_file_saver.dart';

int _countPdfPages(Uint8List bytes) {
  final raw = latin1.decode(bytes, allowInvalid: true);
  return RegExp(r'/Type\s*/Page\b').allMatches(raw).length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfDataMapper & PdfCleaningData mapping', () {
    test('maps reiniging fields and all 14 checkboxes cleanly', () {
      final data = PdfDataMapper.mapToPdfData(
        visit: {
          'certificate_type': 'reiniging',
          'attest_number': 'RA-2026-01',
          'technician_role_erkend': 1,
          'technician_role_schoorsteenveger': 1,
          'remedial_measures_notes': 'Rookgaskanaal nakijken',
          'next_inspection_date': '15/03/2027',
          'next_chimney_inspection_date': '20/03/2027',
        },
        profile: {'company_name': 'HVAC BV', 'gv_number': '12345'},
        customer: {'first_name': 'Jan', 'last_name': 'Peeters'},
        location: const {},
        boiler: {'fuel_type': 'gas'},
        slotInitial: const {},
        slotLow: const {},
        slotHigh: const {},
        reinigingRow: {
          'flue_sweeping': 1,
          'all_other_checked': 1,
          'all_other_text': 'Speciale dichting',
          'gas_dust_removal': 1,
        },
      );

      expect(data.cleaning.certificateType, 'reiniging');
      expect(data.cleaning.technicianRoleErkend, isTrue);
      expect(data.cleaning.technicianRoleSchoorsteenveger, isTrue);
      expect(data.cleaning.remedialMeasuresNotes, 'Rookgaskanaal nakijken');
      expect(data.cleaning.nextChimneyInspectionDate, '20/03/2027');
      expect(data.cleaning.controls.flueSweeping, isTrue);
      expect(data.cleaning.controls.allOtherChecked, isTrue);
      expect(data.cleaning.controls.allOtherText, 'Speciale dichting');
      expect(data.cleaning.controls.gasDustRemoval, isTrue);
    });

    test('prunes allOtherText when allOtherChecked is false', () {
      final cleaning = PdfCleaningData.fromRows(
        visit: {'certificate_type': 'reiniging'},
        reinigingRow: {
          'all_other_checked': 0,
          'all_other_text': 'Stale text that must be pruned',
        },
      );

      expect(cleaning.controls.allOtherChecked, isFalse);
      expect(cleaning.controls.allOtherText, isNull);
    });
  });

  group('CleaningPdfGenerator output & single-page A4 guarantees', () {
    test('generates valid 1-page A4 PDF for Schoorsteenveger-only empty draft',
        () async {
      const data = PdfVisitData(
        volgnummerAttest: 'SV-001',
        technicusVoornaam: 'Piet',
        technicusAchternaam: 'Veger',
        cleaning: PdfCleaningData(
          certificateType: 'reiniging',
          technicianRoleErkend: false,
          technicianRoleSchoorsteenveger: true,
        ),
      );

      final bytes = await CleaningPdfGenerator.generateCertificate(data);
      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(_countPdfPages(bytes), 1);
    });

    test(
        'omits saved GV/TV numbers when technicianRoleErkend is false and formats ISO dates',
        () async {
      const data = PdfVisitData(
        volgnummerAttest: 'SV-NO-GV',
        technicusVoornaam: 'Piet',
        technicusAchternaam: 'Veger',
        technicusGv: '99887',
        technicusTv: '77665',
        volgendeControleDatum: '2027-05-01',
        cleaning: PdfCleaningData(
          certificateType: 'reiniging',
          technicianRoleErkend: false,
          technicianRoleSchoorsteenveger: true,
          nextChimneyInspectionDate: '2027-06-15',
        ),
      );

      final bytes = await CertificatePdfDispatcher.generateCertificate(data);
      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(_countPdfPages(bytes), 1);
      expect(PdfFirmaBuilder.formatDate('2027-05-01'), '01/05/2027');
      expect(
        CertificatePdfDispatcher.documentPrefix('reiniging'),
        'Reinigingsattest',
      );
    });

    test(
        'generates 1-page A4 PDF with all 14 checkboxes and long multiline notes',
        () async {
      const longNote =
          'Regel 1 met uitgebreide uitleg over de vastgestelde afwijking.\n'
          'Regel 2 met bijkomende technische details voor de klant.\n'
          'Regel 3 met extra opmerking om hoogtegrenzen te testen.';

      const data = PdfVisitData(
        volgnummerAttest: 'RA-FULL-2026',
        firmaNaam: 'Warmte & Schouw BV',
        technicusVoornaam: 'Karel',
        technicusAchternaam: 'De Smet',
        technicusGv: 'GV 11223',
        technicusTv: 'TV 44556',
        datumOnderhoud: '2026-11-27',
        arbeidsduurVan: '09:00',
        arbeidsduurTot: '10:30',
        klantVoornaam: 'Marie',
        klantAchternaam: 'Janssens',
        brandstofCat: 'gas',
        toestelMerk: 'Vaillant',
        volgendeControleDatum: '27/11/2028',
        gebrekenOpmerkingen: longNote,
        andereOpmerkingen: longNote,
        klantHandtekeningUitzondering: 'weigert',
        cleaning: PdfCleaningData(
          certificateType: 'reiniging',
          technicianRoleErkend: true,
          technicianRoleSchoorsteenveger: true,
          remedialMeasuresNotes: longNote,
          nextChimneyInspectionDate: '27/11/2027',
          controls: ReinigingControlsDraft(
            flueSweeping: true,
            flueGoodOperationCheck: true,
            flueBackdraftCheck: true,
            allOtherChecked: true,
            allOtherText: 'Reinigingsdeksel vervangen',
            allVentilationCheck: true,
            allFlueTightnessCheck: true,
            gasDustRemoval: true,
            gasBurnerBedExchanger: true,
            gasFanBurner: true,
            liquidFilters: true,
            liquidBoiler: true,
            liquidBurner: true,
            solidGeneralCondition: true,
            solidInternalCleaning: true,
          ),
        ),
      );

      final bytes = await CleaningPdfGenerator.generateCertificate(data);
      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes.sublist(0, 5)), '%PDF-');
      expect(_countPdfPages(bytes), 1);
    });
  });

  group('Verbrandingsattest zero-regression & PdfFileSaver naming', () {
    test('CombustionPdfGenerator still produces 1-page A4 PDF', () async {
      const data = PdfVisitData(
        activiteitType: 'onderhoud',
        volgnummerAttest: 'VA-2026-01',
      );
      final bytes = await CombustionPdfGenerator.generateCertificate(data);
      expect(bytes, isNotEmpty);
      expect(_countPdfPages(bytes), 1);
    });

    test('PdfFileSaver uses Reinigingsattest_ prefix for reiniging', () async {
      final tempDir = await Directory.systemTemp.createTemp('hvac_pdf_test_');
      try {
        final bytes = Uint8List.fromList([37, 80, 68, 70, 45]);
        final result = await PdfFileSaver.saveToDevice(
          pdfBytes: bytes,
          attestNumber: 'RA 2026/01',
          certificateType: 'reiniging',
          overrideDirectory: tempDir,
        );
        expect(result.isSuccess, isTrue);
        expect(result.filePath, endsWith('Reinigingsattest_RA_2026_01.pdf'));
        expect(await File(result.filePath).exists(), isTrue);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
