import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_attempt.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_payload.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_repository.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_transport.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'veka_api_fixture.dart';

const _visit = VekaApiFixture.visitId;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late VekaApiFixture fixture;

  setUp(() async => fixture = await VekaApiFixture.create());
  tearDown(() => fixture.close());

  VekaApiRepository repository({
    VekaApiTransport? transport,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      VekaApiRepository(
        database: () async => fixture.db,
        transport: transport,
        timeout: timeout,
      );

  test(
      'persists the exact request before transport and durably stores a receipt',
      () async {
    var calls = 0;
    late VekaApiRepository repo;
    repo = repository(transport: (request, _) async {
      calls++;
      final stored = await repo.read(_visit);
      expect(stored?.status, VekaApiStatus.sending);
      expect(stored?.requestJson, request);
      expect(stored?.requestReference, _reference(request));
      expect(stored?.report.address, 'Kerkstraat 15 bus 0001, 9000 Gent');
      final row = (await fixture.db.query('veka_api_attempts')).single;
      expect(row['status'], 'sending');
      expect(row['request_json'], request);
      expect(row['contract_version'], VekaApiPayload.contractVersion);
      expect(DateTime.tryParse(row['created_at'] as String), isNotNull);
      return _accepted(request);
    });

    final review = await fixture.review();
    final prepared = repo.prepare(review);
    final result = await repo.submit(review, prepared: prepared);
    expect(result.requestJson, prepared.requestJson);
    expect(result.status, VekaApiStatus.accepted);
    expect(result.responseStatus, 201);
    expect(result.responseJson, _accepted(result.requestJson).body);
    expect(result.receiptNumber, 'TEST-42');
    expect(result.messages, contains('Testwaarschuwing'));
    expect(calls, 1);
    final row = await fixture.visit();
    expect(row['veka_status'], 'not_submitted');
    expect(row['snapshot_json'], isNull);
    expect(row['veka_manual_note'], isNull);
    expect(row['pdf_status'], 'draft');
    expect(row['is_draft'], 1);

    await fixture.reopen();
    final reopened = repository(transport: (_, __) async {
      calls++;
      return const VekaApiResponse(500, '{}');
    });
    final recalled = await reopened.read(_visit);
    expect(recalled?.requestJson, result.requestJson);
    expect(recalled?.responseJson, result.responseJson);
    expect(recalled?.receiptNumber, 'TEST-42');
    await expectLater(
      reopened.submit(await fixture.review()),
      throwsA(isA<VekaException>()),
    );
    await expectLater(
      fixture.reports.reserve(await fixture.review(), replaces: null),
      throwsA(isA<VekaException>()),
    );
    expect(calls, 1);
  });

  test('two concurrent requests produce one attempt and one transport call',
      () async {
    final dispatched = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    final repo = repository(transport: (request, _) async {
      calls++;
      dispatched.complete();
      await release.future;
      return _accepted(request);
    });
    final report = await fixture.review();
    final secondConnection = await fixture.openSecondConnection();
    addTearDown(secondConnection.close);
    final first = repo.submit(report);
    try {
      await dispatched.future.timeout(const Duration(seconds: 3));
      final another = VekaApiRepository(
          database: () async => secondConnection,
          transport: (_, __) async {
            calls++;
            return const VekaApiResponse(500, '{}');
          });
      expect((await another.read(_visit))?.status, VekaApiStatus.sending);
      await expectLater(another.submit(report), throwsA(isA<VekaException>()));
      await expectLater(
        fixture.reports.reserve(report, replaces: null),
        throwsA(isA<VekaException>()),
      );
      expect(await fixture.db.query('veka_api_attempts'), hasLength(1));
    } finally {
      release.complete();
      expect((await first).status, VekaApiStatus.accepted);
    }
    expect(calls, 1);
  });

  test('field rejection keeps exact earlier evidence after an explicit fix',
      () async {
    const rejection = VekaApiResponse(
      400,
      '{"errors":[{"field":"kenmerkenToestel.merk",'
      '"detail":"Merk ontbreekt"}]}',
    );
    var calls = 0;
    final repo = repository(transport: (request, _) async {
      calls++;
      return calls == 1 ? rejection : _accepted(request);
    });
    final report = await fixture.review();
    final rejected = await repo.submit(report);
    expect(rejected.status, VekaApiStatus.rejected);
    expect(rejected.responseStatus, 400);
    expect(rejected.responseJson, rejection.body);
    expect(rejected.messages, contains('Merk ontbreekt'));
    expect(rejected.fieldErrors.single.field, 'kenmerkenToestel.merk');
    expect(rejected.receiptNumber, isNull);
    final oldRows = await fixture.db.query('veka_api_attempts');
    expect(oldRows, hasLength(1));
    await expectLater(repo.submit(report), throwsA(isA<VekaException>()));
    await fixture.db
        .update('technician_profile', {'technician_first_name': 'Andere'});
    await expectLater(
        repo.submit(await fixture.review()), throwsA(isA<VekaException>()));

    await fixture.db.update('boilers', {'boiler_brand': 'Gecorrigeerd'});
    await expectLater(repo.submit(report), throwsA(isA<VekaException>()));
    final accepted = await repo.submit(await fixture.review());
    expect(accepted.status, VekaApiStatus.accepted);
    expect(accepted.requestReference, isNot(rejected.requestReference));
    expect(accepted.requestJson, contains('Gecorrigeerd'));
    final savedRows = await fixture.db.query('veka_api_attempts');
    expect(savedRows, hasLength(2));
    expect(savedRows.singleWhere((row) => row['id'] == rejected.id),
        oldRows.single);
    expect(calls, 2);
  });

  test('an open or confirmed manual report blocks an API dispatch', () async {
    var calls = 0;
    final repo = repository(transport: (request, _) async {
      calls++;
      return _accepted(request);
    });
    final reviewed = await fixture.review();
    final manual = await fixture.reports.reserve(reviewed, replaces: null);
    final manualId = manual.report!.id!;
    await expectLater(repo.submit(reviewed), throwsA(isA<VekaException>()));
    await fixture.reports.confirm(_visit, manualId, actor: 'Jan');
    await expectLater(
      repo.submit(await fixture.review()),
      throwsA(isA<VekaException>()),
    );
    expect(calls, 0);
    expect((await fixture.reports.read(_visit)).confirmed, isTrue);
    expect(await fixture.db.query('veka_api_attempts'), isEmpty);
  });

  test('a completed visit sends only frozen certificate values', () async {
    await fixture.finalize();
    final row = await fixture.visit();
    await fixture.db.update('service_locations', {'adres_id': 'edited'});
    await fixture.db.update('boilers', {'boiler_brand': 'edited'});
    final repo = repository(transport: (request, _) async {
      expect(request, contains('"adresId":"12345"'));
      expect(request, contains('"merk":"Voorbeeldmerk"'));
      return _accepted(request);
    });
    expect(
      (await repo.submit(await fixture.review())).status,
      VekaApiStatus.accepted,
    );
    final updated = await fixture.visit();
    expect(updated['snapshot_json'], row['snapshot_json']);
    expect(updated['pdf_status'], 'ready');
    expect(updated['is_draft'], 0);
  });

  test('a failed attempt insert cannot dispatch', () async {
    await fixture.db.execute('''
      CREATE TRIGGER reject_attempt BEFORE INSERT ON veka_api_attempts
      BEGIN SELECT RAISE(ABORT, 'test rejects request storage'); END
    ''');
    var calls = 0;
    final repo = repository(transport: (request, _) async {
      calls++;
      return _accepted(request);
    });
    await expectLater(repo.submit(await fixture.review()), throwsException);
    expect(calls, 0);
    expect(await fixture.db.query('veka_api_attempts'), isEmpty);
  });

  test('opening a pre-API database keeps the existing manual record', () async {
    final reserved =
        await fixture.reports.reserve(await fixture.review(), replaces: null);
    final confirmed = await fixture.reports
        .confirm(_visit, reserved.report!.id!, actor: 'Jan');
    await fixture.db.execute('DROP TABLE veka_api_dispatches');
    await fixture.db.execute('DROP TABLE veka_api_attempts');
    await fixture.db.setVersion(10);
    await fixture.reopen();
    expect((await fixture.reports.read(_visit)).confirmation,
        confirmed.confirmation);
    expect(await fixture.db.query('veka_api_attempts'), isEmpty);
    expect(await fixture.db.query('veka_api_dispatches'), isEmpty);
  });
}

String _reference(String request) =>
    (jsonDecode(request) as Map<String, Object?>)['externeReferte']! as String;

VekaApiResponse _accepted(String request) => VekaApiResponse(
      201,
      jsonEncode({
        'externeReferte': _reference(request),
        'meldingsnummer': 'TEST-42',
        'opmerkingen': ['Testwaarschuwing'],
      }),
    );
