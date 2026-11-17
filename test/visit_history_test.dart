import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/visit_history_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_follow_up.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:hvac_app/features/visit_history/data/visit_history_repository.dart';
import 'package:hvac_app/features/visit_history/ui/visit_history_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'veka_api_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Database db;
  late VisitHistoryRepository repository;
  const stamp = {'created_at': '2026-01-01', 'updated_at': '2026-01-01'};
  const table = 'maintenance_visits';

  Future<int> addVisit(String date, String due, {int? boiler = 1}) =>
      db.insert(table, {
        ...stamp,
        'visit_date': date,
        'next_inspection_date': due,
        'customer_id': 1,
        'service_location_id': 1,
        'boiler_id': boiler,
      });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) => DatabaseSchema.createAllTables(db)));
    repository = VisitHistoryRepository(database: () async => db);
    await db.insert('customers', {...stamp, 'last_name': 'Aerts'});
    await db.insert('service_locations', {
      ...stamp,
      'customer_id': 1,
      'street': 'Kerkstraat',
      'house_number': '15',
      'box_number': '0001',
      'postal_code': '9000',
      'municipality': 'Gent'
    });
    await db.insert('boilers', {
      ...stamp,
      'boiler_brand': 'Voorbeeld',
      'boiler_model': 'Model',
      'boiler_serial_number': 'ABC'
    });
  });

  tearDown(() => db.close());

  test('archives immutable visit data and leaves VEKA evidence untouched',
      () async {
    final id = await addVisit('2026-01-01', '2026-06-15');
    await db.update(table, {
      'veka_status': 'reported_manually_portal',
      'veka_manual_note': 'existing evidence'
    });
    await repository.finalize(id);
    final original = (await db.query(table)).single['snapshot_json'];
    await db.update('customers', {'last_name': 'Nieuw'});
    await db.update('service_locations', {'house_number': '25'});
    await db.update('boilers', {'boiler_model': 'Nieuwe ketel'});
    await repository.finalize(id);
    final row = (await db.query(table)).single;
    expect(row['snapshot_json'], original);
    expect(row['veka_manual_note'], 'existing evidence');
    expect(row['veka_status'], 'reported_manually_portal');
    final entry = (await repository.load()).entries.single;
    expect(entry.certificate.klantAchternaam, 'Aerts');
    expect(entry.certificate.locatieNr, '15');
    expect(entry.certificate.toestelType, 'Model');
    final report =
        await VekaReportRepository(database: () async => db).preview(id);
    expect(report.address, 'Kerkstraat 15 bus 0001, 9000 Gent');
    final next = await DraftRepository().getOrCreateActiveDraft(dbOverride: db);
    expect(next.id, isNot(id));
    expect(next.customerId, isNull);
    expect(
        (await db.query(table, where: 'id = ?', whereArgs: [next.id]))
            .single['boiler_id'],
        isNull);
  });

  test('blocks an unsettled edit and never archives a different visit',
      () async {
    final id = await addVisit('2026-01-01', '2026-06-15');
    await db.update(table, {'klant_undo_json': '{}'});
    await expectLater(repository.finalize(id), throwsStateError);
    await expectLater(repository.finalize(42), throwsStateError);
    expect((await db.query(table)).single['is_draft'], 1);
    expect((await repository.load()).entries, isEmpty);
  });

  test(
      'reminders use the latest archived visit per boiler and report unreadable entries',
      () async {
    final old = await addVisit('2026-01-01', '2026-06-15');
    await repository.finalize(old);
    final current = await addVisit('2026-05-01', '2026-07-01');
    await repository.finalize(current);
    await addVisit('2026-05-15', '2026-05-20');
    await db.insert(table, {
      ...stamp,
      'visit_date': '2026-05-01',
      'is_draft': 0,
      'snapshot_json': '{"format_version":99}'
    });
    final history = await repository.load();
    expect(history.unreadable, 1);
    expect(history.entries.map((entry) => entry.id), [current, old]);
    expect(history.dueWithin(DateTime(2026, 5, 31)), isEmpty);
    expect(history.dueWithin(DateTime(2026, 6, 1)).single.id, current);
  });

  testWidgets('history searches by boiler and offers a reminder share action',
      (tester) async {
    await tester.runAsync(() async {
      final id = await addVisit('2026-01-01', '2026-01-02');
      await repository.finalize(id);
    });
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: VisitHistoryScreen(repository: repository),
    )));
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
      if (find.byType(TextField).evaluate().isNotEmpty) break;
    }
    expect(find.byTooltip(VisitHistoryDictionary.reminder), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ABC');
    await tester.pump();
    expect(find.textContaining('Voorbeeld Model ABC'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'geen match');
    await tester.pump();
    expect(find.text(VisitHistoryDictionary.noResults), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('puts unfinished VEKA work at the top of history',
      (tester) async {
    late VekaApiFixture fixture;
    await tester.runAsync(() async {
      fixture = await VekaApiFixture.create();
    });
    addTearDown(fixture.close);
    final historyRepository =
        VisitHistoryRepository(database: () async => fixture.db);
    await tester
        .runAsync(() => historyRepository.finalize(VekaApiFixture.visitId));
    final loaded = await tester.runAsync(historyRepository.load);
    expect(loaded!.entries.single.reporting, VekaFollowUp.ready);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: VisitHistoryScreen(repository: historyRepository)),
    ));
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
      if (find.text(VisitHistoryDictionary.reportReady).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.text(VisitHistoryDictionary.followUp), findsOneWidget);
    expect(find.textContaining(VisitHistoryDictionary.reportReady),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
