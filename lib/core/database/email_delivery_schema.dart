import 'package:sqflite/sqflite.dart';

/// Shared DDL statements for `email_delivery_jobs` table and indexes.
///
/// Used both during fresh database creation ([DatabaseSchema.createAllTables])
/// and during database schema migration to version 12 ([AppDatabase.onUpgrade]).
abstract final class EmailDeliverySchema {
  static Future<void> createTablesAndIndexes(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS email_delivery_jobs (
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
        resolved_at TEXT,
        resolution_notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES maintenance_visits (id) ON DELETE RESTRICT
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_email_jobs_status ON email_delivery_jobs (status);',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_email_jobs_visit_recipient ON email_delivery_jobs (visit_id, recipient_type);',
    );
  }
}
