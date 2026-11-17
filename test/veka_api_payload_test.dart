import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_payload.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'veka_api_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final today = DateTime.utc(2026, 1, 1);
  const reference = 'reference-fixture';
  late VekaApiFixture fixture;

  setUp(() async => fixture = await VekaApiFixture.create());
  tearDown(() => fixture.close());

  test('serializes the documented synthetic contract from the visit', () async {
    final payload = VekaApiPayload.fromReport(
      await fixture.review(),
      reference,
      today,
    );
    expect(jsonDecode(payload.json), {
      'externeReferte': reference,
      'ondernemingsnummer': '0123456789',
      'gegevensActiviteit': {
        'activiteitType': 'Onderhoud',
        'datumActiviteit': '2025-01-01',
        'erkenningsnummer': 'GV12345',
        'verwarmingType': 'Individueel',
        'adresId': '12345',
        'gebouwId': '67890',
        'gebouwIdNietGekend': false,
        'gebouweenheidId': '67891',
        'gebouweenheidIdNietGekend': false,
      },
      'kenmerkenToestel': {
        'brandstof': 'Aardgas',
        'nominaalVermogen': 32.0,
        'werking': 'Condenserende ketel',
        'branderTechnologie': 'Premix (GI)',
        'merk': 'Voorbeeldmerk',
        'merkNietGekend': false,
        'type': 'Voorbeeldmodel',
        'typeNietGekend': false,
        'fabricatienummer': 'TEST-12345',
        'fabricatienummerNietGekend': false,
        'bouwjaar': 2022,
        'bouwjaarNietGekend': false,
      },
      'eindbeoordeling': {
        'stooktoestelConform': 'OK',
        'rookgasafvoerkanaalConform': 'OK',
        'stookplaatsConform': 'OK',
        'verbrandingscontrole': 'OK',
        'toestelWerkingGoed': 'Goed',
        'toestelWerkingVeilig': 'Veilig',
      },
    });
  });

  test('unverified installation cannot be sent but remains usable manually',
      () async {
    await fixture.db.update('service_locations', {
      'verification_status': 'unverified',
      'adres_id': null,
    });
    final reviewed = await fixture.review();
    expect(
      () => VekaApiPayload.fromReport(reviewed, reference, today),
      throwsA(isA<VekaException>()),
    );
    final reserved = await fixture.reports.reserve(reviewed, replaces: null);
    expect(reserved.report?.address, 'Kerkstraat 15 bus 0001, 9000 Gent');
  });

  test('a partial link remains usable manually but cannot enter the mock API',
      () async {
    await fixture.db.update('service_locations', {
      'verification_status': 'partial',
      'gebouweenheid_id': null,
    });
    final reviewed = await fixture.review();
    expect(
      () => VekaApiPayload.fromReport(reviewed, reference, today),
      throwsA(isA<VekaException>()),
    );
    final stored = await fixture.reports.reserve(reviewed, replaces: null);
    expect(stored.report?.address, 'Kerkstraat 15 bus 0001, 9000 Gent');
  });

  test('stookolie uses a TV recognition and omits gas burner technology',
      () async {
    await fixture.db.update('boilers', {
      'fuel_type': 'vloeibaar',
      'fuel_subtype': null,
      'burner_technology': 'premix',
    });
    await fixture.db.update('technician_profile', {'tv_number': 'tv 67890'});
    final payload = VekaApiPayload.fromReport(
      await fixture.review(),
      reference,
      today,
    );
    final decoded = jsonDecode(payload.json) as Map<String, Object?>;
    final activity = decoded['gegevensActiviteit'] as Map<String, Object?>;
    final boiler = decoded['kenmerkenToestel'] as Map<String, Object?>;
    expect(activity['erkenningsnummer'], 'TV67890');
    expect(boiler['brandstof'], 'Stookolie');
    expect(boiler.containsKey('branderTechnologie'), isFalse);
  });
}
