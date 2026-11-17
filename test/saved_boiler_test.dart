import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/saved_boiler_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/certificate_draft/data/saved_boiler_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/boiler_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/stooktoestel/saved_boiler_picker.dart';
import 'package:hvac_app/features/visit_history/data/visit_history_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late SavedBoilerRepository repo;
  late int draftId;
  const table = 'maintenance_visits';
  const stamp = {'created_at': '2026-10-01', 'updated_at': '2026-10-01'};

  Future<int> archive(int location, String serial,
      {String model = 'Model'}) async {
    final boiler = BoilerDraft(
      boilerBrand: 'Voorbeeld',
      boilerModel: model,
      boilerSerialNumber: serial,
      fuelCategory: 'gas',
      fuelSubtype: 'aardgas',
      heatingType: 'collectief',
      boilerOperation: 'condenserend',
      burnerBrand: 'Brander',
      isCentral: true,
    );
    final boilerId = await db.insert('boilers', {...boiler.toMap(), ...stamp});
    final id = await db.insert(table, {
      ...stamp,
      'customer_id': 1,
      'service_location_id': location,
      'boiler_id': boilerId,
      'visit_date': '2026-10-01',
      'veka_status': 'reported_manually_portal',
      'veka_manual_note': 'original evidence',
    });
    await VisitHistoryRepository(database: () async => db).finalize(id);
    return id;
  }

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) => DatabaseSchema.createAllTables(db)));
    repo = SavedBoilerRepository(database: () async => db);
    await db.insert('customers', {...stamp, 'last_name': 'Aerts'});
    for (final bus in ['0001', '0002', '1', null]) {
      await db.insert('service_locations', {
        ...stamp,
        'customer_id': 1,
        'street': 'Kerkstraat',
        'house_number': '15',
        'municipality': 'Gent',
        'postal_code': '9000',
        'box_number': bus,
      });
    }
    draftId = await db.insert(table, {
      ...stamp,
      'customer_id': 1,
      'service_location_id': 1,
      'visit_date': '2026-11-14',
    });
  });

  tearDown(() => db.close());

  Future<Map<String, Object?>> readVisit(int id) async =>
      (await db.query(table, where: 'id = ?', whereArgs: [id])).single;

  test(
      'finds multiple boilers at the exact address and preserves leading zeros',
      () async {
    await db.update('customers', {
      'street': 'Facturatiestraat',
      'house_number': '99',
    });
    await archive(1, 'First');
    await archive(1, 'Second');
    await archive(1, 'First');
    await archive(2, 'Other apartment');
    await archive(3, 'Different bus spelling');
    await archive(4, 'No bus');
    final result = await repo.listForVisit(draftId);
    expect(result.location.boxNumber, '0001');
    expect(result.boilers.map((item) => item.boiler.boilerSerialNumber),
        ['First', 'Second']);
  });

  test(
      'copies archived boiler data independently of the source visit and live edits',
      () async {
    final source = await archive(1, 'ABC');
    final before = await readVisit(source);
    await db.update('boilers', {'boiler_model': 'Other live value'});
    final choice = await repo.listForVisit(draftId);
    final copied = await repo.copyToVisit(draftId, choice, source);
    expect(copied.id, isNot(before['boiler_id']));
    expect(copied.serviceLocationId, 1);
    expect(copied.boilerModel, 'Model');
    expect(copied.burnerBrand, 'Brander');
    expect(copied.heatingType, 'collectief');
    final draft = await readVisit(draftId);
    expect(draft['boiler_id'], copied.id);
    expect(draft['veka_status'], 'not_submitted');
    expect(draft['veka_manual_note'], isNull);
    expect(await readVisit(source), before);
    final replacement = await archive(1, 'DEF', model: 'Andere ketel');
    final nextChoice = await repo.listForVisit(draftId);
    final updated = await repo.copyToVisit(draftId, nextChoice, replacement);
    expect(updated.id, copied.id);
    expect(updated.boilerSerialNumber, 'DEF');
    final reopened =
        (await db.query('boilers', where: 'id = ?', whereArgs: [updated.id]))
            .single;
    expect(BoilerDraft.fromMap(reopened).boilerModel, 'Andere ketel');
    expect(await readVisit(source), before);
  });

  test(
      'uses the archived bus and rejects a stale picker or a draft with reporting evidence',
      () async {
    final source = await archive(1, 'ABC');
    final choice = await repo.listForVisit(draftId);
    await db.update('service_locations', {'box_number': '0003'},
        where: 'id = 1');
    await expectLater(repo.copyToVisit(draftId, choice, source),
        throwsA(isA<SavedBoilerException>()));
    expect((await repo.listForVisit(draftId)).boilers, isEmpty);
    await db.update('service_locations', {'box_number': '0001'},
        where: 'id = 1');
    await db.update(table, {'veka_manual_note': 'draft evidence'},
        where: 'id = ?', whereArgs: [draftId]);
    await expectLater(
        repo.copyToVisit(draftId, choice, source),
        throwsA(
          isA<SavedBoilerException>().having((error) => error.problem,
              'problem', SavedBoilerProblem.visitStarted),
        ));
    expect((await readVisit(draftId))['boiler_id'], isNull);
  });

  testWidgets('shows the bus and waits for explicit selection and confirmation',
      (tester) async {
    await tester.runAsync(() async {
      await archive(1, 'First', model: 'Ketel A');
      await archive(1, 'Second', model: 'Ketel B');
      await archive(2, 'Other', model: 'Andere bus');
    });
    BoilerDraft? copied;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: SavedBoilerPicker(
          visitId: draftId,
          repository: repo,
          onCopied: (value) => copied = value),
    )));
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 60; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump(const Duration(milliseconds: 30));
        if (finder.evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 250));
          return;
        }
      }
      fail('Missing $finder');
    }

    await tester.tap(find.text(SavedBoilerDictionary.open));
    await waitFor(find.text(SavedBoilerDictionary.choose));
    expect(find.text('Kerkstraat 15 bus 0001, 9000 Gent'), findsOneWidget);
    expect(find.text('Voorbeeld Andere bus'), findsNothing);
    final confirm =
        find.widgetWithText(FilledButton, SavedBoilerDictionary.choose);
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.tap(find.text('Voorbeeld Ketel B'));
    await tester.pumpAndSettle();
    expect(copied, isNull);
    await tester.tap(confirm);
    await waitFor(find.text(SavedBoilerDictionary.done));
    expect(copied?.boilerSerialNumber, 'Second');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
