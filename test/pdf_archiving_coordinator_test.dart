import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/localization/email_delivery_dictionary.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late PdfArchivingCoordinator coordinator;
  late EmailOutboxRepository outbox;

  final validSnapshot = {
    'format_version': 1,
    'visit': {'attest_number': 'ATTEST-2026-99', 'activity_type': 'onderhoud'},
    'profile': {'company_name': 'Test BV', 'email': 'tech@example.com'},
    'customer': {'first_name': 'Marc', 'last_name': 'W', 'email': 'm@e.com'},
    'location': {'street': 'Dorpstraat', 'house_number': '12'},
    'boiler': {'fuel_type': 'gas'},
    'initial': <String, Object?>{},
    'low': <String, Object?>{},
    'high': <String, Object?>{},
    'technician_signature': null,
    'customer_signature': null,
  };

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coord_test_');
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => DatabaseSchema.createAllTables(db),
      ),
    );
    outbox = EmailOutboxRepository(database: () async => db);
    coordinator = PdfArchivingCoordinator(
      database: () async => db,
      outboxRepository: outbox,
      documentsDirectoryOverride: tempDir,
    );

    await db.insert('technician_profile', {
      'company_name': 'Test BV',
      'kbo_number': 'BE 0123.456.789',
      'email': 'tech@example.com',
      'email_copy_technician': 1,
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
    });
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('PdfArchivingCoordinator Unit Tests', () {
    test('successful archive updates pdf_status to ready and sets pdf_path',
        () async {
      await db.insert('maintenance_visits', {
        'id': 1,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': jsonEncode(validSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final outcome = await coordinator.archiveAndUpdateStatus(1);
      expect(outcome.archiveSuccess, isTrue);
      expect(File(outcome.archivePath).existsSync(), isTrue);
      expect(outcome.copyTechnicianDefault, isTrue);
      expect(outcome.technicianEmail, equals('tech@example.com'));

      final visitRow =
          (await db.query('maintenance_visits', where: 'id = 1')).single;
      expect(visitRow['pdf_status'], equals('ready'));
      expect(visitRow['pdf_path'], equals(outcome.archivePath));
    });

    test(
        'archive failure on finalized visit sets failed status and preserves snapshot',
        () async {
      await db.insert('maintenance_visits', {
        'id': 2,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': 'invalid-unparseable-json',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final outcome = await coordinator.archiveAndUpdateStatus(2);
      expect(outcome.archiveSuccess, isFalse);
      expect(outcome.archivePath, isEmpty);

      final visitRow =
          (await db.query('maintenance_visits', where: 'id = 2')).single;
      expect(visitRow['snapshot_json'], equals('invalid-unparseable-json'));
      expect(visitRow['pdf_status'], equals('failed'));

      final jobs = await outbox.getJobsForVisit(2);
      expect(jobs, isEmpty);
    });

    test(
        'missing finalized snapshot on a draft visit does not mark draft as failed',
        () async {
      await db.insert('maintenance_visits', {
        'id': 3,
        'visit_date': '2026-01-01',
        'is_draft': 1,
        'pdf_status': 'draft',
        'snapshot_json': null,
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final outcome = await coordinator.archiveAndUpdateStatus(3);
      expect(outcome.archiveSuccess, isFalse);

      final draftRow =
          (await db.query('maintenance_visits', where: 'id = 3')).single;
      expect(draftRow['is_draft'], equals(1));
      expect(draftRow['pdf_status'], equals('draft'));
    });

    test('registerArchivedPdf refuses to mark visit ready if file is missing',
        () async {
      await db.insert('maintenance_visits', {
        'id': 4,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': jsonEncode(validSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final missingPath = p.join(tempDir.path, 'non_existent.pdf');
      final okMissing = await coordinator.registerArchivedPdf(
        visitId: 4,
        archivePath: missingPath,
      );
      expect(okMissing, isFalse);

      final rowAfterMissing =
          (await db.query('maintenance_visits', where: 'id = 4')).single;
      expect(rowAfterMissing['pdf_status'], equals('draft'));
      expect(rowAfterMissing['pdf_path'], isNull);

      final existingFile = File(p.join(tempDir.path, 'real.pdf'))
        ..writeAsBytesSync([1, 2, 3]);
      final okExisting = await coordinator.registerArchivedPdf(
        visitId: 4,
        archivePath: existingFile.path,
      );
      expect(okExisting, isTrue);

      final rowAfterOk =
          (await db.query('maintenance_visits', where: 'id = 4')).single;
      expect(rowAfterOk['pdf_status'], equals('ready'));
      expect(rowAfterOk['pdf_path'], equals(existingFile.path));
    });

    test('createEmailJobs uses dictionary templates and prevents duplicates',
        () async {
      final result = await coordinator.createEmailJobs(
        visitId: 10,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Marc Wouters',
        customerEmail: 'marc@example.com',
        sendToTechnician: true,
        technicianEmail: 'tech@example.com',
        attestNumber: 'ATTEST-42',
      );
      expect(result, equals(EmailQueueResult.queued));

      final jobs = await outbox.getJobsForVisit(10);
      final customer =
          jobs.firstWhere((j) => j['recipient_type'] == 'customer');
      final tech = jobs.firstWhere((j) => j['recipient_type'] == 'technician');

      expect(customer['subject'],
          equals(EmailDeliveryDictionary.emailSubject('ATTEST-42')));
      expect(customer['body_text'],
          equals(EmailDeliveryDictionary.emailBodyCustomer('ATTEST-42')));
      expect(
          tech['subject'],
          equals(
              EmailDeliveryDictionary.emailSubject('ATTEST-42', isCopy: true)));
      expect(tech['body_text'],
          equals(EmailDeliveryDictionary.emailBodyTechnician));

      final retry = await coordinator.createEmailJobs(
        visitId: 10,
        pdfPath: '/path/test.pdf',
        sendToCustomer: true,
        customerName: 'Marc Wouters',
        customerEmail: 'marc@example.com',
        sendToTechnician: true,
        technicianEmail: 'tech@example.com',
        attestNumber: 'ATTEST-42',
      );
      expect(retry, equals(EmailQueueResult.alreadyQueued));
      expect((await outbox.getJobsForVisit(10)).length, equals(2));
    });

    test('canceling recipient dialog keeps archived PDF and creates no jobs',
        () async {
      await db.insert('maintenance_visits', {
        'id': 5,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': jsonEncode(validSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      final outcome = await coordinator.archiveAndUpdateStatus(5);
      expect(outcome.archiveSuccess, isTrue);

      final jobs = await outbox.getJobsForVisit(5);
      expect(jobs, isEmpty);

      final visitRow =
          (await db.query('maintenance_visits', where: 'id = 5')).single;
      expect(visitRow['pdf_status'], equals('ready'));
      expect(File(outcome.archivePath).existsSync(), isTrue);
    });
  });
}
