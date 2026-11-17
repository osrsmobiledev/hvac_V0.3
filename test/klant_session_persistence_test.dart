import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_data_coordinator.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_edit_session.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final appDb = AppDatabase.instance;
  late Database db;
  late KlantDataCoordinator coordinator;
  late int draftId;

  setUp(() async {
    db = await appDb.initDatabase(customPath: inMemoryDatabasePath);
    appDb.setDatabaseForTesting(db);
    coordinator = KlantDataCoordinator();
    final draft = await coordinator.loadDraftData();
    draftId = draft.draftId;
    coordinator.startNewSession(draftId: draftId);
  });

  tearDown(appDb.close);

  test('v9 draft migration preserves the finalized snapshot field', () async {
    final directory = await Directory.systemTemp.createTemp('hvac_schema_v9_');
    final path = '${directory.path}/draft.sqlite';
    addTearDown(() async {
      await databaseFactory.deleteDatabase(path);
      await directory.delete();
    });
    final legacy = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 9,
        onCreate: (db, _) => db.execute('''
          CREATE TABLE maintenance_visits (id INTEGER PRIMARY KEY, snapshot_json TEXT)
        '''),
      ),
    );
    await legacy.insert('maintenance_visits', {'id': 1, 'snapshot_json': '{}'});
    await legacy.close();

    final upgraded = await appDb.initDatabase(customPath: path);
    try {
      final existing = (await upgraded.query('maintenance_visits')).single;
      expect(existing['snapshot_json'], '{}');
      expect(existing, containsPair('klant_undo_json', null));
    } finally {
      await upgraded.close();
    }
  });

  test('SQLite rejecting undo data rolls back all autosave records', () async {
    await db.execute('''
      CREATE TRIGGER reject_undo_write
      BEFORE UPDATE OF klant_undo_json ON maintenance_visits
      WHEN NEW.klant_undo_json IS NOT NULL
      BEGIN SELECT RAISE(ABORT, 'test rejects undo data'); END
    ''');

    await expectLater(
      coordinator.enqueueSave(draftId: draftId, snapshot: _snapshot('Aerts')),
      throwsA(isA<DatabaseException>()),
    );
    expect(await db.query('customers'), isEmpty);
    expect(await db.query('service_locations'), isEmpty);
    final failedDraft = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(failedDraft.customerId, isNull);
    expect(failedDraft.serviceLocationId, isNull);
    expect(failedDraft.klantUndoJson, isNull);

    await db.execute('DROP TRIGGER reject_undo_write');
    final retried = await coordinator.enqueueSave(
      draftId: draftId,
      snapshot: _snapshot('Aerts'),
    );
    final savedDraft = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(savedDraft.customerId, retried!.customer.id);
    expect(savedDraft.serviceLocationId, retried.location.id);
    expect(savedDraft.klantUndoJson, isNotNull);
  });

  test('SQLite rejecting undo cleanup rolls back final Opslaan values',
      () async {
    final autosaved = (await coordinator.enqueueSave(
      draftId: draftId,
      snapshot: _snapshot('Aerts'),
    ))!;
    final before = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(before.klantUndoJson, isNotNull);
    await db.execute('''
      CREATE TRIGGER reject_undo_cleanup
      BEFORE UPDATE OF klant_undo_json ON maintenance_visits
      WHEN OLD.klant_undo_json IS NOT NULL AND NEW.klant_undo_json IS NULL
      BEGIN SELECT RAISE(ABORT, 'test rejects undo cleanup'); END
    ''');

    final failed = await coordinator.confirmSave(
      draftId: draftId,
      snapshot: _snapshot('Bogaert', street: 'Kouter'),
    );
    expect(failed, isNull);
    final afterFailure = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(afterFailure.klantUndoJson, before.klantUndoJson);
    expect(afterFailure.customerId, autosaved.customer.id);
    expect(afterFailure.serviceLocationId, autosaved.location.id);
    final customer =
        await coordinator.customerRepo.getCustomerById(autosaved.customer.id!);
    expect(customer?.lastName, 'Aerts');
    final locations = await coordinator.customerRepo.getLocationsForCustomer(
      autosaved.customer.id!,
    );
    expect(locations.single.street, 'Kerkstraat');

    await db.execute('DROP TRIGGER reject_undo_cleanup');
    final retried = await coordinator.confirmSave(
      draftId: draftId,
      snapshot: _snapshot('Bogaert', street: 'Kouter'),
    );
    expect(retried!.customer.id, autosaved.customer.id);
    expect(retried.customer.lastName, 'Bogaert');
    expect(retried.location.id, autosaved.location.id);
    expect(retried.location.street, 'Kouter');
    final afterRetry = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(afterRetry.klantUndoJson, isNull);
  });

  test('Annuleren preserves a session location now used by a boiler', () async {
    final autosaved = (await coordinator.enqueueSave(
      draftId: draftId,
      snapshot: _snapshot('Aerts'),
    ))!;
    final date = DateTime.now().toIso8601String();
    final boilerId = await db.insert('boilers', {
      'service_location_id': autosaved.location.id,
      'created_at': date,
      'updated_at': date,
    });

    expect(await coordinator.cancelSession(draftId), isTrue);
    final draft = await coordinator.draftRepo.getOrCreateActiveDraft();
    expect(draft.customerId, isNull);
    expect(draft.serviceLocationId, isNull);
    expect(draft.klantUndoJson, isNull);
    expect(await db.query('boilers'), [
      containsPair('id', boilerId),
    ]);
    final locations = await coordinator.customerRepo.getLocationsForCustomer(
      autosaved.customer.id!,
    );
    expect(locations.single.id, autosaved.location.id);
    expect(
      await coordinator.customerRepo.getCustomerById(autosaved.customer.id!),
      isNotNull,
    );
  });
}

KlantFormDataSnapshot _snapshot(String lastName,
    {String street = 'Kerkstraat'}) {
  final now = DateTime.now();
  return KlantFormDataSnapshot(
    customerValues: Customer(
      lastName: lastName,
      street: street,
      createdAt: now,
      updatedAt: now,
    ),
    locationValues: ServiceLocation(
      customerId: 0,
      street: street,
      houseNumber: '5',
      postalCode: '9000',
      municipality: 'Gent',
      createdAt: now,
      updatedAt: now,
    ),
  );
}
