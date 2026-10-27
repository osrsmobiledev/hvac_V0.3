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
