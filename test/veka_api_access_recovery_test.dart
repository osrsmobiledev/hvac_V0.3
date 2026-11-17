import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_attempt.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_repository.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_transport.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'veka_api_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late VekaApiFixture fixture;
  late VekaApiRepository api;
  late List<String> sent;
  const visit = VekaApiFixture.visitId;

  setUp(() async {
    fixture = await VekaApiFixture.create();
    sent = [];
    api = VekaApiRepository(
      database: () async => fixture.db,
      transport: (json, outcome) {
        sent.add(json);
        return VekaMockTransport.send(json, outcome);
      },
    );
  });
  tearDown(() => fixture.close());

  test('access recovery after restart replays the frozen request once',
      () async {
    final first = await api.submit(await fixture.review(),
        outcome: VekaMockOutcome.technical);
    expect(first.status, VekaApiStatus.technical);
    expect(first.receiptNumber, isNull);
    await fixture.finalize();
    await fixture.reopen();
    final saved = (await api.read(visit))!;
    expect(saved.status, VekaApiStatus.technical);
    expect(sent, hasLength(1));
    final receipt = await api.retryAfterAccessRestored(saved,
        outcome: VekaMockOutcome.accepted);
    expect(receipt.status, VekaApiStatus.accepted);
    expect(receipt.requestReference, first.requestReference);
    expect(sent, [first.requestJson, first.requestJson]);
    expect((await api.dispatches(receipt)).map((item) => item.responseStatus),
        [201, 403]);
    await expectLater(
        api.retryAfterAccessRestored(saved, outcome: VekaMockOutcome.accepted),
        throwsA(isA<VekaException>()));
    expect(sent, hasLength(2));
  });

  test('changed draft can use the portal but cannot replay stale data',
      () async {
    final refused = await api.submit(await fixture.review(),
        outcome: VekaMockOutcome.technical);
    await fixture.changeAddress('25');
    await expectLater(
        api.retryAfterAccessRestored(refused,
            outcome: VekaMockOutcome.accepted),
        throwsA(isA<VekaException>()));
    final portal =
        await fixture.reports.reserve(await fixture.review(), replaces: null);
    final confirmed = await fixture.reports
        .confirm(visit, portal.report!.id!, actor: 'Testtechnicus');
    expect(confirmed.report!.address, contains('25 bus'));
    expect(confirmed.confirmed, isTrue);
    expect((await api.read(visit))!.report.address, contains('15 bus'));
    expect(sent, hasLength(1));
  });

  test('reserving the portal blocks a previously reviewed API retry', () async {
    final report = await fixture.review();
    final refused =
        await api.submit(report, outcome: VekaMockOutcome.technical);
    await fixture.reports.reserve(report, replaces: null);
    await expectLater(
        api.retryAfterAccessRestored(refused,
            outcome: VekaMockOutcome.accepted),
        throwsA(isA<VekaException>()));
    expect(sent, hasLength(1));
  });

  test('a refusal naming another request remains uncertain', () async {
    const response = VekaApiResponse(403, '{"externeReferte":"other"}');
    expect(response.classify('this').status, VekaApiStatus.uncertain);
  });
}
