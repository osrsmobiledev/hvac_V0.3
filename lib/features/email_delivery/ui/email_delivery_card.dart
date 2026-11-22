import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../pdf_export/data/pdf_visit_loader.dart';
import '../data/email_delivery_coordinator.dart';
import '../data/email_outbox_repository.dart';
import '../data/email_settings_repository.dart';
import '../data/pdf_archiving_coordinator.dart';
import 'email_delivery_actions.dart';
import 'email_empty_outbox_view.dart';
import 'email_job_tile.dart';
import 'email_recipient_dialog.dart';
import 'email_tracker_header.dart';
import 'pdf_share_helper.dart';

export 'pdf_share_helper.dart' show SharePdfFunction;

/// Card displaying per-recipient email delivery state and recovery controls.
class EmailDeliveryCard extends StatefulWidget {
  final int visitId;
  final EmailOutboxRepository? outboxRepository;
  final EmailDeliveryCoordinator? coordinator;
  final EmailSettingsRepository? settingsRepository;
  final SharePdfFunction? sharePdfOverride;

  const EmailDeliveryCard({
    super.key,
    required this.visitId,
    this.outboxRepository,
    this.coordinator,
    this.settingsRepository,
    this.sharePdfOverride,
  });

  @override
  State<EmailDeliveryCard> createState() => _EmailDeliveryCardState();
}

class _EmailDeliveryCardState extends State<EmailDeliveryCard> {
  late final EmailOutboxRepository _outbox;
  late final EmailDeliveryCoordinator _coordinator;
  List<Map<String, Object?>>? _jobs;
  String? _archivedPdfPath;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isSmtpConfigured = true;
  bool _smtpNeedsAttention = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _outbox = widget.outboxRepository ?? EmailOutboxRepository();
    _coordinator = widget.coordinator ?? EmailDeliveryCoordinator.instance;
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobs = await _outbox.getJobsForVisit(widget.visitId);
    String? pdfPath;
    if (jobs.isEmpty) {
      pdfPath = await _outbox.getPdfPathForVisit(widget.visitId);
    }
    bool isConfigured = true;
    bool needsAttention = false;
    try {
      final settings = widget.settingsRepository != null
          ? await widget.settingsRepository!.loadSettings()
          : await _coordinator.loadSettings();
      isConfigured = settings.isConfigured;
      needsAttention = settings.needsAttention;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _jobs = jobs;
        _archivedPdfPath = pdfPath;
        _isSmtpConfigured = isConfigured;
        _smtpNeedsAttention = needsAttention;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    setState(() => _isProcessing = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await _loadJobs();
      }
    }
  }

  Future<void> _sendQueuedJobs() async {
    await _handleAction(() async {
      final res = await _coordinator.processOutbox(forceManual: true);
      if (!mounted) return;
      if (res == OutboxDispatchResult.offline) {
        setState(() => _isOffline = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(EmailDeliveryDictionary.outboxOfflineNotice),
          ),
        );
      } else if (res == OutboxDispatchResult.success) {
        setState(() => _isOffline = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(EmailDeliveryDictionary.outboxSendSuccess),
          ),
        );
      } else if (res == OutboxDispatchResult.needsAttention) {
        setState(() => _smtpNeedsAttention = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(EmailDeliveryDictionary.outboxNeedsAttentionNotice),
          ),
        );
      }
    });
  }

  Future<void> _promptAddEmail() async {
    final visitData = await PdfVisitLoader.loadVisitData(widget.visitId);
    final smtp = await PdfArchivingCoordinator().loadSmtpDefaults();
    if (!mounted) return;

    final result = await EmailRecipientDialog.show(
      context,
      snapshot: visitData,
      defaultCopyTechnician: smtp.copyTechnician,
      technicianEmail: smtp.technicianEmail,
    );
    if (!mounted || !result.isQueue || result.confirmation == null) return;

    await _handleAction(() async {
      final conf = result.confirmation!;
      final path = _archivedPdfPath ?? '';
      await PdfArchivingCoordinator().createEmailJobs(
        visitId: widget.visitId,
        pdfPath: path,
        sendToCustomer: conf.sendToCustomer,
        customerName: conf.customerName,
        customerEmail: conf.customerEmail,
        sendToTechnician: conf.sendToTechnician,
        technicianEmail: conf.technicianEmail,
        attestNumber: visitData.volgnummerAttest,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final jobs = _jobs ?? const [];
    if (jobs.isEmpty) {
      return EmailEmptyOutboxView(
        pdfPath: _archivedPdfPath,
        isProcessing: _isProcessing,
        onSharePdf: () => _handleAction(() => PdfShareHelper.sharePdf(
              context,
              _archivedPdfPath ?? '',
              sharePdfOverride: widget.sharePdfOverride,
            )),
        onAddEmail: _promptAddEmail,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    final hasQueuedJobs = jobs.any(
      (j) => (j['status'] as String? ?? 'queued') == 'queued',
    );
    final firstPdfPath = jobs
        .map((j) => j['pdf_path'] as String?)
        .firstWhere((p) => p != null && p.isNotEmpty, orElse: () => null);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailTrackerHeader(
            isProcessing: _isProcessing,
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < jobs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            EmailJobTile(
              job: jobs[i],
              isProcessing: _isProcessing,
              onCorrectEmail: (newEmail) => _handleAction(() => _coordinator
                  .correctRecipientEmail(jobs[i]['id'] as int, newEmail)),
              onRetry: () => _handleAction(
                  () => _coordinator.retryJob(jobs[i]['id'] as int)),
              onResolveManually: (notes) => _handleAction(() => _coordinator
                  .resolveJobManually(jobs[i]['id'] as int, notes: notes)),
            ),
          ],
          const SizedBox(height: 16),
          EmailDeliveryActions(
            hasQueuedJobs: hasQueuedJobs,
            isProcessing: _isProcessing,
            isConfigured: _isSmtpConfigured,
            needsAttention: _smtpNeedsAttention,
            isOffline: _isOffline,
            firstPdfPath: firstPdfPath,
            onSendNow: _sendQueuedJobs,
            onSharePdf: () => _handleAction(() => PdfShareHelper.sharePdf(
                  context,
                  firstPdfPath ?? '',
                  sharePdfOverride: widget.sharePdfOverride,
                )),
            onClose: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
