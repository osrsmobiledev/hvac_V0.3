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
