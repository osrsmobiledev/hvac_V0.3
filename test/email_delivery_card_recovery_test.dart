import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/app/localization/email_failure_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:hvac_app/features/pdf_export/data/pdf_visit_data.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'email_delivery_mock_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late File dummyPdf;

  Future<Database> openSeededDb(String name) async {
    final opened = await databaseFactoryFfi.openDatabase(
      p.join(tempDir.path, name),
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (d, _) => DatabaseSchema.createAllTables(d),
      ),
    );
    await opened.insert('technician_profile', <String, Object?>{
      'id': 1,
      'company_name': 'Warmte BV',
      'kbo_number': '0123.456.789',
      'email': 'tech@example.com',
      'email_copy_technician': 1,
      'smtp_state': 'configured',
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01',
    });
    await opened.insert('maintenance_visits', <String, Object?>{
      'id': 42,
      'visit_date': '2026-02-01',
      'is_draft': 0,
      'pdf_status': 'ready',
      'pdf_path': dummyPdf.path,
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01',
    });
    return opened;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('card_recovery_test_');
    dummyPdf = File(p.join(tempDir.path, 'test_cert.pdf'))
      ..writeAsBytesSync([1, 2, 3, 4]);
    db = await openSeededDb('main.db');
  });

  tearDown(() async {
    if (db.isOpen) await db.close();
    try {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  Future<void> pumpCard(WidgetTester tester) async {
    for (int i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Widget buildCard({
    required EmailOutboxRepository outbox,
    required PdfArchivingCoordinator archiving,
    required EmailDeliveryCoordinatorMockWrapper coord,
    required PdfVisitData visitData,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmailDeliveryCard(
              visitId: 42,
              outboxRepository: outbox,
              coordinator: coord.coordinator,
              archivingCoordinator: archiving,
              visitDataLoader: (_) async => visitData,
            ),
          ),
        ),
      );

  testWidgets(
      'Load failure clears spinner, shows error view, and recovers on retry',
      (tester) async {
    final closedDb = await tester.runAsync(() => openSeededDb('closed.db'));
    await tester.runAsync(() => closedDb!.close());

    Database activeDb = closedDb!;
    final outbox = EmailOutboxRepository(database: () async => activeDb);
    final archiving = PdfArchivingCoordinator(
      database: () async => activeDb,
      outboxRepository: outbox,
    );
    final coord = EmailDeliveryCoordinatorMockWrapper(db);

    await tester.pumpWidget(buildCard(
      outbox: outbox,
      archiving: archiving,
      coord: coord,
      visitData: const PdfVisitData(volgnummerAttest: 'ATT-1'),
    ));
    await pumpCard(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(EmailFailureDictionary.trackerLoadError), findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.actionRetry), findsOneWidget);

    activeDb = db;
    await tester.tap(find.text(EmailDeliveryDictionary.actionRetry));
    await pumpCard(tester);

    expect(find.text(EmailFailureDictionary.trackerLoadError), findsNothing);
    expect(find.text(EmailDeliveryDictionary.trackerNoJobs), findsOneWidget);
  });

  testWidgets('Alsnog e-mailen queues customer and technician jobs',
      (tester) async {
    final outbox = EmailOutboxRepository(database: () async => db);
    final archiving = PdfArchivingCoordinator(
      database: () async => db,
      outboxRepository: outbox,
    );
    final coord = EmailDeliveryCoordinatorMockWrapper(db);

    await tester.pumpWidget(buildCard(
      outbox: outbox,
      archiving: archiving,
      coord: coord,
      visitData: const PdfVisitData(
        volgnummerAttest: 'ATT-2026-01',
        klantNaam: 'Jan Peeters',
        klantEmail: 'jan@example.com',
      ),
    ));
    await pumpCard(tester);

    await tester.tap(find.text(EmailDeliveryDictionary.actionSendEmailLater));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.recipientDialogTitle),
        findsOneWidget);
    await tester.tap(find.text(EmailDeliveryDictionary.finalizeAndEmailAction));
    await pumpCard(tester);

    final jobs = await tester.runAsync(() => outbox.getJobsForVisit(42));
    expect(jobs, hasLength(2));
    expect(find.text(EmailDeliveryDictionary.badgeQueued), findsNWidgets(2));
  });

  testWidgets(
      'Alsnog e-mailen Option A allows technician-only dispatch without customer email',
      (tester) async {
    final outbox = EmailOutboxRepository(database: () async => db);
    final archiving = PdfArchivingCoordinator(
      database: () async => db,
      outboxRepository: outbox,
    );
    final coord = EmailDeliveryCoordinatorMockWrapper(db);

    await tester.pumpWidget(buildCard(
      outbox: outbox,
      archiving: archiving,
      coord: coord,
      visitData: const PdfVisitData(
        volgnummerAttest: 'ATT-2026-02',
        klantNaam: 'Marie Janssens',
        klantEmail: '',
      ),
    ));
    await pumpCard(tester);

    await tester.tap(find.text(EmailDeliveryDictionary.actionSendEmailLater));
    await pumpCard(tester);

    expect(find.text(EmailDeliveryDictionary.recipientNoCustomerEmail),
        findsOneWidget);
    await tester.tap(
        find.text(EmailDeliveryDictionary.finalizeTechnicianCopyOnlyAction));
    await pumpCard(tester);

    final jobs = await tester.runAsync(() => outbox.getJobsForVisit(42));
    expect(jobs, hasLength(1));
    expect(jobs!.single['recipient_type'], 'technician');
    expect(find.text(EmailDeliveryDictionary.badgeQueued), findsOneWidget);
  });

  testWidgets('Alsnog e-mailen cancel leaves outbox empty', (tester) async {
    final outbox = EmailOutboxRepository(database: () async => db);
    final archiving = PdfArchivingCoordinator(
      database: () async => db,
      outboxRepository: outbox,
    );
    final coord = EmailDeliveryCoordinatorMockWrapper(db);

    await tester.pumpWidget(buildCard(
      outbox: outbox,
      archiving: archiving,
      coord: coord,
      visitData: const PdfVisitData(
        volgnummerAttest: 'ATT-2026-03',
        klantNaam: 'Jan Peeters',
        klantEmail: 'jan@example.com',
      ),
    ));
    await pumpCard(tester);

    await tester.tap(find.text(EmailDeliveryDictionary.actionSendEmailLater));
    await pumpCard(tester);

    await tester.tap(find.text(EmailDeliveryDictionary.recipientDialogAbort));
    await pumpCard(tester);

    final jobs = await tester.runAsync(() => outbox.getJobsForVisit(42));
    expect(jobs, isEmpty);
    expect(find.text(EmailDeliveryDictionary.trackerNoJobs), findsOneWidget);
  });
}

class EmailDeliveryCoordinatorMockWrapper {
  final MockEmailDeliveryCoordinator coordinator;
  EmailDeliveryCoordinatorMockWrapper(Database db)
      : coordinator = MockEmailDeliveryCoordinator(db: db);
}
