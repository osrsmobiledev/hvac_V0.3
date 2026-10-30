import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/eurolyzer_qr_parser.dart';
import '../../../domain/measurement_slot_draft.dart';

/// Tactical HUD modal camera scanner for Eurolyzer flue-gas QR codes.
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
      title: '${MetingDictionary.titleEurolyzerScanner}\n(${widget.slotTitle})',
      maxWidth: 380,
      actions: TacticalDialogActions.single(
        label: AppDictionary.btnCancel,
        onPressed: () => Navigator.of(context).pop(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            MetingDictionary.lblCameraUnavailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Tactical amber reticle viewfinder overlay
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.85),
                    width: 2.0,
                  ),
                ),
              ),

              // Torch toggle button in top right
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      _isTorchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _isTorchOn
                          ? AppColors.amberGold
                          : AppColors.textSecondary,
                    ),
                    onPressed: () async {
                      await _controller.toggleTorch();
                      setState(() {
                        _isTorchOn = !_isTorchOn;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Simulation fallback action
          OutlinedButton.icon(
            key: const ValueKey('simulate_eurolyzer_qr_button'),
            onPressed: _simulateSampleScan,
            icon: const Icon(Icons.bolt_rounded,
                color: AppColors.antiqueGold, size: 18),
            label: const Text(
              MetingDictionary.btnSimulateEurolyzer,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.antiqueGold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: BorderSide(
                color: AppColors.amberGoldBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFF191919),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
