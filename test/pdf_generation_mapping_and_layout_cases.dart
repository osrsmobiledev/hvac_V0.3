part of 'pdf_generation_test.dart';

void _mappingAndLayoutCases(Uint8List dummySignatureBytes) {
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

  test(
      'generateCertificate succeeds with 6 defects and multi-line remarks on single page',
      () async {
    final multiIssueData = PdfVisitData(
      volgnummerAttest: 'TEST-MULTI-6',
      firmaNaam: 'Verwarming & Sanitair BV',
      gebrekenOpmerkingen: '• Expansievat membraan gescheurd\n'
          '• Branderdichting versleten\n'
          '• Ontstekingselektrode gecorrodeerd\n'
          '• Automatische ontluchter lekt\n'
          '• Condensafvoer deels verstopt\n'
          '• Isolatiepaneel verbrandingskamer beschadigd',
      andereOpmerkingen: '• Expansievat vervangen\n• Branderpakking vernieuwd',
      technicusHandtekeningBytes: dummySignatureBytes,
      klantHandtekeningBytes: dummySignatureBytes,
    );

    final pdfBytes =
        await CombustionPdfGenerator.generateCertificate(multiIssueData);
    File('Verbrandingsattest_Test.pdf').writeAsBytesSync(pdfBytes);
    expect(pdfBytes, isNotNull);
    expect(pdfBytes, isNotEmpty);
    expect(String.fromCharCodes(pdfBytes.take(5)), equals('%PDF-'));
  });
}
