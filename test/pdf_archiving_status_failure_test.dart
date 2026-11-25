import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:hvac_app/features/email_delivery/data/pdf_archiving_coordinator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FailingRegisterCoordinator extends PdfArchivingCoordinator {
  _FailingRegisterCoordinator({
    required super.database,
    super.documentsDirectoryOverride,
  });

  @override
  Future<bool> registerArchivedPdf({
    required int visitId,
    required String archivePath,
  }) async =>
      false;
}

class _ThrowingRegisterCoordinator extends PdfArchivingCoordinator {
  _ThrowingRegisterCoordinator({
    required super.database,
    super.documentsDirectoryOverride,
  });

  @override
  Future<bool> registerArchivedPdf({
    required int visitId,
    required String archivePath,
  }) async =>
      throw StateError('Simulated unexpected registration exception');
}

Future<Database> _openTestDbWithFinalizedVisit() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) => DatabaseSchema.createAllTables(db),
    ),
  );
  final validSnapshot = {
    'format_version': 1,
    'visit': {'attest_number': 'ATT-1', 'activity_type': 'onderhoud'},
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
  await db.insert('maintenance_visits', {
    'id': 1,
    'is_draft': 0,
    'activity_type': 'onderhoud',
    'visit_date': '2026-10-31',
    'pdf_status': 'draft',
    'snapshot_json': jsonEncode(validSnapshot),
    'created_at': '2026-10-31T10:00:00',
    'updated_at': '2026-10-31T10:00:00',
  });
  return db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('PdfArchivingCoordinator failure status recording', () {
    test('records pdf_status = failed when registerArchivedPdf returns false',
        () async {
      final db = await _openTestDbWithFinalizedVisit();
      final tempDir = await Directory.systemTemp.createTemp('pdf_fail_reg_');
      addTearDown(() async {
        await db.close();
        await tempDir.delete(recursive: true);
      });

      final coordinator = _FailingRegisterCoordinator(
        database: () async => db,
        documentsDirectoryOverride: tempDir,
      );
      final outcome = await coordinator.archiveAndUpdateStatus(1);

      expect(outcome.archiveSuccess, isFalse);
      expect(outcome.isDatabaseRegistrationFailure, isTrue);

      final rows = await db.query(
        'maintenance_visits',
        columns: ['pdf_status'],
        where: 'id = 1',
      );
      expect(rows.single['pdf_status'], 'failed');
    });

    test('records pdf_status = failed when outer catch runs after DB is opened',
        () async {
      final db = await _openTestDbWithFinalizedVisit();
      final tempDir = await Directory.systemTemp.createTemp('pdf_fail_throw_');
      addTearDown(() async {
        await db.close();
        await tempDir.delete(recursive: true);
      });

      final coordinator = _ThrowingRegisterCoordinator(
        database: () async => db,
        documentsDirectoryOverride: tempDir,
      );
      final outcome = await coordinator.archiveAndUpdateStatus(1);

      expect(outcome.archiveSuccess, isFalse);

      final rows = await db.query(
        'maintenance_visits',
        columns: ['pdf_status'],
        where: 'id = 1',
      );
      expect(rows.single['pdf_status'], 'failed');
    });

    test('does not throw when _database() fails before opening DB', () async {
      final coordinator = PdfArchivingCoordinator(
        database: () async => throw StateError('DB open failed'),
      );

      final outcome = await coordinator.archiveAndUpdateStatus(1);

      expect(outcome.archiveSuccess, isFalse);
      expect(outcome.errorMessage, contains('DB open failed'));
    });
  });
}
