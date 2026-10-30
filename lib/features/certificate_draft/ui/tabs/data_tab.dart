import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_confirm_dialog.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../../data/measurement_draft_repository.dart';
import '../../domain/measurement_slot_draft.dart';
import 'data/meetgegevens_card.dart';
import 'meting/eurolyzer_scanner_modal.dart';

/// Tab 1 (Data) view for the Verbrandingsattest Vlaanderen workflow.
///
/// Features:
/// - Preserves scroll position and accordion state across tab switches
///   via [AutomaticKeepAliveClientMixin] and [PageStorageKey].
/// - Displays the live/incoming flue-gas telemetry from the Eurolyzer instrument.
/// - Scans Eurolyzer QR codes directly into the 'tab1_raw' buffer.
/// - Clears 'tab1_raw' telemetry with tactical confirmation dialog.
/// - Responsive and tablet-adapted (constrained to max 600px width via [WorkflowTabContainer]).
class DataTab extends StatefulWidget {
  final int visitId;
  final VoidCallback? onScanQrPressed;
  final MeasurementDraftRepository? repository;

  const DataTab({
    super.key,
    this.visitId = 1,
    this.onScanQrPressed,
    this.repository,
  });

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> with AutomaticKeepAliveClientMixin {
  late final MeasurementDraftRepository _repository;
  MeasurementSlotDraft? _measurement;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MeasurementDraftRepository();
    _loadTab1Measurement();
  }

  @override
  void didUpdateWidget(DataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitId != widget.visitId) {
      _loadTab1Measurement();
    }
  }

  Future<void> _loadTab1Measurement() async {
    try {
      final loaded = await _repository.loadTab1RawMeasurement(widget.visitId);
      if (!mounted) return;
      setState(() => _measurement = loaded);
    } catch (e, stack) {
      debugPrint('[DataTab] _loadTab1Measurement error: $e\n$stack');
    }
  }

  Future<void> _scanEurolyzer() async {
    final scanned = await EurolyzerScannerModal.scan(
      context,
      slotKey: 'tab1_raw',
      slotTitle: MetingDictionary.slotTitleDataTab,
    );
    if (scanned != null && mounted) {
      setState(() => _measurement = scanned);
      try {
        await _repository.saveMeasurementSlot(widget.visitId, scanned);

        if (!mounted) return;
        TacticalFeedback.showSuccess(
          context,
          MetingDictionary.snackEurolyzerDataLoaded,
        );
      } catch (e, stack) {
        debugPrint('[DataTab] _scanEurolyzer error: $e\n$stack');
      }
    }
  }

  Future<void> _clearTab1Measurement() async {
    final shouldClear = await TacticalConfirmDialog.show(
      context: context,
      title: MetingDictionary.dlgConfirmClearTitle,
      content: MetingDictionary.dlgConfirmClearDataTab,
      confirmLabel: AppDictionary.btnDelete,
      cancelLabel: AppDictionary.btnCancel,
      isDestructive: true,
    );

    if (shouldClear == true && mounted) {
      setState(() => _measurement = null);
      try {
        await _repository.clearMeasurementSlot(widget.visitId, 'tab1_raw');

        if (!mounted) return;
        TacticalFeedback.showInfo(
          context,
          MetingDictionary.snackSlotCleared,
          icon: Icons.delete_sweep_rounded,
        );
      } catch (e, stack) {
        debugPrint('[DataTab] _clearTab1Measurement error: $e\n$stack');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WorkflowTabContainer(
      scrollKey: 'data_tab_scroll_position',
      children: [
        MeetgegevensCard(
          measurement: _measurement,
          onScanQrPressed: widget.onScanQrPressed ?? _scanEurolyzer,
          onClearPressed: _clearTab1Measurement,
        ),
      ],
    );
  }
}
