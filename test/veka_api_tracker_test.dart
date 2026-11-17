import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/veka_api_dictionary.dart';
import 'package:hvac_app/app/localization/veka_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_repository.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_api_transport.dart';
import 'package:hvac_app/features/reporting_delivery/ui/veka_tracker.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'veka_api_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late VekaApiFixture fixture;

  setUp(() async => fixture = await VekaApiFixture.create());
  tearDown(() async => fixture.close());

  Future<void> openTracker(WidgetTester tester,
      {bool simulation = true}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final app = MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: VekaTracker(
            visitId: VekaApiFixture.visitId,
            repository: fixture.reports,
            apiRepository: simulation
                ? VekaApiRepository(database: () async => fixture.db)
                : null,
          ),
        ),
      ),
    );
    await tester.runAsync(() => tester.pumpWidget(app));
  }

  testWidgets('requires review on a narrow phone and displays a saved receipt',
      (tester) async {
    await openTracker(tester);
    await _tap(tester, VekaApiDictionary.start);
    await _waitFor(tester, find.text(VekaApiDictionary.review));
    expect(find.text('Kerkstraat 15 bus 0001, 9000 Gent'), findsOneWidget);
    expect(await tester.runAsync(() => fixture.db.query('veka_api_attempts')),
        isEmpty);
    await _tap(tester, VekaApiDictionary.submit);
    await _waitFor(tester, find.text(VekaApiDictionary.accepted));
    expect(find.text(VekaDictionary.open), findsNothing);
    await _tap(tester, VekaApiDictionary.details);
    expect(find.text('Kerkstraat 15 bus 0001, 9000 Gent').last, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a manual address keeps the portal available', (tester) async {
    await tester.runAsync(() => fixture.db.update('service_locations', {
          'verification_status': 'unverified',
          'adres_id': null,
          'gebouw_id': null,
          'gebouweenheid_id': null,
        }));
    await openTracker(tester);
    await _tap(tester, VekaApiDictionary.start);
    await _waitFor(tester, find.text(VekaApiDictionary.addressBlocked));
    expect(find.text(VekaApiDictionary.submit), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await tester.runAsync(() => fixture.db.query('veka_api_attempts')),
        isEmpty);
  });

  testWidgets('the ordinary build shows only the portal flow', (tester) async {
    await openTracker(tester, simulation: false);
    await _waitFor(tester, find.text(VekaDictionary.open));
    expect(find.text(VekaApiDictionary.start), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the review names the missing safety conclusion', (tester) async {
    await tester.runAsync(() => fixture.db
        .update(VekaApiFixture.visitTable, {'toestel_werking_veilig': null}));
    await openTracker(tester);
    await _tap(tester, VekaApiDictionary.start);
    await _waitFor(tester, find.text('Duid Veiligheid aan.'));
    expect(find.text(VekaApiDictionary.submit), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an access refusal offers retry and portal without editing',
      (tester) async {
    final api = VekaApiRepository(database: () async => fixture.db);
    final refused = await tester.runAsync(() async =>
        api.submit(await fixture.review(), outcome: VekaMockOutcome.technical));
    await openTracker(tester);
    await _waitFor(tester, find.text(VekaApiDictionary.technical));
    expect(find.text(VekaDictionary.open), findsOneWidget);
    expect(find.text(VekaApiDictionary.receipt), findsNothing);
    await _tap(tester, VekaApiDictionary.accessRetry);
    await _waitFor(tester, find.text(VekaApiDictionary.accessRetryHint));
    expect(find.text(refused!.requestReference), findsOneWidget);
    await _tap(tester, VekaApiDictionary.submit);
    await _waitFor(tester, find.text(VekaApiDictionary.accepted));
    expect(find.text(VekaDictionary.open), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 120; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 30));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 250));
      return;
    }
  }
  fail('Widget never appeared: $finder');
}

Future<void> _tap(WidgetTester tester, String label) async {
  final text = find.text(label);
  await _waitFor(tester, text);
  final finder = text.last;
  await tester.ensureVisible(finder);
  await tester.runAsync(() => tester.tap(finder));
  await tester.pump();
}
