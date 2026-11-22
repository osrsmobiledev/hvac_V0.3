import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/database/app_database.dart';
import 'package:hvac_app/core/database/database_schema.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Schema v13 Tests', () {
    test(
        'fresh v13 database creation includes resolved_at and resolution_notes',
        () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseSchema.version,
          onCreate: (db, _) => DatabaseSchema.createAllTables(db),
        ),
      );

      final cols = await db.rawQuery('PRAGMA table_info(email_delivery_jobs);');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, contains('resolved_at'));
      expect(names, contains('resolution_notes'));
      await db.close();
    });

    test(
        'real v12 to v13 upgrade via AppDatabase.onUpgrade preserves existing data and adds new columns',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('v13_upgrade_test_');
      final dbPath = p.join(tempDir.path, 'v12_app.db');

      // 1. Build genuine v12 database without resolved_at and resolution_notes
      final v12Db = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 12,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                last_name TEXT NOT NULL,
                first_name TEXT,
                email TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE technician_profile (
                id INTEGER PRIMARY KEY,
                company_name TEXT,
                kbo_number TEXT,
                email TEXT,
                smtp_host TEXT,
                smtp_port INTEGER,
                smtp_username TEXT,
                smtp_state TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE maintenance_visits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL,
                visit_date TEXT NOT NULL,
                is_draft INTEGER NOT NULL DEFAULT 0,
                pdf_status TEXT NOT NULL DEFAULT 'ready',
                pdf_path TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE email_delivery_jobs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                visit_id INTEGER NOT NULL,
                recipient_type TEXT NOT NULL,
                recipient_name TEXT NOT NULL,
                recipient_email TEXT NOT NULL,
                original_recipient_email TEXT NOT NULL,
                subject TEXT NOT NULL,
                body_text TEXT NOT NULL,
                pdf_path TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'queued',
                failure_reason TEXT,
                attempt_count INTEGER NOT NULL DEFAULT 0,
                sent_at TEXT,
                last_error TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
          },
        ),
      );

      // Populate representative v12 data
      await v12Db.insert('customers', {
        'id': 1,
        'last_name': 'Janssens',
        'first_name': 'Peter',
        'email': 'peter@example.com',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });
      await v12Db.insert('technician_profile', {
        'id': 1,
        'company_name': 'Test BV',
        'kbo_number': '0123.456.789',
        'email': 'tech@example.com',
        'smtp_host': 'smtp.gmail.com',
        'smtp_port': 465,
        'smtp_username': 'tech@example.com',
        'smtp_state': 'configured',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });
      await v12Db.insert('maintenance_visits', {
        'id': 100,
        'customer_id': 1,
        'visit_date': '2026-01-01',
        'is_draft': 0,
        'pdf_status': 'ready',
        'pdf_path': '/path/cert.pdf',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });
      await v12Db.insert('email_delivery_jobs', {
        'id': 1,
        'visit_id': 100,
        'recipient_type': 'customer',
        'recipient_name': 'Peter Janssens',
        'recipient_email': 'peter@example.com',
        'original_recipient_email': 'peter@example.com',
        'subject': 'Attest',
        'body_text': 'Hierbij uw attest',
        'pdf_path': '/path/cert.pdf',
        'status': 'queued',
        'attempt_count': 0,
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });
      await v12Db.insert('email_delivery_jobs', {
        'id': 2,
        'visit_id': 100,
        'recipient_type': 'technician',
        'recipient_name': 'Tech',
        'recipient_email': 'tech@example.com',
        'original_recipient_email': 'tech@example.com',
        'subject': 'Kopie Attest',
        'body_text': 'Kopie',
        'pdf_path': '/path/cert.pdf',
        'status': 'sent',
        'attempt_count': 1,
        'sent_at': '2026-01-01T12:00:00',
        'created_at': '2026-01-01',
        'updated_at': '2026-01-01',
      });

      // Verify v12 lacked the v13 columns
      final beforeCols =
          await v12Db.rawQuery('PRAGMA table_info(email_delivery_jobs);');
      final beforeNames = beforeCols.map((c) => c['name'] as String).toSet();
      expect(beforeNames.contains('resolved_at'), isFalse);
      expect(beforeNames.contains('resolution_notes'), isFalse);
      await v12Db.close();

      // 2. Reopen through actual app v13 migration path
      final migratedDb =
          await AppDatabase.instance.initDatabase(customPath: dbPath);

      // Verify columns were added by AppDatabase.onUpgrade
      final afterCols =
          await migratedDb.rawQuery('PRAGMA table_info(email_delivery_jobs);');
      final afterNames = afterCols.map((c) => c['name'] as String).toSet();
      expect(afterNames, contains('resolved_at'));
      expect(afterNames, contains('resolution_notes'));

      // Verify customer, profile, and visit data remain intact
      final customer =
          (await migratedDb.query('customers', where: 'id = 1')).single;
      expect(customer['last_name'], equals('Janssens'));

      final profile =
          (await migratedDb.query('technician_profile', where: 'id = 1'))
              .single;
      expect(profile['smtp_host'], equals('smtp.gmail.com'));
      expect(profile['smtp_state'], equals('configured'));

      final visit =
          (await migratedDb.query('maintenance_visits', where: 'id = 100'))
              .single;
      expect(visit['pdf_status'], equals('ready'));

      // Verify queued and sent jobs preserved with exact fields
      final queuedJob =
          (await migratedDb.query('email_delivery_jobs', where: 'id = 1'))
              .single;
      expect(queuedJob['status'], equals('queued'));
      expect(queuedJob['attempt_count'], equals(0));
      expect(queuedJob['resolved_at'], isNull);

      final sentJob =
          (await migratedDb.query('email_delivery_jobs', where: 'id = 2'))
              .single;
      expect(sentJob['status'], equals('sent'));
      expect(sentJob['sent_at'], equals('2026-01-01T12:00:00'));

      // Verify new columns are operational
      await migratedDb.update(
        'email_delivery_jobs',
        {
          'status': 'resolved_manually',
          'resolved_at': '2026-01-02T10:00:00',
          'resolution_notes': 'Manueel bevestigd',
        },
        where: 'id = 1',
      );
      final updatedJob =
          (await migratedDb.query('email_delivery_jobs', where: 'id = 1'))
              .single;
      expect(updatedJob['status'], equals('resolved_manually'));
      expect(updatedJob['resolution_notes'], equals('Manueel bevestigd'));

      await migratedDb.close();
      await tempDir.delete(recursive: true);
    });
  });
}
