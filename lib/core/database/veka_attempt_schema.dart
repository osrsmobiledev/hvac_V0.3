import 'package:sqflite/sqflite.dart';

const vekaApiAttemptsTable = 'veka_api_attempts';
const vekaApiDispatchesTable = 'veka_api_dispatches';

/// API evidence is independent from the technician's manual portal record.
Future<void> createVekaAttemptTables(Database db) async {
  await db.execute('''
    CREATE TABLE $vekaApiAttemptsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      visit_id INTEGER NOT NULL REFERENCES maintenance_visits(id),
      request_reference TEXT NOT NULL UNIQUE,
      request_json TEXT NOT NULL,
      report_json TEXT NOT NULL,
      contract_version TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      resolved_at TEXT,
      response_status INTEGER,
      response_json TEXT,
      receipt_number TEXT,
      dispatch_number INTEGER NOT NULL DEFAULT 1
    )
  ''');
  await db.execute(
    'CREATE INDEX idx_veka_api_visit ON $vekaApiAttemptsTable (visit_id, id DESC)',
  );
  await db.execute('''
    CREATE TABLE $vekaApiDispatchesTable (
      attempt_id INTEGER NOT NULL REFERENCES $vekaApiAttemptsTable(id),
      dispatch_number INTEGER NOT NULL,
      started_at TEXT NOT NULL,
      finished_at TEXT,
      status TEXT NOT NULL,
      response_status INTEGER,
      response_json TEXT,
      PRIMARY KEY (attempt_id, dispatch_number)
    )
  ''');
}
