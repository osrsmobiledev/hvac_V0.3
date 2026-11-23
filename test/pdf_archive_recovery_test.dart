import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/archive_outcome.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:hvac_app/features/email_delivery/ui/email_delivery_card.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'email_delivery_mock_coordinator.dart';

class _MockArchivingCoordinator extends PdfArchivingCoordinator {
  final Future<Database> Function() _db;
  bool shouldSucceed;
  String? mockArchivePath;
  int retryCalls = 0;

  _MockArchivingCoordinator({
    required Future<Database> Function() database,
    this.shouldSucceed = true,
    this.mockArchivePath,
  })  : _db = database,
        super(database: database);

  @override
  Future<bool> archiveFileExists(String path) async =>
      mockArchivePath != null && path == mockArchivePath;

  @override
  Future<ArchiveOutcome> archiveAndUpdateStatus(int visitId) async {
    retryCalls++;
    final db = await _db();
    final path = mockArchivePath ?? '/data/cert_$visitId.pdf';
    await db.update(
      'maintenance_visits',
      {
        'pdf_status': shouldSucceed ? 'ready' : 'failed',
        if (shouldSucceed) 'pdf_path': path,
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
    return ArchiveOutcome(
      archiveSuccess: shouldSucceed,
      archivePath: shouldSucceed ? path : '',
      errorMessage: shouldSucceed ? null : 'Schijffout bij wegschrijven',
      copyTechnicianDefault: true,
      technicianEmail: shouldSucceed ? 'tech@example.com' : '',
      snapshot: const {},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late EmailOutboxRepository outbox;
  const snapshotJson = '{"visit":{"attest_number":"ATTEST-001"}}';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdf_recov_test_');
    db = await databaseFactoryFfi.openDatabase(
      p.join(tempDir.path, 'test.db'),
      options: OpenDatabaseOptions(
        version: DatabaseSchema.version,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);

    await db.insert('technician_profile', {
      'id': 1,
      'company_name': 'Warmte BV',
      'kbo_number': '0123.456.789',
      'email': 'warmte@example.com',
      'smtp_state': 'configured',
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01',
    });
    await db.insert('maintenance_visits', {
      'id': 42,
      'visit_date': '2026-02-01',
      'is_draft': 0,
      'pdf_status': 'failed',
      'pdf_path': null,
      'snapshot_json': snapshotJson,
      'created_at': '2026-02-01',
      'updated_at': '2026-02-01',
    });
  });

  tearDown(() async {
    await db.close();
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

  test('Email jobs cannot be queued with an empty PDF path', () async {
    final coordinator = PdfArchivingCoordinator(
      database: () async => db,
      outboxRepository: outbox,
    );
    for (final badPath in ['', '   ']) {
      final res = await coordinator.createEmailJobs(
        visitId: 42,
        pdfPath: badPath,
        sendToCustomer: true,
        customerName: 'Klant',
        customerEmail: 'klant@example.com',
        sendToTechnician: true,
        technicianEmail: 'tech@example.com',
        attestNumber: 'ATTEST-001',
      );
      expect(res, equals(EmailQueueResult.skipped));
    }
    expect(await outbox.getJobsForVisit(42), isEmpty);

    expect(
      EmailJobSpec.buildJobs(
        visitId: 42,
        pdfPath: '',
        sendToCustomer: true,
        customerName: 'Klant',
        customerEmail: 'klant@example.com',
        sendToTechnician: true,
        technicianEmail: 'tech@example.com',
        attestNumber: 'ATTEST-001',
      ),
      isEmpty,
    );
  });

  testWidgets('A failed archive can be retried successfully from Historiek',
      (tester) async {
    final validPdfFile = File(p.join(tempDir.path, 'valid.pdf'))
      ..writeAsBytesSync([1, 2, 3]);
    final mockArchiver = _MockArchivingCoordinator(
      database: () async => db,
      shouldSucceed: true,
      mockArchivePath: validPdfFile.path,
    );
    final mockDelivery = MockEmailDeliveryCoordinator(db: db);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
          visitId: 42,
          outboxRepository: outbox,
          coordinator: mockDelivery,
          archivingCoordinator: mockArchiver,
        ),
      ),
    ));
    await pumpCard(tester);

    final retryButton = find.text(EmailDeliveryDictionary.actionRetryArchive);
    expect(retryButton, findsOneWidget);

    final emailButton = tester.widget<FilledButton>(
      find.widgetWithText(
          FilledButton, EmailDeliveryDictionary.actionSendEmailLater),
    );
    expect(emailButton.onPressed, isNull);

    final shareButton = tester.widget<OutlinedButton>(
      find.widgetWithText(
          OutlinedButton, EmailDeliveryDictionary.actionSharePdf),
    );
    expect(shareButton.onPressed, isNull);

    await tester.tap(retryButton);
    await pumpCard(tester);

    expect(mockArchiver.retryCalls, equals(1));
    expect(find.text(EmailDeliveryDictionary.archiveSuccess), findsOneWidget);
    expect(find.text(EmailDeliveryDictionary.actionRetryArchive), findsNothing);

    final emailButtonAfter = tester.widget<FilledButton>(
      find.widgetWithText(
          FilledButton, EmailDeliveryDictionary.actionSendEmailLater),
    );
    expect(emailButtonAfter.onPressed, isNotNull);

    final shareButtonAfter = tester.widget<OutlinedButton>(
      find.widgetWithText(
          OutlinedButton, EmailDeliveryDictionary.actionSharePdf),
    );
    expect(shareButtonAfter.onPressed, isNotNull);
  });

  testWidgets('A failed retry preserves the visit and reports the failure',
      (tester) async {
    final mockArchiver = _MockArchivingCoordinator(
      database: () async => db,
      shouldSucceed: false,
    );
    final mockDelivery = MockEmailDeliveryCoordinator(db: db);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmailDeliveryCard(
          visitId: 42,
          outboxRepository: outbox,
          coordinator: mockDelivery,
          archivingCoordinator: mockArchiver,
        ),
      ),
    ));
    await pumpCard(tester);

    final retryButton = find.text(EmailDeliveryDictionary.actionRetryArchive);
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await pumpCard(tester);

    expect(mockArchiver.retryCalls, equals(1));
    expect(find.text('Schijffout bij wegschrijven'), findsOneWidget);

    final visitRows = await tester.runAsync(
      () => db.query('maintenance_visits', where: 'id = 42'),
    );
    expect(visitRows!.length, equals(1));
    final visit = visitRows.first;
    expect(visit['is_draft'], equals(0));
    expect(visit['snapshot_json'], equals(snapshotJson));
    expect(visit['pdf_status'], equals('failed'));

    expect(
        find.text(EmailDeliveryDictionary.actionRetryArchive), findsOneWidget);
  });
}
