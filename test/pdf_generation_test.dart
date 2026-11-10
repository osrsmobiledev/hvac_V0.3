import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/pdf_export/combustion_pdf_generator.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_data_mapper.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CombustionPdfGenerator Unit Tests', () {
    final dummySignatureBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    test('generateCertificate succeeds with default empty draft', () async {
      const emptyData = PdfVisitData();

      final pdfBytes =
          await CombustionPdfGenerator.generateCertificate(emptyData);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes, isNotEmpty);
      // Valid PDF documents always start with '%PDF-'
      expect(pdfBytes.length, greaterThan(100));
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });

    test('generateCertificate succeeds with fully populated visit data',
        () async {
      final fullData = PdfVisitData(
        activiteitType: 'Periodiek onderhoud',
        volgnummerAttest: 'V-2026-0042',
        firmaNaam: 'HVAC Solutions BV',
        firmaStraat: 'Industrieweg',
        firmaNr: '12',
        firmaPostcode: '9000',
        firmaGemeente: 'Gent',
        firmaTel: '+32 9 123 45 67',
        firmaKbo: '0123.456.789',
        technicusVoornaam: 'Jan',
        technicusAchternaam: 'Peeters',
        technicusGv: 'GV01234',
        datumOnderhoud: '10/11/2026',
        arbeidsduurVan: '08:30',
        arbeidsduurTot: '10:15',
        klantNaam: 'Familie Janssens',
        klantStraat: 'Kerkstraat',
        klantNr: '45',
        klantPostcode: '9050',
        klantGemeente: 'Ledeberg',
        klantTel: '+32 470 12 34 56',
        isCentraal: true,
        centraalType: 'B',
        brandstofCat: 'gas',
        gasType: 'aardgas',
        branderTech: 'premix (GI)',
        toestelMerk: 'Vaillant',
        toestelType: 'ecoTEC plus',
        toestelBouwjaar: '2021',
        toestelFabNummer: 'SN-987654321',
        toestelVermogen: '24.5',
        branderMerk: 'Vaillant Integrated',
        branderType: 'VM-1',
        branderBouwjaar: '2021',
        branderFabNummer: 'BR-12345',
        branderDebiet: '24.5',
        meetToestelSerienummer: '06-52-01055',
        isLaaglastActive: true,
        isHooglastActive: true,
        ketelTemp: '62.0',
        proef1O2: '4.8',
        proef1Co2: '9.1',
        proef1Co: '18',
        proef1CoOk: 'OK',
        proef1Tg: '52.3',
        proef1Ta: '20.1',
        proef1NettoTemp: '32.2',
        proef1RendementHi: '98.5',
        proef1RendementHiOk: 'OK',
        proef2LaagO2: '4.9',
        proef2LaagCo2: '9.0',
        proef2LaagCo: '15',
        proef2HoogO2: '4.8',
        proef2HoogCo2: '9.1',
        proef2HoogCo: '18',
        geenOliespoorOk: 'OK',
        geenCondensatieOk: 'OK',
        schouwtrekPa: '12.0',
        verluchtingStooklokaalOk: 'OK',
        dichtheidRookgasafvoerOk: 'OK',
        dichtheidBrandstoftoevoerOk: 'OK',
        toestelWerkingGoed: 'Goed',
        toestelWerkingVeilig: 'Veilig',
        volgendeControleDatum: '10/11/2028',
        gebrekenOpmerkingen:
            'Toestel in uitstekende staat na periodiek onderhoud.',
        technicusHandtekeningBytes: dummySignatureBytes,
        klantHandtekeningBytes: dummySignatureBytes,
        klantHandtekeningNaam: 'Janssens',
      );

      final pdfBytes =
          await CombustionPdfGenerator.generateCertificate(fullData);

      File('Verbrandingsattest_1.pdf').writeAsBytesSync(pdfBytes);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });

    test('generateCertificate handles customer signature refusal gracefully',
        () async {
      const data = PdfVisitData(
        klantHandtekeningUitzondering: 'weigert',
        toestelWerkingGoed: 'Niet goed',
        toestelWerkingVeilig: 'Niet veilig',
        gebrekenOpmerkingen:
            'Klant weigert handtekening te plaatsen wegens afkeur.',
      );

      final pdfBytes = await CombustionPdfGenerator.generateCertificate(data);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
    });

    test('PdfDataMapper correctly wires measurements and base64 signatures',
        () async {
      final slot1 = {
        'slot': 'proef1',
        'o2_percent': 4.8,
        'co2_percent': 9.1,
        'co_mg_kwh': 18.0,
        'co_ok': 1,
        'flue_temp_celsius': 52.3,
        'ambient_temp_celsius': 20.1,
        'net_temp_celsius': 32.2,
        'combustion_efficiency_hi': 98.5,
        'combustion_efficiency_hi_ok': 1,
        'combustion_efficiency_hs': 89.2,
      };

      final slotLow = {
        'slot': 'proef2_laaglast',
        'o2_percent': 4.9,
        'co2_percent': 9.0,
        'co_ppm': 15.0,
        'flue_temp_celsius': 48.0,
        'ambient_temp_celsius': 20.0,
        'combustion_efficiency_hi': 98.2,
      };

      final slotHigh = {
        'slot': 'proef2_hooglast',
        'o2_percent': 4.8,
        'co2_percent': 9.1,
        'co_mg_kwh': 18.0,
        'flue_temp_celsius': 54.0,
        'ambient_temp_celsius': 20.0,
        'combustion_efficiency_hi': 98.6,
      };

      final mapped = PdfDataMapper.mapToPdfData(
        visit: {
          'activity_type': 'Periodiek onderhoud',
          'attest_number': 'AT-999',
          'operating_temp_celsius': 60.0,
          'toestel_werking_goed': 'Goed',
          'toestel_werking_veilig': 'Veilig',
          'customer_signature_exception': 'refused',
        },
        profile: {'company_name': 'Warmte BV'},
        customer: {'first_name': 'Karel', 'last_name': 'De Grote'},
        location: {'street': 'Kasteellaan', 'house_number': '1'},
        boiler: {'fuel_type': 'gas', 'is_central': 1},
        slotInitial: slot1,
        slotLow: slotLow,
        slotHigh: slotHigh,
        techSigBytes: dummySignatureBytes,
        custSigBytes: null,
      );

      expect(mapped.proef1O2, equals('4.8'));
      expect(mapped.proef1Co, equals('18'));
      expect(mapped.proef1CoOk, equals('OK'));
      expect(mapped.proef1RendementHi, equals('98.5'));
      expect(mapped.proef1RendementHiOk, equals('OK'));
      expect(mapped.isLaaglastActive, isTrue);
      expect(mapped.isHooglastActive, isTrue);
      expect(mapped.proef2LaagO2, equals('4.9'));
      expect(mapped.proef2LaagCo, equals('15'));
      expect(mapped.proef2HoogO2, equals('4.8'));
      expect(mapped.technicusHandtekeningBytes, isNotNull);
      expect(mapped.klantHandtekeningUitzondering, equals('refused'));

      final pdfBytes = await CombustionPdfGenerator.generateCertificate(mapped);
      expect(pdfBytes, isNotEmpty);
    });
  });
}
