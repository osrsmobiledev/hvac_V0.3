import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

/// Recipient category used in `email_delivery_jobs.recipient_type`.
enum RecipientType {
  customer('customer'),
  technician('technician');

  final String value;
  const RecipientType(this.value);
}

/// Result of creating queued email delivery jobs.
enum EmailQueueResult {
  /// One or more email jobs were newly inserted into the queue.
  queued,

  /// Jobs were already in the queue (skipped as idempotent duplicates).
  alreadyQueued,

  /// No recipients were selected or available; no jobs created.
  skipped,
}

/// Data needed to create a queued email delivery job.
class EmailJobSpec {
  final int visitId;
  final RecipientType recipientType;
  final String recipientName;
  final String recipientEmail;
  final String subject;
  final String bodyText;
  final String pdfPath;

  const EmailJobSpec({
    required this.visitId,
    required this.recipientType,
    required this.recipientName,
    required this.recipientEmail,
    required this.subject,
    required this.bodyText,
    required this.pdfPath,
  });
}

/// Repository that atomically creates queued email delivery jobs.
///
/// Jobs are inserted into `email_delivery_jobs` with `status = 'queued'`.
/// A UNIQUE index on `(visit_id, recipient_type)` prevents duplicates;
/// `INSERT OR IGNORE` silently skips any already-queued job for the same pair.
class EmailOutboxRepository {
  final Future<Database> Function() _database;

  EmailOutboxRepository({Future<Database> Function()? database})
      : _database = database ?? (() => AppDatabase.instance.database);

  /// Atomically inserts one or more [jobs] into `email_delivery_jobs`.
  ///
  /// Uses INSERT OR IGNORE so that re-running finalization (e.g. after a
  /// crash) does not create duplicate jobs for the same visit + recipient.
  /// Returns the number of jobs actually inserted (0 if all were duplicates).
  Future<int> createJobs(List<EmailJobSpec> jobs) async {
    if (jobs.isEmpty) return 0;
    final db = await _database();
    return db.transaction((tx) async {
      var inserted = 0;
      final now = DateTime.now().toIso8601String();
      for (final job in jobs) {
        await tx.rawInsert(
          '''INSERT OR IGNORE INTO email_delivery_jobs
               (visit_id, recipient_type, recipient_name, recipient_email,
                original_recipient_email, subject, body_text, pdf_path,
                status, attempt_count, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'queued', 0, ?, ?)''',
          [
            job.visitId,
            job.recipientType.value,
            job.recipientName,
            job.recipientEmail,
            job.recipientEmail, // original_recipient_email = same at creation
            job.subject,
            job.bodyText,
            job.pdfPath,
            now,
            now,
          ],
        );
        final changes = Sqflite.firstIntValue(
              await tx.rawQuery('SELECT changes()'),
            ) ??
            0;
        inserted += changes;
      }
      return inserted;
    });
  }

  /// Returns all queued jobs for [visitId] (used for idempotency checks
  /// and for verifying test outcomes).
  Future<List<Map<String, Object?>>> getJobsForVisit(int visitId) async {
    final db = await _database();
    return db.query(
      'email_delivery_jobs',
      where: 'visit_id = ?',
      whereArgs: [visitId],
      orderBy: 'created_at ASC',
    );
  }
}
