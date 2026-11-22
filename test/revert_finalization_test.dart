import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/features/certificate_draft/data/draft_repository.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_data_coordinator.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/klant/klant_edit_session.dart';
import 'package:hvac_app/features/customers_installations/data/customer_repository.dart';
import 'package:hvac_app/features/customers_installations/domain/customer.dart';
import 'package:hvac_app/features/customers_installations/domain/service_location.dart';
import 'package:hvac_app/features/visit_history/data/visit_history_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test(
      'revertFinalization sets is_draft=1 and pdf_status=draft without constraint error, enabling subsequent edits and cancels',
      () async {
    final db = await AppDatabase.instance.initDatabase(
      customPath: inMemoryDatabasePath,
    );
    AppDatabase.instance.setDatabaseForTesting(db);

    final draftRepo = DraftRepository();
    final customerRepo = CustomerRepository();
    final visitHistoryRepo = VisitHistoryRepository();
    final coord = KlantDataCoordinator(
      customerRepository: customerRepo,
      draftRepository: draftRepo,
    );

    // 1. App creates active draft
    final draft = await draftRepo.getOrCreateActiveDraft();
    expect(draft.id, isPositive);

    final now = DateTime.now();

    // 2. User sets up customer
    final initialCust = await customerRepo.saveCustomerWithLocation(
      customer: Customer(
        firstName: 'Test',
        lastName: 'Klant',
        email: '',
        phone: '',
        createdAt: now,
        updatedAt: now,
      ),
      location: ServiceLocation(
        customerId: 0,
        street: 'Dorpstraat',
        houseNumber: '10',
        postalCode: '1000',
        municipality: 'Brussel',
        createdAt: now,
        updatedAt: now,
      ),
      visitId: draft.id,
    );

    // 3. User finalizes the visit
    await visitHistoryRepo.finalize(draft.id);

    final rowFinalized = await db.query(
      'maintenance_visits',
      where: 'id = ?',
      whereArgs: [draft.id],
    );
    expect(rowFinalized.first['is_draft'], 0);

    // 4. User cancels: revertFinalization must succeed cleanly without NOT NULL constraint error!
    await visitHistoryRepo.revertFinalization(draft.id);

    final rowReverted = await db.query(
      'maintenance_visits',
      where: 'id = ?',
      whereArgs: [draft.id],
    );
    expect(rowReverted.first['is_draft'], 1);
    expect(rowReverted.first['pdf_status'], 'draft');

    // 5. User goes to Klant tab, edits customer, and saves!
    coord.startEditSession(
      draftId: draft.id,
      currentCustomer: initialCust.customer,
      currentLocation: initialCust.location,
    );

    final snapshot = KlantFormDataSnapshot(
      customerValues: initialCust.customer.copyWith(email: 'new@email.com'),
      locationValues: initialCust.location,
      isSameAsCustomer: true,
    );

    final saveResult =
        await coord.enqueueSave(draftId: draft.id, snapshot: snapshot);
    expect(saveResult, isNotNull);
    expect(saveResult!.customer.email, 'new@email.com');

    // 6. User can also cancel edit session cleanly!
    final cancelResult = await coord.cancelSession(draft.id);
    expect(cancelResult, isTrue);
  });
}
