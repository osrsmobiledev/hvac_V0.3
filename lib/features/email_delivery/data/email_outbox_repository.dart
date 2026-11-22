import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import 'email_job_models.dart';

export 'email_job_models.dart';

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

  /// Returns the archived PDF path for [visitId] from maintenance_visits.
  Future<String?> getPdfPathForVisit(int visitId) async {
    final db = await _database();
    final rows = await db.query(
      'maintenance_visits',
      columns: ['pdf_path'],
      where: 'id = ?',
      whereArgs: [visitId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['pdf_path'] as String?;
  }

  /// Returns all jobs with `status = 'queued'` ordered by creation time.
  Future<List<Map<String, Object?>>> getQueuedJobs() async {
    final db = await _database();
    return db.query(
      'email_delivery_jobs',
      where: "status = 'queued'",
      orderBy: 'created_at ASC',
    );
  }

  /// Atomically claims a job for sending by transitioning from 'queued' to 'sending'
  /// and incrementing attempt_count. Returns true if successfully claimed.
  Future<bool> claimJob(int jobId) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final changes = await db.rawUpdate(
      '''UPDATE email_delivery_jobs
         SET status = 'sending', attempt_count = attempt_count + 1, updated_at = ?
         WHERE id = ? AND status = 'queued' ''',
      [now, jobId],
    );
    return changes == 1;
  }

  /// Marks a job as successfully sent with the confirmed delivery timestamp.
  Future<void> markSent(int jobId, {required String sentAt}) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    await db.update(
      'email_delivery_jobs',
      {
        'status': 'sent',
        'sent_at': sentAt,
        'failure_reason': null,
        'last_error': null,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  /// Marks a job as failed with specific status and structured reason.
  Future<void> markFailed(
    int jobId, {
    required String status,
    required String failureReason,
    String? lastError,
  }) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    await db.update(
      'email_delivery_jobs',
      {
        'status': status,
        'failure_reason': failureReason,
        'last_error': lastError,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  /// Corrects a rejected recipient email in place while preserving original_recipient_email.
  ///
  /// Restricted to jobs in 'recipient_rejected' or 'failed' status.
  Future<bool> updateRecipientEmail(int jobId, String newEmail) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final count = await db.update(
      'email_delivery_jobs',
      {
        'recipient_email': newEmail.trim(),
        'status': 'queued',
        'failure_reason': null,
        'last_error': null,
        'updated_at': now,
      },
      where: "id = ? AND status IN ('recipient_rejected', 'failed')",
      whereArgs: [jobId],
    );
    return count > 0;
  }

  /// Re-queues an uncertain or failed job for a technician-authorized retry.
  ///
  /// Restricted to jobs in 'uncertain_timeout', 'server_rejected', or 'failed' status.
  Future<bool> requeueJob(int jobId) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final count = await db.update(
      'email_delivery_jobs',
      {'status': 'queued', 'updated_at': now},
      where:
          "id = ? AND status IN ('uncertain_timeout', 'server_rejected', 'failed')",
      whereArgs: [jobId],
    );
    return count > 0;
  }

  /// Marks an uncertain delivery as resolved manually, preserving previous failure details.
  Future<bool> markResolvedManually(
    int jobId, {
    required String resolvedAt,
    required String notes,
  }) async {
    final trimmed = notes.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Resolution notes must not be empty.');
    }
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    final count = await db.update(
      'email_delivery_jobs',
      {
        'status': 'resolved_manually',
        'resolved_at': resolvedAt,
        'resolution_notes': trimmed,
        'updated_at': now,
      },
      where:
          "id = ? AND status IN ('uncertain_timeout', 'recipient_rejected', 'server_rejected', 'failed')",
      whereArgs: [jobId],
    );
    return count > 0;
  }

  /// Recovers any crashed in-flight 'sending' jobs by transitioning them to 'uncertain_timeout'.
  Future<int> recoverStaleSendingJobs() async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    return db.rawUpdate(
      '''UPDATE email_delivery_jobs
         SET status = 'uncertain_timeout',
             failure_reason = 'uncertain_timeout',
             last_error = 'Onderbroken tijdens verzenden (stale sending recovery)',
             updated_at = ?
         WHERE status = 'sending' ''',
      [now],
    );
  }
}
