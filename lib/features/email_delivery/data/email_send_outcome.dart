/// Strongly typed outcome of an attempt to send an email job via SMTP.
class EmailSendOutcome {
  /// Resulting job status: 'sent', 'recipient_rejected', 'server_rejected', 'uncertain_timeout', 'failed'.
  final String status;

  /// Structured category of the failure.
  final String? failureReason;

  /// Diagnostic error description (excluding credentials/passwords).
  final String? lastError;

  /// ISO-8601 timestamp when the email was successfully accepted by the server.
  final String? sentAt;

  /// True if authentication failed, signaling `smtp_state` should be set to `needs_attention`.
  final bool isAuthFailure;

  const EmailSendOutcome({
    required this.status,
    this.failureReason,
    this.lastError,
    this.sentAt,
    this.isAuthFailure = false,
  });

  bool get isSuccess => status == 'sent';
}

/// Structured result of an outbox processing run.
enum OutboxDispatchResult {
  /// No jobs in the queue.
  noQueuedJobs,

  /// Successfully connected and processed jobs.
  success,

  /// SMTP settings are not configured.
  unconfigured,

  /// Offline: SMTP connection check timed out or failed to reach host.
  offline,

  /// SMTP credentials rejected or require technician attention.
  needsAttention,
}
