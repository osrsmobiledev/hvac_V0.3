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

  Future<Set<String>> colNames(Database db, String table) async {
    final cols = await db.rawQuery('PRAGMA table_info($table);');
    return cols.map((c) => c['name'] as String).toSet();
  }

  group('Database Schema v14 (Reiniging) Tests', () {
    test('fresh v14 creation has Reiniging columns, table, and CASCADE FK',
        () async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: DatabaseSchema.version,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON;'),
          onCreate: (db, _) => DatabaseSchema.createAllTables(db),
        ),
      );

      final profCols = await colNames(db, 'technician_profile');
      expect(profCols,
          containsAll(['is_erkend_technicus', 'is_schoorsteenveger']));

      final visitCols = await colNames(db, 'maintenance_visits');
      expect(
        visitCols,
        containsAll([
          'certificate_type',
          'technician_role_erkend',
          'technician_role_schoorsteenveger',
          'remedial_measures_notes',
          'next_chimney_inspection_date',
          'reiniging_pdf_path',
        ]),
      );

      final ctrlCols = await colNames(db, 'reiniging_controls');
      expect(
        ctrlCols,
        containsAll([
          'visit_id',
          'flue_sweeping',
          'all_other_checked',
          'all_other_text',
          'solid_internal_cleaning',
        ]),
      );

      // Verify ON DELETE CASCADE removes reiniging_controls when visit deleted.
      final now = DateTime.now().toIso8601String();
      final visitId = await db.insert('maintenance_visits', {
        'visit_date': '2026-11-26',
        'is_draft': 1,
        'created_at': now,
        'updated_at': now,
      });
      await db.insert('reiniging_controls', {
        'visit_id': visitId,
        'flue_sweeping': 1,
        'created_at': now,
        'updated_at': now,
      });
      await db
          .delete('maintenance_visits', where: 'id = ?', whereArgs: [visitId]);
      final remaining = await db.query('reiniging_controls',
          where: 'visit_id = ?', whereArgs: [visitId]);
      expect(remaining, isEmpty);

      await db.close();
    });

    test('v13 to v14 upgrade via AppDatabase preserves data and matches v14',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('v14_upgrade_test_');
      final dbPath = p.join(tempDir.path, 'v13_app.db');
      final now = DateTime.now().toIso8601String();

      final v13Db = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 13,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE technician_profile (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                company_name TEXT NOT NULL,
                kbo_number TEXT NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            await db.execute('''
              CREATE TABLE maintenance_visits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                visit_date TEXT NOT NULL,
                is_draft INTEGER NOT NULL DEFAULT 1,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              );
            ''');
            await db.insert('technician_profile', {
              'company_name': 'HVAC BV',
              'kbo_number': '0123456789',
              'created_at': now,
              'updated_at': now,
            });
            await db.insert('maintenance_visits', {
              'visit_date': '2026-11-26',
              'is_draft': 1,
              'created_at': now,
              'updated_at': now,
            });
          },
        ),
      );
      await v13Db.close();

      final appDb = AppDatabase.instance;
      final upgraded = await appDb.initDatabase(customPath: dbPath);

      final profiles = await upgraded.query('technician_profile');
      expect(profiles.single['company_name'], 'HVAC BV');
      expect(profiles.single['is_erkend_technicus'], 1);
      expect(profiles.single['is_schoorsteenveger'], 0);

      final visits = await upgraded.query('maintenance_visits');
      expect(visits.single['certificate_type'], 'verbranding');
      expect(visits.single['technician_role_erkend'], 1);
      expect(visits.single['technician_role_schoorsteenveger'], 0);

      final ctrlCols = await colNames(upgraded, 'reiniging_controls');
      expect(ctrlCols,
          containsAll(['visit_id', 'flue_sweeping', 'all_other_text']));

      await upgraded.close();
      await appDb.close();
      await tempDir.delete(recursive: true);
    });
  });
}
