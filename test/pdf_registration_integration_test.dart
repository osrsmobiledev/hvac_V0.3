import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/email_outbox_repository.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archive_service.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late Database db;
  late EmailOutboxRepository outbox;
  late PdfArchivingCoordinator coordinator;

  const validSnapshot = {
    'format_version': 1,
    'visit': {'attest_number': 'AT-INT-42', 'activity_type': 'onderhoud'},
    'profile': {'company_name': 'Warmte BV', 'email': 'tech@warmte.be'},
    'customer': {
      'first_name': 'Luc',
      'last_name': 'Claes',
      'email': 'luc@example.com'
    },
    'location': {'street': 'Kerkstraat', 'house_number': '5'},
    'boiler': {'fuel_type': 'gas'},
    'initial': <String, Object?>{},
    'low': <String, Object?>{},
    'high': <String, Object?>{},
    'technician_signature': null,
    'customer_signature': null,
  };

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reg_integ_test_');
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
      'company_name': 'Warmte BV',
      'kbo_number': 'BE 0123.456.789',
      'email': 'tech@warmte.be',
      'email_copy_technician': 1,
      'created_at': '2026-01-01',
      'updated_at': '2026-01-01',
    });
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('PDF Registration Integration Recovery Tests', () {
    test('retry registers same archived file without generating second copy',
        () async {
      await db.insert('maintenance_visits', {
        'id': 42,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': jsonEncode(validSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      // Force failure during pdf_status update
      await db.execute(
        "CREATE TRIGGER block_pdf_reg BEFORE UPDATE OF pdf_status "
        "ON maintenance_visits BEGIN SELECT RAISE(FAIL, 'locked'); END;",
      );

      final outcome = await coordinator.archiveAndUpdateStatus(42);

      // Outcome accurately indicates database registration failure while file exists
      expect(outcome.archiveSuccess, isFalse);
      expect(outcome.isDatabaseRegistrationFailure, isTrue);
      expect(outcome.archivePath, isNotEmpty);
      expect(File(outcome.archivePath).existsSync(), isTrue);

      final certDir = Directory(p.join(tempDir.path, 'certificates'));
      final generatedFiles = certDir.listSync().whereType<File>().toList();
      expect(generatedFiles.length, equals(1));
      expect(generatedFiles.single.path, equals(outcome.archivePath));

      // Simulate database recovery: drop trigger
      await db.execute('DROP TRIGGER block_pdf_reg;');

      // Retry registration with identical archived path
      final retrySuccess = await coordinator.registerArchivedPdf(
        visitId: 42,
        archivePath: outcome.archivePath,
      );
      expect(retrySuccess, isTrue);

      // Verify SQLite state: ready and matching path
      final rows = await db
          .query('maintenance_visits', where: 'id = ?', whereArgs: [42]);
      expect(rows.single['pdf_status'], equals('ready'));
      expect(rows.single['pdf_path'], equals(outcome.archivePath));

      // Verify no second PDF was generated
      final filesAfter = certDir.listSync().whereType<File>().toList();
      expect(filesAfter.length, equals(1));
      expect(filesAfter.single.path, equals(outcome.archivePath));
    });

    test(
        'skip after registration failure deletes file and keeps visit finalized',
        () async {
      await db.insert('maintenance_visits', {
        'id': 43,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'draft',
        'snapshot_json': jsonEncode(validSnapshot),
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      await db.execute(
        "CREATE TRIGGER block_pdf_reg_43 BEFORE UPDATE OF pdf_status "
        "ON maintenance_visits BEGIN SELECT RAISE(FAIL, 'locked'); END;",
      );

      final outcome = await coordinator.archiveAndUpdateStatus(43);
      expect(outcome.archiveSuccess, isFalse);
      expect(outcome.isDatabaseRegistrationFailure, isTrue);
      expect(File(outcome.archivePath).existsSync(), isTrue);

      // Skip registration failure: clean up unregistered file
      final deleted = await PdfArchiveService.deleteUnregisteredArchiveFile(
        outcome.archivePath,
        documentsDirectoryOverride: tempDir,
      );
      expect(deleted, isTrue);

      // Unregistered file is safely deleted from disk
      expect(File(outcome.archivePath).existsSync(), isFalse);

      // Visit remains finalized in SQLite with unready status
      final rows = await db
          .query('maintenance_visits', where: 'id = ?', whereArgs: [43]);
      expect(rows.single['is_draft'], equals(0));
      expect(rows.single['pdf_status'], isNot(equals('ready')));
    });
  });
}
