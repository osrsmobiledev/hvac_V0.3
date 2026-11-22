import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

import '../../../core/database/app_database.dart';
import 'email_outbox_repository.dart';
import 'email_send_outcome.dart';
import 'email_sender_service.dart';
import 'email_settings_model.dart';
import 'email_settings_repository.dart';
import 'secure_credential_store.dart';

export 'email_send_outcome.dart' show OutboxDispatchResult;

/// Orchestrates outbox preflight testing, atomic claiming, and safe SMTP delivery.
///
/// Follows Golden Rule #5: delivery errors never invalidate the finalized visit or PDF.
/// Follows Golden Rule #7: offline basement visits leave jobs 'queued' with attempt_count = 0.
class EmailDeliveryCoordinator {
  static final Lock _sharedLock = Lock();
  static EmailDeliveryCoordinator? _instance;

  /// Process-wide app-scoped coordinator instance.
  static EmailDeliveryCoordinator get instance =>
      _instance ??= EmailDeliveryCoordinator();

  /// Inject custom coordinator instance for testing.
  static set instanceForTesting(EmailDeliveryCoordinator? coordinator) {
    _instance = coordinator;
  }

  final Future<Database> Function() _database;
  final EmailOutboxRepository _outbox;
  final EmailSettingsRepository? _settingsRepo;
  final ISecureCredentialStore _secureStore;
  final EmailSenderService _sender;
  final Lock _lock;

  EmailDeliveryCoordinator({
    Future<Database> Function()? database,
    EmailOutboxRepository? outboxRepository,
    EmailSettingsRepository? settingsRepository,
    ISecureCredentialStore? credentialStore,
    EmailSenderService? senderService,
    Lock? lock,
  })  : _database = database ?? (() => AppDatabase.instance.database),
        _outbox = outboxRepository ?? EmailOutboxRepository(database: database),
        _settingsRepo = settingsRepository,
        _secureStore = credentialStore ?? const SecureCredentialStore(),
        _sender = senderService ?? EmailSenderService(),
        _lock = lock ?? _sharedLock;

  /// Loads current email settings for status display and preflight validation.
  Future<EmailSettings> loadSettings() async {
    final db = await _database();
    final repo = _settingsRepo ??
        EmailSettingsRepository(db: db, secureStore: _secureStore);
    return repo.loadSettings();
  }

  /// Processes all pending outbox jobs under isolate-level [Lock].
  ///
  /// Set [forceManual] to true when triggered explicitly by technician action,
  /// bypassing the `email_auto_send == 0` automatic resume suppression.
  Future<OutboxDispatchResult> processOutbox({bool forceManual = false}) async {
    try {
      return await _lock.synchronized(() async {
        return await _processOutboxLocked(forceManual: forceManual);
      });
    } catch (e, stack) {
      debugPrint('[EmailDeliveryCoordinator] processOutbox error: $e\n$stack');
      return OutboxDispatchResult.offline;
    }
  }

  Future<OutboxDispatchResult> _processOutboxLocked(
      {required bool forceManual}) async {
    await _outbox.recoverStaleSendingJobs();

    final queued = await _outbox.getQueuedJobs();
    if (queued.isEmpty) return OutboxDispatchResult.noQueuedJobs;

    final db = await _database();
    final settingsRepo = _settingsRepo ??
        EmailSettingsRepository(db: db, secureStore: _secureStore);

    final settings = await settingsRepo.loadSettings();
    if (!settings.isConfigured) return OutboxDispatchResult.unconfigured;
    if (!forceManual && !settings.autoSend) {
      return OutboxDispatchResult.noQueuedJobs;
    }

    final password = await _secureStore.getPassword();
    if (password == null || password.isEmpty) {
      await settingsRepo.updateSmtpState('needs_attention');
      return OutboxDispatchResult.needsAttention;
    }

    final preflight = await _sender.testConnection(
      settings: settings,
      password: password,
    );
    if (preflight != SmtpConnectionResult.success) {
      if (preflight == SmtpConnectionResult.authenticationFailed) {
        await settingsRepo.updateSmtpState('needs_attention');
        return OutboxDispatchResult.needsAttention;
      }
      return OutboxDispatchResult.offline;
    }

    final profiles = await db.query(
      'technician_profile',
      columns: [
        'email',
        'company_name',
        'technician_first_name',
        'technician_last_name'
      ],
      limit: 1,
    );
    final profile =
        profiles.isNotEmpty ? profiles.first : const <String, Object?>{};
    final profileEmail = (profile['email'] as String? ?? '').trim();
    final companyName = (profile['company_name'] as String? ?? '').trim();
    final techFirst =
        (profile['technician_first_name'] as String? ?? '').trim();
    final techLast = (profile['technician_last_name'] as String? ?? '').trim();
    final senderName =
        companyName.isNotEmpty ? companyName : '$techFirst $techLast'.trim();

    final senderEmail = EmailSenderService.resolveSenderEmail(
      settings: settings,
      profileEmail: profileEmail,
    );
    if (senderEmail == null || senderEmail.isEmpty) {
      await settingsRepo.updateSmtpState('needs_attention');
      return OutboxDispatchResult.needsAttention;
    }

    for (final job in queued) {
      final jobId = job['id'] as int;
      final claimed = await _outbox.claimJob(jobId);
      if (!claimed) continue;

      final outcome = await _sender.sendCertificateEmail(
        settings: settings,
        password: password,
        senderEmail: senderEmail,
        senderName: senderName.isNotEmpty ? senderName : 'HVAC Technicus',
        recipientEmail: job['recipient_email'] as String,
        subject: job['subject'] as String,
        bodyText: job['body_text'] as String,
        pdfPath: job['pdf_path'] as String,
      );

      if (outcome.isSuccess) {
        await _outbox.markSent(jobId, sentAt: outcome.sentAt!);
      } else {
        if (outcome.isAuthFailure) {
          await settingsRepo.updateSmtpState('needs_attention');
        }
        await _outbox.markFailed(
          jobId,
          status: outcome.status,
          failureReason: outcome.failureReason ?? 'unknown',
          lastError: outcome.lastError,
        );
      }
    }
    return OutboxDispatchResult.success;
  }

  /// Corrects a rejected recipient address in place and re-queues the job.
  ///
  /// Returns false if the job was not eligible (e.g. already sent or resolved).
  Future<bool> correctRecipientEmail(int jobId, String newEmail) async {
    return _lock.synchronized(() async {
      final updated = await _outbox.updateRecipientEmail(jobId, newEmail);
      if (!updated) return false;
      await _processOutboxLocked(forceManual: true);
      return true;
    });
  }

  /// Retries an uncertain or server-rejected job after technician confirmation.
  ///
  /// Returns false if the job was not eligible (e.g. already sent or resolved).
  Future<bool> retryJob(int jobId) async {
    return _lock.synchronized(() async {
      final requeued = await _outbox.requeueJob(jobId);
      if (!requeued) return false;
      await _processOutboxLocked(forceManual: true);
      return true;
    });
  }

  /// Marks an uncertain delivery as resolved manually with an audit record.
  ///
  /// Returns false if notes are empty or the job was not in an unresolved state.
  Future<bool> resolveJobManually(int jobId, {required String notes}) async {
    final trimmed = notes.trim();
    if (trimmed.isEmpty) return false;
    return _lock.synchronized(() async {
      return _outbox.markResolvedManually(
        jobId,
        resolvedAt: DateTime.now().toIso8601String(),
        notes: trimmed,
      );
    });
  }
}
