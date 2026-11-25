import 'package:flutter/material.dart';

import 'email_delivery_actions.dart';
import 'email_job_tile.dart';
import 'email_tracker_header.dart';

/// Displays queued, failed, or sent email delivery jobs and recovery actions.
class EmailLoadedJobsView extends StatelessWidget {
  final List<Map<String, Object?>> jobs;
  final bool isProcessing;
  final bool isConfigured;
  final bool needsAttention;
  final bool isOffline;
  final Future<void> Function(int jobId, String email) onCorrectEmail;
  final Future<void> Function(int jobId) onRetryJob;
  final Future<void> Function(int jobId, String notes) onResolveManually;
  final VoidCallback onSendNow;
  final Future<void> Function(String pdfPath) onSharePdf;
  final VoidCallback onClose;

  const EmailLoadedJobsView({
    super.key,
    required this.jobs,
    required this.isProcessing,
    required this.isConfigured,
    required this.needsAttention,
    required this.isOffline,
    required this.onCorrectEmail,
    required this.onRetryJob,
    required this.onResolveManually,
    required this.onSendNow,
    required this.onSharePdf,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final hasQueuedJobs =
        jobs.any((j) => (j['status'] as String? ?? 'queued') == 'queued');
    final firstPdfPath = jobs
        .map((j) => j['pdf_path'] as String?)
        .firstWhere((p) => p != null && p.isNotEmpty, orElse: () => null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailTrackerHeader(isProcessing: isProcessing, onClose: onClose),
          const SizedBox(height: 12),
          for (int i = 0; i < jobs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            EmailJobTile(
              job: jobs[i],
              isProcessing: isProcessing,
              onCorrectEmail: (em) => onCorrectEmail(jobs[i]['id'] as int, em),
              onRetry: () => onRetryJob(jobs[i]['id'] as int),
              onResolveManually: (n) =>
                  onResolveManually(jobs[i]['id'] as int, n),
            ),
          ],
          const SizedBox(height: 16),
          EmailDeliveryActions(
            hasQueuedJobs: hasQueuedJobs,
            isProcessing: isProcessing,
            isConfigured: isConfigured,
            needsAttention: needsAttention,
            isOffline: isOffline,
            firstPdfPath: firstPdfPath,
            onSendNow: onSendNow,
            onSharePdf: () => onSharePdf(firstPdfPath ?? ''),
            onClose: onClose,
          ),
        ],
      ),
    );
  }
}
