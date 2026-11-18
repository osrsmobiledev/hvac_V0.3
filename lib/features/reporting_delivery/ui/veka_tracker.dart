import 'package:flutter/material.dart';

import '../../../app/localization/veka_api_dictionary.dart';
import '../../../app/localization/veka_dictionary.dart';
import '../../certificate_draft/ui/widgets/bento_main_section.dart';
import '../data/veka_api_attempt.dart';
import '../data/veka_api_repository.dart';
import '../data/veka_portal.dart';
import '../data/veka_report.dart';
import '../data/veka_report_repository.dart';
import 'veka_api_actions.dart';
import 'veka_portal_actions.dart';
import 'veka_tracker_controls.dart';

class VekaTracker extends StatefulWidget {
  final int visitId;
  final VekaReportRepository? repository;
  final VekaApiRepository? apiRepository;
  final Widget? conformity;
  final bool archived;
  final Future<void> Function() openPortal;

  const VekaTracker({
    required this.visitId,
    super.key,
    this.repository,
    this.apiRepository,
    this.conformity,
    this.archived = false,
    this.openPortal = VekaPortal.open,
  });

  @override
  State<VekaTracker> createState() => _VekaTrackerState();
}

class _VekaTrackerState extends State<VekaTracker> {
  late final _repository = widget.repository ?? VekaReportRepository();
  late final _api = widget.apiRepository ?? VekaApiRepository();
  VekaRecord? _record;
  VekaApiAttempt? _apiAttempt;
  bool _busy = false;
  bool _changed = false;
  bool _statusUnreadable = false;
  String? _error;

  bool get _simulation => VekaPortal.mock || widget.apiRepository != null;

  VekaPortalActions get _portal => VekaPortalActions(
        visitId: widget.visitId,
        reports: _repository,
        openPortal: widget.openPortal,
        verifyAvailable: _verifyPortalAvailable,
      );

  VekaApiActions get _simulationActions => VekaApiActions(
        visitId: widget.visitId,
        api: _api,
        reports: _repository,
      );

  @override
  void initState() {
    super.initState();
    _run(_reload);
  }

  Future<void> _reload() async {
    final record = await _repository.read(widget.visitId);
    if (!mounted) return;
    VekaApiAttempt? attempt;
    try {
      if (_simulation) attempt = await _api.read(widget.visitId);
    } catch (_) {
      if (mounted) {
        setState(() {
          _record = record;
          _statusUnreadable = true;
          _error = VekaApiDictionary.statusError;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _record = record;
      _apiAttempt = attempt;
      _statusUnreadable = false;
      _changed = false;
    });
    final submitted = attempt?.status == VekaApiStatus.accepted
        ? attempt!.report
        : record.confirmed
            ? record.report
            : null;
    if (submitted != null) {
      try {
        final active = await _repository.preview(widget.visitId,
            requireSettledCustomer: false);
        if (mounted) {
          setState(() => _changed = submitted.differsFrom(active));
        }
      } catch (_) {
        // The saved evidence remains available when the live report fails.
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on FormatException {
      if (mounted) {
        setState(() {
          _record = null;
          _error = VekaDictionary.broken;
        });
      }
    } on VekaException catch (e) {
      if (!mounted) return;
      setState(() => _error = switch (e.issue) {
            VekaIssue.customerEditing => VekaDictionary.customer,
            VekaIssue.changed => VekaDictionary.stale,
            VekaIssue.ineligible => VekaDictionary.unsupported,
            VekaIssue.save => VekaDictionary.saveError,
          });
    } catch (_) {
      if (mounted) setState(() => _error = VekaDictionary.saveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyPortalAvailable() async {
    if (!_simulation) return;
    final attempt = await _api.read(widget.visitId);
    if (mounted) setState(() => _apiAttempt = attempt);
    if (attempt != null && !attempt.allowsManual) {
      throw const VekaException(VekaIssue.changed);
    }
  }

  Future<void> _runPortal(Future<bool> Function() action) async {
    final failed = await action();
    if (!mounted) return;
    await _reload();
    if (failed && mounted) {
      setState(() => _error = VekaDictionary.launchError);
    }
  }

  Future<void> _runSimulation(Future<void> Function() action) async {
    try {
      await action();
    } on VekaException {
      if (mounted) await _reload();
      rethrow;
    } catch (_) {
      if (!mounted) return;
      await _reload();
      if (mounted && !_statusUnreadable) {
        setState(() => _error = VekaApiDictionary.attemptError);
      }
      return;
    }
    if (mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final attempt = _apiAttempt;
    final portalAvailable =
        !_statusUnreadable && (attempt?.allowsManual ?? true);
    return BentoMainSection(
      title: VekaDictionary.title,
      isExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.conformity != null) widget.conformity!,
          if (_simulation) const Text(VekaApiDictionary.simulation),
          if (record != null && (attempt == null || record.report != null))
            Text(record.confirmed
                ? VekaDictionary.reported
                : VekaDictionary.pending),
          if (_changed) const Text(VekaDictionary.changed),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_busy) const LinearProgressIndicator(),
          if ((record == null || _statusUnreadable) && !_busy)
            TextButton(
                onPressed: () => _run(_reload),
                child: const Text(VekaApiDictionary.reload)),
          if (record != null)
            VekaTrackerControls(
              record: record,
              archived: widget.archived,
              apiAttempt: attempt,
              simulation: _simulation && !_statusUnreadable,
              portalAvailable: portalAvailable,
              current: _busy
                  ? null
                  : () =>
                      _run(() => _runPortal(() => _portal.current(context))),
              open: _busy
                  ? null
                  : () => _run(() => _runPortal(
                      () => _portal.current(context, prepare: true))),
              saved: _busy
                  ? null
                  : () => _run(() => _runPortal(() => _portal.saved(context))),
              reopen: _busy
                  ? null
                  : () => _run(() =>
                      _runPortal(() => _portal.saved(context, launch: true))),
              replace: _busy
                  ? null
                  : () => _run(() => _runPortal(() =>
                      _portal.current(context, prepare: true, replace: true))),
              confirm: _busy
                  ? null
                  : () => _run(() =>
                      _runPortal(() => _portal.saved(context, confirm: true))),
              review: _busy
                  ? null
                  : () => _run(() => _runSimulation(() => _simulationActions
                      .review(context, attempt, archived: widget.archived))),
              history: _busy
                  ? null
                  : () => _run(() => _runSimulation(
                      () => _simulationActions.history(context))),
              verify: _busy || attempt == null
                  ? null
                  : () => _run(() => _runSimulation(
                      () => _simulationActions.recover(context, attempt))),
            ),
        ],
      ),
    );
  }
}
