import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../pdf_export/data/pdf_visit_data.dart';
import '../../pdf_export/data/pdf_visit_loader.dart';
import '../data/email_delivery_coordinator.dart';
import '../data/email_outbox_repository.dart';
import '../data/email_settings_repository.dart';
import '../data/pdf_archiving_coordinator.dart';
import 'email_empty_outbox_view.dart';
import 'email_load_error_view.dart';
import 'email_loaded_jobs_view.dart';
import 'email_recipient_dialog.dart';
import 'pdf_share_helper.dart';

export 'pdf_share_helper.dart' show SharePdfFunction;

/// Card displaying per-recipient email delivery state and recovery controls.
class EmailDeliveryCard extends StatefulWidget {
  final int visitId;
  final EmailOutboxRepository? outboxRepository;
  final EmailDeliveryCoordinator? coordinator;
  final EmailSettingsRepository? settingsRepository;
  final PdfArchivingCoordinator? archivingCoordinator;
  final SharePdfFunction? sharePdfOverride;
  final Future<PdfVisitData> Function(int visitId)? visitDataLoader;

  const EmailDeliveryCard({
    super.key,
    required this.visitId,
    this.outboxRepository,
    this.coordinator,
    this.settingsRepository,
    this.archivingCoordinator,
    this.sharePdfOverride,
    this.visitDataLoader,
  });

  @override
  State<EmailDeliveryCard> createState() => _EmailDeliveryCardState();
}

class _EmailDeliveryCardState extends State<EmailDeliveryCard> {
  EmailOutboxRepository get _outbox =>
      widget.outboxRepository ?? EmailOutboxRepository();
  EmailDeliveryCoordinator get _coordinator =>
      widget.coordinator ?? EmailDeliveryCoordinator.instance;
  PdfArchivingCoordinator get _archivingCoordinator =>
      widget.archivingCoordinator ?? PdfArchivingCoordinator();

  List<Map<String, Object?>>? _jobs;
  String? _archivedPdfPath, _pdfStatus;
  bool _isLoading = true, _hasLoadError = false, _isProcessing = false;
  bool _isSmtpConfigured = true,
      _smtpNeedsAttention = false,
      _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _retryLoad() async {
    setState(() {
      _isLoading = true;
      _hasLoadError = false;
    });
    await _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await _outbox.getJobsForVisit(widget.visitId);
      String? pdfPath;
      String? pdfStatus;
      if (jobs.isEmpty) {
        final info = await _outbox.getPdfInfoForVisit(widget.visitId);
        pdfStatus = info?.status;
        if (info?.path != null &&
            await _archivingCoordinator.archiveFileExists(info!.path!)) {
          pdfPath = info.path;
        } else if (pdfStatus != null) {
          pdfStatus = 'failed';
        }
      }
      final s = await (widget.settingsRepository?.loadSettings() ??
          _coordinator.loadSettings());
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _archivedPdfPath = pdfPath;
        _pdfStatus = pdfStatus;
        _isSmtpConfigured = s.isConfigured;
        _smtpNeedsAttention = s.needsAttention;
        _hasLoadError = false;
      });
    } catch (e, stack) {
      debugPrint('[EmailDeliveryCard] _loadJobs error: $e\n$stack');
      if (mounted) setState(() => _hasLoadError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _retryArchiving() async {
    await _handleAction(() async {
      final outcome =
          await _archivingCoordinator.archiveAndUpdateStatus(widget.visitId);
      if (!mounted) return;
      if (outcome.archiveSuccess) {
        TacticalFeedback.showSuccess(
            context, EmailDeliveryDictionary.archiveSuccess);
      } else {
        TacticalFeedback.showError(context,
            outcome.errorMessage ?? EmailDeliveryDictionary.archiveFailure);
      }
    });
  }

  Future<void> _sendQueuedJobs() async {
    await _handleAction(() async {
      final res = await _coordinator.processOutbox(forceManual: true);
      if (!mounted) return;
      setState(() {
        if (res == OutboxDispatchResult.offline) _isOffline = true;
        if (res == OutboxDispatchResult.success) _isOffline = false;
        if (res == OutboxDispatchResult.needsAttention) {
          _smtpNeedsAttention = true;
        }
      });
      switch (res) {
        case OutboxDispatchResult.offline:
          TacticalFeedback.showInfo(
              context, EmailDeliveryDictionary.outboxOfflineNotice);
        case OutboxDispatchResult.success:
          TacticalFeedback.showSuccess(
              context, EmailDeliveryDictionary.outboxSendSuccess);
        case OutboxDispatchResult.needsAttention:
          TacticalFeedback.showError(
              context, EmailDeliveryDictionary.outboxNeedsAttentionNotice);
        default:
          break;
      }
    });
  }

  Future<void> _promptAddEmail() async {
    final path = (_archivedPdfPath ?? '').trim();
    if (path.isEmpty) return;
    final loader = widget.visitDataLoader ?? PdfVisitLoader.loadVisitData;
    final visitData = await loader(widget.visitId);
    final smtp = await _archivingCoordinator.loadSmtpDefaults();
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
      await _archivingCoordinator.createEmailJobs(
        visitId: widget.visitId,
        pdfPath: path,
        sendToCustomer: conf.sendToCustomer,
        customerName: conf.customerName,
        customerEmail: conf.customerEmail,
        sendToTechnician: conf.sendToTechnician,
        technicianEmail: conf.technicianEmail,
        attestNumber: visitData.volgnummerAttest,
        customerNote: conf.customNote,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_hasLoadError) {
      return EmailLoadErrorView(
        onRetry: _retryLoad,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    final jobs = _jobs ?? const [];
    if (jobs.isEmpty) {
      return EmailEmptyOutboxView(
        pdfPath: _archivedPdfPath,
        pdfStatus: _pdfStatus,
        isProcessing: _isProcessing,
        onRetryArchive: _retryArchiving,
        onSharePdf: () => _handleAction(() => PdfShareHelper.sharePdf(
            context, _archivedPdfPath ?? '',
            sharePdfOverride: widget.sharePdfOverride)),
        onAddEmail: _promptAddEmail,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return EmailLoadedJobsView(
      jobs: jobs,
      isProcessing: _isProcessing,
      isConfigured: _isSmtpConfigured,
      needsAttention: _smtpNeedsAttention,
      isOffline: _isOffline,
      onCorrectEmail: (id, em) =>
          _handleAction(() => _coordinator.correctRecipientEmail(id, em)),
      onRetryJob: (id) => _handleAction(() => _coordinator.retryJob(id)),
      onResolveManually: (id, n) =>
          _handleAction(() => _coordinator.resolveJobManually(id, notes: n)),
      onSendNow: _sendQueuedJobs,
      onSharePdf: (p) => _handleAction(() => PdfShareHelper.sharePdf(context, p,
          sharePdfOverride: widget.sharePdfOverride)),
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
