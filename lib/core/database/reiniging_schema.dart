import 'package:sqflite/sqflite.dart';

/// Database v14 schema definitions and idempotent migration for
/// Reinigingsattest Vlaanderen and future Combined Maintenance mode.
abstract final class ReinigingSchema {
  /// Applies all v14 schema additions idempotently.
  ///
  /// Called from both [DatabaseSchema.createAllTables] (`onCreate`) and
  /// [AppDatabase] (`onUpgrade` when `oldVersion < 14`) to guarantee
  /// 100% parity between fresh installs and upgraded databases.
  static Future<void> applyV14(Database db) async {
    await _addColumnsIfMissing(db, 'technician_profile', const {
      'is_erkend_technicus': 'INTEGER NOT NULL DEFAULT 1',
      'is_schoorsteenveger': 'INTEGER NOT NULL DEFAULT 0',
    });

    await _addColumnsIfMissing(db, 'maintenance_visits', const {
      'certificate_type': "TEXT NOT NULL DEFAULT 'verbranding'",
      'technician_role_erkend': 'INTEGER NOT NULL DEFAULT 1',
      'technician_role_schoorsteenveger': 'INTEGER NOT NULL DEFAULT 0',
      'remedial_measures_notes': 'TEXT',
      'next_chimney_inspection_date': 'TEXT',
      'reiniging_pdf_path': 'TEXT',
    });

    await db.execute('''
      CREATE TABLE IF NOT EXISTS reiniging_controls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL UNIQUE,
        flue_sweeping INTEGER NOT NULL DEFAULT 0,
        flue_good_operation_check INTEGER NOT NULL DEFAULT 0,
        flue_backdraft_check INTEGER NOT NULL DEFAULT 0,
        all_other_checked INTEGER NOT NULL DEFAULT 0,
        all_other_text TEXT,
        all_ventilation_check INTEGER NOT NULL DEFAULT 0,
        all_flue_tightness_check INTEGER NOT NULL DEFAULT 0,
        gas_dust_removal INTEGER NOT NULL DEFAULT 0,
        gas_burner_bed_exchanger INTEGER NOT NULL DEFAULT 0,
        gas_fan_burner INTEGER NOT NULL DEFAULT 0,
        liquid_filters INTEGER NOT NULL DEFAULT 0,
        liquid_boiler INTEGER NOT NULL DEFAULT 0,
        liquid_burner INTEGER NOT NULL DEFAULT 0,
        solid_general_condition INTEGER NOT NULL DEFAULT 0,
        solid_internal_cleaning INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES maintenance_visits (id) ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reiniging_visit ON reiniging_controls (visit_id);',
    );
  }

  static Future<void> _addColumnsIfMissing(
    Database db,
    String table,
    Map<String, String> columns,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?;",
      [table],
    );
    if (tables.isEmpty) return;

    final info = await db.rawQuery('PRAGMA table_info($table);');
    final existing = info.map((r) => r['name'] as String).toSet();
    for (final entry in columns.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value};',
        );
      }
    }
  }
}
