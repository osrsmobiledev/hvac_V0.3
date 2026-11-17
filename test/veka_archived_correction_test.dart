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

  setUp(() async => fixture = await VekaApiFixture.create());
  tearDown(() => fixture.close());

  test('archived date correction keeps the certificate and rejection evidence',
      () async {
    const rejection = VekaApiResponse(
      400,
      '{"errors":[{"field":"datumActiviteit",'
      '"detail":"Datum is ongeldig"}]}',
    );
    var calls = 0;
    final api = VekaApiRepository(
      database: () async => fixture.db,
      transport: (request, _) async {
        if (calls++ == 0) return rejection;
        return VekaMockTransport.send(request, VekaMockOutcome.accepted);
      },
    );
    final original = await fixture.review();
    final rejected = await api.submit(original);
    await fixture.finalize();
    final snapshot = (await fixture.visit())['snapshot_json'];
    final correction = original.withActivityDate('2026-02-03');

    expect(rejected.canCorrectActivityDate, isTrue);
    await expectLater(
      api.submit(original, corrects: rejected),
      throwsA(isA<VekaException>()),
    );
    final accepted = await api.submit(correction,
        corrects: rejected, outcome: VekaMockOutcome.accepted);

    expect(accepted.status, VekaApiStatus.accepted);
    expect(accepted.requestJson, contains('"datumActiviteit":"2026-02-03"'));
    expect((await fixture.visit())['snapshot_json'], snapshot);
    final attempts = await api.history(VekaApiFixture.visitId);
    expect(attempts, hasLength(2));
    expect(attempts[1].requestJson, rejected.requestJson);
    expect(attempts[1].status, VekaApiStatus.rejected);
    expect(calls, 2);
  });
}
