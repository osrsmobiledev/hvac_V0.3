import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import 'archive_outcome.dart';
import 'email_outbox_repository.dart';
import 'pdf_archive_service.dart';
import 'pdf_archiving_outcome_helper.dart';

/// Coordinates post-finalization PDF archiving and email outbox creation.
///
/// This is the data-layer coordinator; UI only calls it, never executes SQL directly.
class PdfArchivingCoordinator {
  final Future<Database> Function() _database;
  final EmailOutboxRepository _outbox;
  final Directory? _documentsDirectoryOverride;

  PdfArchivingCoordinator({
    Future<Database> Function()? database,
    EmailOutboxRepository? outboxRepository,
    Directory? documentsDirectoryOverride,
  })  : _database = database ?? (() => AppDatabase.instance.database),
        _outbox = outboxRepository ?? EmailOutboxRepository(),
        _documentsDirectoryOverride = documentsDirectoryOverride;

  /// Reads the frozen snapshot for [visitId], archives the PDF, and updates
  /// `pdf_status`/`pdf_path` in SQLite strictly for finalized visits (`is_draft = 0`).
  Future<ArchiveOutcome> archiveAndUpdateStatus(int visitId) async {
    PdfArchiveResult? archiveResult;
    Map<String, Object?> snapshot = const {};
    Map<String, Object?> smtpRow = const {};
    Database? db;

    try {
      db = await _database();
      final rows = await db.query('maintenance_visits',
          columns: ['snapshot_json'],
          where: 'id = ? AND is_draft = 0',
          whereArgs: [visitId],
          limit: 1);
      if (rows.isEmpty) {
        return PdfArchivingOutcomeHelper.failureOutcome(
            'Gefinaliseerd bezoek niet gevonden.');
      }

      final snapshotJson = rows.single['snapshot_json'] as String? ?? '';
      if (snapshotJson.isEmpty) {
        await _recordFailureIfFinalized(db, visitId);
        return PdfArchivingOutcomeHelper.failureOutcome(
            'Snapshot_json is leeg.');
      }

      try {
        snapshot = jsonDecode(snapshotJson) as Map<String, Object?>;
      } catch (e, stack) {
        debugPrint(
            '[PdfArchivingCoordinator] archivePdf snapshot error: $e\n$stack');
      }

      smtpRow = await _loadSmtpRow(db);

      archiveResult = await PdfArchiveService.archiveCertificate(
        visitId: visitId,
        snapshotJson: snapshotJson,
        documentsDirectoryOverride: _documentsDirectoryOverride,
      );

      if (archiveResult.isSuccess) {
        final registered = await registerArchivedPdf(
          visitId: visitId,
          archivePath: archiveResult.archivePath,
        );
        if (!registered) {
          await _recordFailureIfFinalized(db, visitId);
          return PdfArchivingOutcomeHelper.buildOutcome(
            success: false,
            path: archiveResult.archivePath,
            isDbRegFailure: true,
            error: 'Bijwerken van pdf_status in database mislukt.',
            smtp: smtpRow,
            snapshot: snapshot,
          );
        }
      } else {
        await _recordFailureIfFinalized(db, visitId);
      }

      return PdfArchivingOutcomeHelper.buildOutcome(
        success: archiveResult.isSuccess,
        path: archiveResult.archivePath,
        error: archiveResult.errorMessage,
        smtp: smtpRow,
        snapshot: snapshot,
      );
    } catch (e) {
      debugPrint('[PdfArchivingCoordinator] Database or archive error: $e');
      try {
        final targetDb = db ?? await _database();
        await _recordFailureIfFinalized(targetDb, visitId);
      } catch (_) {
        // Fallback DB failure recording must never throw out of archiveAndUpdateStatus.
      }
      return PdfArchivingOutcomeHelper.buildOutcome(
        success: false,
        path: archiveResult?.archivePath ?? '',
        isDbRegFailure: archiveResult?.isSuccess ?? false,
        error: 'Fout bij verwerken archivering: $e',
        smtp: smtpRow,
        snapshot: snapshot,
      );
    }
  }

  /// Registers an already archived PDF path and sets `pdf_status = 'ready'` in SQLite.
  /// Strictly verifies the file exists on disk before marking the database ready.
  Future<bool> registerArchivedPdf({
    required int visitId,
    required String archivePath,
  }) async {
    if (archivePath.isEmpty || !await File(archivePath).exists()) {
      debugPrint(
          '[PdfArchivingCoordinator] register error: missing file at $archivePath');
      return false;
    }
    try {
      final db = await _database();
      final updated = await db.update(
        'maintenance_visits',
        {
          'pdf_status': 'ready',
          'pdf_path': archivePath,
          'updated_at': DateTime.now().toIso8601String()
        },
        where: 'id = ? AND is_draft = 0',
        whereArgs: [visitId],
      );
      return updated == 1;
    } catch (e) {
      debugPrint('[PdfArchivingCoordinator] register error: $e');
      return false;
    }
  }

  /// Verifies whether an archived PDF file exists on disk.
  Future<bool> archiveFileExists(String path) async {
    if (path.isEmpty) return false;
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  /// Safely deletes an unregistered archive file by delegating to [PdfArchiveService].
  Future<bool> deleteUnregisteredArchiveFile(String path) async =>
      PdfArchiveService.deleteUnregisteredArchiveFile(
        path,
        documentsDirectoryOverride: _documentsDirectoryOverride,
      );

  /// Creates queued email jobs from confirmed recipients using dictionary templates.
  Future<EmailQueueResult> createEmailJobs({
    required int visitId,
    required String pdfPath,
    required bool sendToCustomer,
    required String customerName,
    required String customerEmail,
    required bool sendToTechnician,
    required String technicianEmail,
    required String attestNumber,
    String? customerNote,
  }) async {
    if (pdfPath.trim().isEmpty) return EmailQueueResult.skipped;
    final jobs = EmailJobSpec.buildJobs(
      visitId: visitId,
      pdfPath: pdfPath,
      sendToCustomer: sendToCustomer,
      customerName: customerName,
      customerEmail: customerEmail,
      sendToTechnician: sendToTechnician,
      technicianEmail: technicianEmail,
      attestNumber: attestNumber,
      customerNote: customerNote,
    );
    if (jobs.isEmpty) return EmailQueueResult.skipped;
    final inserted = await _outbox.createJobs(jobs);
    return inserted > 0
        ? EmailQueueResult.queued
        : EmailQueueResult.alreadyQueued;
  }

  /// Loads default technician copy preference and email address from SQLite.
  Future<({bool copyTechnician, String technicianEmail})>
      loadSmtpDefaults() async {
    final db = await _database();
    final row = await _loadSmtpRow(db);
    return (
      copyTechnician: (row['email_copy_technician'] as int? ?? 1) == 1,
      technicianEmail: (row['email'] as String? ?? '').trim(),
    );
  }

  Future<Map<String, Object?>> _loadSmtpRow(Database db) async {
    try {
      final rows = await db.query('technician_profile',
          columns: ['email', 'email_copy_technician'], limit: 1);
      return rows.isNotEmpty ? rows.first : const {};
    } catch (_) {
      return const {};
    }
  }

  Future<void> _recordFailureIfFinalized(Database db, int visitId) async {
    try {
      await db.update(
        'maintenance_visits',
        {
          'pdf_status': 'failed',
          'updated_at': DateTime.now().toIso8601String()
        },
        where: 'id = ? AND is_draft = 0',
        whereArgs: [visitId],
      );
    } catch (e, stack) {
      debugPrint('[PdfArchivingCoordinator] _recordFailure error: $e\n$stack');
    }
  }

  /// Extracts attest number from a decoded snapshot map.
  static String attestNumberFromSnapshot(Map<String, Object?> snapshot) =>
      PdfArchivingOutcomeHelper.attestNumberFromSnapshot(snapshot);
}
