import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_attempt.dart';
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
    required VekaApiTransport transport,
    Duration timeout = const Duration(seconds: 10),
  }) =>
      VekaApiRepository(
        database: () async => fixture.db,
        transport: transport,
        timeout: timeout,
      );

  const responses = {
    'a malformed success': VekaApiResponse(201, 'not-json'),
    'a 2xx without a receipt': VekaApiResponse(201, '{}'),
    'a 2xx with the wrong reference': VekaApiResponse(
      201,
      '{"externeReferte":"wrong","meldingsnummer":"TEST-42"}',
    ),
    'a possible duplicate': VekaApiResponse(409, '{}'),
    'an unknown server failure': VekaApiResponse(500, '{}'),
  };
  for (final entry in responses.entries) {
    test('${entry.key} remains uncertain and blocks both send channels',
        () async {
      var calls = 0;
      final repo = repository(transport: (_, __) async {
        calls++;
        return entry.value;
      });
      final report = await fixture.review();
      final result = await repo.submit(report);
      expect(result.status, VekaApiStatus.uncertain);
      expect(result.responseStatus, entry.value.statusCode);
      expect(result.responseJson, entry.value.body);
      expect(result.receiptNumber, isNull);
      expect(result.allowsManual, isFalse);
      expect(result.allowsNewAttempt, isFalse);
      await expectLater(repo.submit(report), throwsA(isA<VekaException>()));
      await expectLater(
        fixture.reports.reserve(report, replaces: null),
        throwsA(isA<VekaException>()),
      );
      expect(calls, 1);
    });
  }

  test('a technical authentication failure differs from a field rejection',
      () async {
    const response =
        VekaApiResponse(401, '{"detail":"Geen leveranciersrecht"}');
    var calls = 0;
    final repo = repository(transport: (_, __) async {
      calls++;
      return response;
    });
    final result = await repo.submit(await fixture.review());
    expect(result.status, VekaApiStatus.technical);
    expect(result.responseStatus, 401);
    expect(result.responseJson, response.body);
    expect(result.receiptNumber, isNull);
    await expectLater(
      repo.submit(await fixture.review()),
      throwsA(isA<VekaException>()),
    );
    expect(calls, 1);
  });

  test('timeout permits only one conscious retry with identical request bytes',
      () async {
    final pending = Completer<VekaApiResponse>();
    final requests = <String>[];
    final repo = repository(
      timeout: const Duration(milliseconds: 50),
      transport: (request, _) {
        requests.add(request);
        return pending.future;
      },
    );
    final result = await repo.submit(await fixture.review());
    expect(result.status, VekaApiStatus.uncertain);
    expect(result.responseStatus, isNull);

    pending.complete(_receipt(result.requestReference));
    await fixture.changeAddress('99');
    await fixture.db.update('boilers', {'boiler_brand': 'Edited'});
    await fixture.reopen();
    final reopened = repository(transport: (request, _) async {
      requests.add(request);
      return _receipt(
        (jsonDecode(request) as Map)['externeReferte'] as String,
      );
    });
    expect((await reopened.read(_visit))?.status, VekaApiStatus.uncertain);
    expect(requests, [result.requestJson]);
    final retry = await reopened.confirmAbsentAndRetry(
      _visit,
      result.requestReference,
      outcome: VekaMockOutcome.accepted,
      expectedDispatchNumber: result.dispatchNumber,
    );
    expect(retry.status, VekaApiStatus.accepted);
    expect(retry.requestReference, result.requestReference);
    expect(retry.requestJson, result.requestJson);
    expect(requests, [result.requestJson, result.requestJson]);
    await expectLater(
      reopened.confirmAbsentAndRetry(
        _visit,
        result.requestReference,
        outcome: VekaMockOutcome.accepted,
        expectedDispatchNumber: retry.dispatchNumber,
      ),
      throwsA(isA<VekaException>()),
    );
    expect(requests, hasLength(2));
  });

  test('a sending attempt survives restart as uncertain without dispatch',
      () async {
    var calls = 0;
    final repo = repository(transport: (_, __) async {
      calls++;
      return const VekaApiResponse(500, '{}');
    });
    final stored = await repo.submit(await fixture.review());
    await fixture.db.update('veka_api_attempts', {
      'status': 'sending',
      'resolved_at': null,
      'response_status': null,
      'response_json': null,
    });
    await fixture.reopen();
    final restarted = repository(transport: (_, __) async {
      calls++;
      return const VekaApiResponse(500, '{}');
    });
    final recovered = await restarted.read(_visit);
    expect(recovered?.status, VekaApiStatus.uncertain);
    expect(recovered?.requestReference, stored.requestReference);
    expect(recovered?.requestJson, stored.requestJson);
    final rows = await fixture.db.query('veka_api_attempts');
    expect(rows.single['status'], 'timeout_uncertain');
    await expectLater(
      restarted.submit(await fixture.review()),
      throwsA(isA<VekaException>()),
    );
    expect(calls, 1);
  });

  test('outdated authorization cannot retry a newer uncertain dispatch',
      () async {
    final requests = <String>[];
    final repo = repository(transport: (request, _) async {
      requests.add(request);
      return const VekaApiResponse(500, '{}');
    });
    final first = await repo.submit(await fixture.review());
    final second = await repo.confirmAbsentAndRetry(
      _visit,
      first.requestReference,
      outcome: VekaMockOutcome.uncertain,
      expectedDispatchNumber: first.dispatchNumber,
    );
    expect(second.status, VekaApiStatus.uncertain);
    expect(second.dispatchNumber, greaterThan(first.dispatchNumber));
    await expectLater(
      repo.confirmAbsentAndRetry(
        _visit,
        first.requestReference,
        outcome: VekaMockOutcome.accepted,
        expectedDispatchNumber: first.dispatchNumber,
      ),
      throwsA(isA<VekaException>()),
    );
    final reconciled = await repo.reconcileReceipt(
      _visit,
      first.requestReference,
      expectedDispatchNumber: second.dispatchNumber,
    );
    expect(reconciled.status, VekaApiStatus.accepted);
    expect(reconciled.receiptNumber, isNotEmpty);
    expect(reconciled.requestJson, first.requestJson);
    expect(requests, [first.requestJson, first.requestJson]);
    final log = await fixture.db.query(
      'veka_api_dispatches',
      orderBy: 'dispatch_number ASC',
    );
    expect(log.map((row) => row['response_status']), [500, 500]);
    expect(log.map((row) => row['status']),
        ['timeout_uncertain', 'timeout_uncertain']);
  });

  test('failure to store a receipt leaves the attempt uncertain', () async {
    await fixture.db.execute('''
      CREATE TRIGGER reject_receipt
      BEFORE UPDATE OF status ON veka_api_attempts
      WHEN NEW.status = 'accepted_api'
      BEGIN SELECT RAISE(ABORT, 'test rejects receipt'); END
    ''');
    final repo = repository(transport: (request, _) async {
      final reference =
          (jsonDecode(request) as Map)['externeReferte'] as String;
      return _receipt(reference);
    });
    final attempt = await repo.submit(await fixture.review());
    expect(attempt.status, VekaApiStatus.uncertain);
    expect(attempt.receiptNumber, isNull);
    expect(attempt.allowsNewAttempt, isFalse);
    await fixture.reopen();
    final reread = await repository(
      transport: (_, __) => throw StateError('Unexpected resend'),
    ).read(_visit);
    expect(reread?.status, VekaApiStatus.uncertain);
    expect(reread?.requestJson, attempt.requestJson);
  });
}

VekaApiResponse _receipt(String reference) => VekaApiResponse(
      201,
      jsonEncode({
        'externeReferte': reference,
        'meldingsnummer': 'TEST-42',
        'opmerkingen': ['Testwaarschuwing'],
      }),
    );
