import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/veka_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_conformity_repository.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/measurement_draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'package:hvac_app/features/certificate_draft/domain/operating_conditions_draft.dart';
import 'package:hvac_app/features/reporting_delivery/data/veka_report_repository.dart';
import 'package:hvac_app/features/reporting_delivery/ui/veka_tracker.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory dir;
  late Database db;
  late VekaReportRepository repo;
  const visit = 'maintenance_visits';
  Future<Database> open() => databaseFactoryFfi.openDatabase(
        '${dir.path}/veka.db',
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) => DatabaseSchema.createAllTables(db)),
      );
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hvac_veka_');
    db = await open();
    repo = VekaReportRepository(database: () async => db);
    final stamp = {'created_at': '2025-01-01', 'updated_at': '2025-01-01'};
    await db.insert('customers', {...stamp, 'last_name': 'Voorbeeld'});
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
      'is_central': 1,
      'fuel_type': 'gas',
      'fuel_subtype': 'aardgas',
      'heating_type': 'individueel',
      'boiler_operation': 'condenserend',
      'burner_technology': 'premix',
      'boiler_brand_unknown': 1,
      'boiler_model_unknown': 1,
      'boiler_serial_number_unknown': 1,
      'boiler_construction_year_unknown': 1,
      'boiler_nominal_power_kw': 30
    });
    await db.insert('technician_profile', {
      ...stamp,
      'company_name': 'Voorbeeld',
      'kbo_number': 'BE 0123.456.789',
      'technician_first_name': 'Jan',
      'technician_last_name': 'Voorbeeld',
      'gv_number': 'gv 12345'
    });
    await db.insert(visit, {
      ...stamp,
      'visit_date': '2025-01-01',
      'activity_type': 'onderhoud',
      'service_location_id': 1,
      'boiler_id': 1,
      'stooktoestel_conform': 'NOK',
      'rookgasafvoerkanaal_conform': 'OK',
      'stookplaats_conform': 'OK',
      'verbrandingscontrole': 'OK',
      'toestel_werking_goed': 'Niet goed',
      'toestel_werking_veilig': 'Veilig'
    });
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });
  test('reopens and confirms the original address despite draft changes',
      () async {
    final preview = await repo.preview(1);
    expect((await db.query(visit)).single['veka_manual_note'], isNull);
    expect(preview.missingTabs(DateTime.now()), isEmpty);
    expect(preview.section('installation_address')['adres_id'], isNull);
    final a = (await repo.reserve(preview, replaces: null)).report!;
    await db.update('service_locations', {'house_number': '25'});
    await db.update('technician_profile', {'technician_first_name': 'Piet'});
    await db.update('boilers', {'is_central': 0});
    await db.update(visit, {'klant_undo_json': '{}'});
    await db.close();
    db = await open();
    repo = VekaReportRepository(database: () async => db);
    expect((await repo.read(1)).report!.address,
        'Kerkstraat 15 bus 0001, 9000 Gent');
    await expectLater(repo.preview(1), throwsA(isA<VekaException>()));
    final confirmed =
        await repo.confirm(1, a.id!, actor: 'Jan', reference: 'TEST');
    expect(confirmed.report!.section('technician')['technician_first_name'],
        'Jan');
    expect((await repo.confirm(1, a.id!, actor: 'Piet')).confirmation,
        confirmed.confirmation);
    final row = (await db.query(visit)).single;
    expect(row['veka_status'], 'reported_manually_portal');
    expect(row['snapshot_json'], isNull);
    expect(row['is_draft'], 1);
    expect(row['pdf_status'], 'draft');
  });
  test('identifies the specific invalid company and technician fields',
      () async {
    await db.update(
        'technician_profile', {'gv_number': '12345', 'kbo_number': '123'});
    await db.update(visit, {'visit_date': '2999-01-01'});
    final report = await repo.preview(1);
    expect(report.technicianIssues(DateTime.now()),
        ['visit_date', 'kbo_number', 'GV']);
    expect(report.missingTabs(DateTime.now()), [3]);
    await db.update('boilers', {'heating_type': '', 'boiler_operation': ''});
    expect((await repo.preview(1)).missingTabs(DateTime.now()), [3, 7]);
    await db.update('boilers', {
      'heating_type': 'collectief',
      'boiler_operation': 'niet_condenserend',
    });
    final updated = await repo.preview(1);
    expect(updated.missingTabs(DateTime.now()), [3]);
    final keys = updated.previewJson;
    expect((keys['gegevensActiviteit'] as Map)['verwarmingType'], 'collectief');
    expect((keys['kenmerkenToestel'] as Map)['werking'], 'niet_condenserend');
  });
  test('serializes competing reservations and rejects stale confirmation',
      () async {
    final preview = await repo.preview(1);
    final results = await Future.wait([
      for (int i = 0; i < 2; i++)
        repo
            .reserve(preview, replaces: null)
            .then((value) => value.report!.id)
            .onError<VekaException>((_, __) => null),
    ]);
    expect(results.whereType<String>(), hasLength(1));
    final a = results.whereType<String>().single;
    await db.update('service_locations', {'house_number': '25'});
    await expectLater(
        repo.reserve(preview, replaces: a), throwsA(isA<VekaException>()));
    final b = await repo.reserve(await repo.preview(1), replaces: a);
    await expectLater(
        repo.confirm(1, a, actor: 'Jan'), throwsA(isA<VekaException>()));
    expect((await repo.read(1)).report!.id, b.report!.id);
  });
  test('preserves unknown evidence and rolls back a failed report write',
      () async {
    await db.update(visit, {'veka_manual_note': '{"format_version":99}'});
    await expectLater(repo.read(1), throwsFormatException);
    await expectLater(repo.reserve(await repo.preview(1), replaces: null),
        throwsFormatException);
    expect((await db.query(visit)).single['veka_manual_note'],
        '{"format_version":99}');
    await db.update(visit, {'veka_manual_note': null});
    final a =
        (await repo.reserve(await repo.preview(1), replaces: null)).report!;
    await db.execute("CREATE TRIGGER broken_write BEFORE UPDATE OF veka_status "
        "ON maintenance_visits BEGIN SELECT RAISE(ABORT, 'test'); END");
    await expectLater(repo.confirm(1, a.id!, actor: 'Jan'),
        throwsA(isA<DatabaseException>()));
    expect((await repo.read(1)).confirmed, isFalse);
    expect((await repo.read(1)).report!.id, a.id);
  });
  test('measurement write rolls back and preserves Tab 7 conclusions',
      () async {
    final provider = AppDatabase.instance..setDatabaseForTesting(db);
    final measurements = MeasurementDraftRepository(dbProvider: provider);
    const condition = OperatingConditionsDraft(
        stooktoestelConform: 'OK', toestelWerkingGoed: 'Goed');
    final slots = {'proef1': MeasurementSlotDraft.empty('proef1')};
    await db.execute(
        "CREATE TRIGGER broken_slot BEFORE INSERT ON measurement_captures "
        "BEGIN SELECT RAISE(ABORT, 'test'); END");
    await expectLater(measurements.saveMeting(1, condition, slots),
        throwsA(isA<DatabaseException>()));
    expect((await db.query(visit)).single['stooktoestel_conform'], 'NOK');
    await db.execute('DROP TRIGGER broken_slot');
    await measurements.saveMeting(1, condition, slots);
    final saved = (await db.query(visit)).single;
    expect(saved['stooktoestel_conform'], 'NOK');
    final conformity = VekaConformityRepository(database: () async => db);
    await conformity.save(1, {VekaConformity.appliance: 'OK'});
    expect((await conformity.load(1))[VekaConformity.appliance], 'OK');
    final json = (await repo.preview(1)).previewJson;
    expect((json['eindbeoordeling'] as Map)['stooktoestelConform'], 'OK');
    expect(saved['toestel_werking_goed'], 'Niet goed');
    expect((await db.query('measurement_captures')).single['slot'], 'proef1');
  });
  testWidgets('portal opens only after storage and failure leaves A available',
      (tester) async {
    var calls = 0;
    String? addressAtLaunch;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: VekaTracker(
          visitId: 1,
          repository: repo,
          openPortal: () async {
            calls++;
            addressAtLaunch = (await repo.read(1)).report!.address;
            throw StateError('No browser');
          }),
    ))));
    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 50; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump(const Duration(milliseconds: 50));
        if (finder.evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 250));
          return;
        }
      }
      fail('Widget never appeared: $finder');
    }

    Future<void> tap(String label) async {
      final text = find.text(label);
      await waitFor(text);
      final item = text.last;
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pump();
    }

    await tap(VekaDictionary.current);
    await waitFor(find.text('Kerkstraat 15 bus 0001, 9000 Gent'));
    expect(find.text(VekaDictionary.reserve), findsNothing);
    expect(calls, 0);
    await tap('OK');
    await tap(VekaDictionary.open);
    await waitFor(find.text(VekaDictionary.portalReview));
    expect(find.text(VekaDictionary.portalReviewHint), findsOneWidget);
    await tap(VekaDictionary.reserve);
    await waitFor(find.text(VekaDictionary.launchError));
    expect(calls, 1);
    expect(addressAtLaunch, 'Kerkstraat 15 bus 0001, 9000 Gent');
    await tap(VekaDictionary.saved);
    await waitFor(find.text('Kerkstraat 15 bus 0001, 9000 Gent'));
    expect(find.text(VekaDictionary.pending), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
