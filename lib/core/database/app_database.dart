import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'database_schema.dart';

/// Central database service managing the SQLite connection for offline draft safety.
///
/// Features:
/// - Enforces relational integrity (`PRAGMA foreign_keys = ON`).
/// - Initializes the 6 core tables on first launch.
/// - Supports in-memory database injection for unit and integration testing.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  AppDatabase._internal();

  /// Returns the open database instance, initializing it if necessary.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database on persistent disk storage.
  Future<Database> initDatabase({String? customPath}) async {
    final String dbPath = customPath ?? await _getDefaultPath();

    return await openDatabase(
      dbPath,
      version: DatabaseSchema.version,
      onConfigure: (db) async {
        // Enforce foreign key constraints across all relationships
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await DatabaseSchema.createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE technician_profile ADD COLUMN box_number TEXT;',
          );
        }
        if (oldVersion < 3) {
          // Columns added for Slice 3.1: Stooktoestel compliance
          const newColumns = [
            'ALTER TABLE boilers ADD COLUMN is_central INTEGER NOT NULL DEFAULT 1;',
            'ALTER TABLE boilers ADD COLUMN centraal_type TEXT;',
            'ALTER TABLE boilers ADD COLUMN type_b_text TEXT;',
            'ALTER TABLE boilers ADD COLUMN type_c_text TEXT;',
            'ALTER TABLE boilers ADD COLUMN heating_type TEXT DEFAULT "individueel";',
            'ALTER TABLE boilers ADD COLUMN boiler_operation TEXT DEFAULT "condenserend";',
            'ALTER TABLE boilers ADD COLUMN fuel_other_text TEXT;',
            'ALTER TABLE boilers ADD COLUMN burner_technology TEXT DEFAULT "premix";',
            'ALTER TABLE boilers ADD COLUMN boiler_brand_unknown INTEGER NOT NULL DEFAULT 0;',
            'ALTER TABLE boilers ADD COLUMN boiler_model_unknown INTEGER NOT NULL DEFAULT 0;',
            'ALTER TABLE boilers ADD COLUMN boiler_serial_number_unknown INTEGER NOT NULL DEFAULT 0;',
            'ALTER TABLE boilers ADD COLUMN boiler_construction_year_unknown INTEGER NOT NULL DEFAULT 0;',
            'ALTER TABLE boilers ADD COLUMN burner_flow_rate TEXT;',
          ];
          for (final query in newColumns) {
            try {
              await db.execute(query);
            } catch (e, stack) {
              debugPrint('[AppDatabase] migration query warning: $e\n$stack');
            }
          }
        }
        if (oldVersion < 4) {
          // Columns added for Slice 3.2: Meting & measurement captures
          const metingColumns = [
            'ALTER TABLE maintenance_visits ADD COLUMN gas_pressure_meter_mbar REAL;',
            'ALTER TABLE maintenance_visits ADD COLUMN gas_pressure_block_mbar REAL;',
            'ALTER TABLE maintenance_visits ADD COLUMN gas_pressure_burner_bed_mbar REAL;',
            'ALTER TABLE maintenance_visits ADD COLUMN nozzle_brand_type TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN nozzle_flow_rate TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN nozzle_angle_degrees REAL;',
            'ALTER TABLE maintenance_visits ADD COLUMN pump_pressure_bar REAL;',
            'ALTER TABLE maintenance_visits ADD COLUMN smoke_index_bacharach INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN smoke_index_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN no_oil_trace_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN no_unwanted_condensation_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN rarely_polluting_smoke_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN flue_pressure_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN flue_tightness_ok INTEGER;',
            'ALTER TABLE maintenance_visits ADD COLUMN fuel_supply_tightness_ok INTEGER;',
            'ALTER TABLE measurement_captures ADD COLUMN co_mg_kwh REAL;',
            'ALTER TABLE measurement_captures ADD COLUMN co_ok INTEGER;',
            'ALTER TABLE measurement_captures ADD COLUMN combustion_efficiency_hi_ok INTEGER;',
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_meas_vis_slot ON measurement_captures (visit_id, slot);',
          ];
          for (final query in metingColumns) {
            try {
              await db.execute(query);
            } catch (e, stack) {
              debugPrint(
                  '[AppDatabase] v4 migration query warning: $e\n$stack');
            }
          }
        }
        if (oldVersion < 5) {
          // Columns added for official VEKA JSON API schema alignment
          const vekaColumns = [
            'ALTER TABLE maintenance_visits ADD COLUMN verbrandingscontrole TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN stooktoestel_conform TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN rookgasafvoerkanaal_conform TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN stookplaats_conform TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN toestel_werking_goed TEXT;',
            'ALTER TABLE maintenance_visits ADD COLUMN toestel_werking_veilig TEXT;',
          ];
          for (final query in vekaColumns) {
            try {
              await db.execute(query);
            } catch (e, stack) {
              debugPrint(
                  '[AppDatabase] v5 migration query warning: $e\n$stack');
            }
          }
        }
      },
    );
  }

  /// Resolves the default persistent file path for the SQLite database.
  Future<String> _getDefaultPath() async {
    final String databasesPath = await getDatabasesPath();
    return p.join(databasesPath, DatabaseSchema.databaseName);
  }

  /// Closes the database connection safely.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Deletes the local SQLite database file (useful for test isolation or clean wipe).
  Future<void> deleteDatabaseFile({String? customPath}) async {
    await close();
    final String dbPath = customPath ?? await _getDefaultPath();
    await deleteDatabase(dbPath);
  }

  /// Allows test suites to inject an in-memory or mock Database instance directly.
  void setDatabaseForTesting(Database db) {
    _database = db;
  }
}
