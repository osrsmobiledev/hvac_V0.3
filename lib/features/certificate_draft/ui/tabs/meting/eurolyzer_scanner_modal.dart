// File: lib/features/certificate_draft/ui/tabs/meting/eurolyzer_scanner_modal.dart
// Responsibility: Sleek, high-precision BO2 tactical HUD camera scanner for Eurolyzer flue-gas QR codes.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:hvac_app/core/widgets/tactical_header_circle_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/eurolyzer_qr_parser.dart';
import '../../../domain/measurement_slot_draft.dart';
import 'eurolyzer_camera_box.dart';

/// Sleek tactical HUD modal camera scanner for Eurolyzer flue-gas QR codes.
class EurolyzerScannerModal extends StatefulWidget {
  final String slotKey;
  final String slotTitle;

  const EurolyzerScannerModal({
    super.key,
    required this.slotKey,
    required this.slotTitle,
  });

  /// Opens the Eurolyzer QR scanner dialog and returns the parsed draft.
  static Future<MeasurementSlotDraft?> scan(
    BuildContext context, {
    required String slotKey,
    required String slotTitle,
  }) async {
    return showDialog<MeasurementSlotDraft>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => EurolyzerScannerModal(
        slotKey: slotKey,
        slotTitle: slotTitle,
      ),
    );
  }

  @override
  State<EurolyzerScannerModal> createState() => _EurolyzerScannerModalState();
}

class _EurolyzerScannerModalState extends State<EurolyzerScannerModal> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasDetected = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _hasDetected = true;
        final draft = EurolyzerQrParser.parse(raw, slot: widget.slotKey);
        Navigator.of(context).pop(draft);
        break;
      }
    }
  }

  void _simulateSampleScan() {
    if (_hasDetected) return;
    _hasDetected = true;
    final payload = EurolyzerQrParser.sampleEurolyzerPayload();
    final draft = EurolyzerQrParser.parse(payload, slot: widget.slotKey);
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return TacticalDialogWindow(
      title: MetingDictionary.titleEurolyzerScanner,
      onClose: () => Navigator.of(context).pop(),
      showDivider: false,
      maxWidth: 360,
      leading: TacticalHeaderCircleButton(
        key: const Key('simulate_eurolyzer_qr_button'),
        tooltip: MetingDictionary.btnSimulateEurolyzer,
        icon: const Icon(
          Icons.science_rounded,
          color: AppColors.antiqueGold,
        ),
        onPressed: _simulateSampleScan,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: EurolyzerCameraBox(
          controller: _controller,
          isTorchOn: _isTorchOn,
          onDetect: _onDetect,
          onToggleTorch: () async {
            await _controller.toggleTorch();
            setState(() => _isTorchOn = !_isTorchOn);
          },
        ),
      ),
    );
  }
}
