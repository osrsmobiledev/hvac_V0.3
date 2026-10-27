import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_window.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Tactical HUD modal camera scanner for boiler and burner serial barcodes.
class BarcodeScannerModal extends StatefulWidget {
  final String title;

  const BarcodeScannerModal({super.key, required this.title});

  /// Opens the barcode scanner modal dialog and returns the scanned code string.
  static Future<String?> scan(
    BuildContext context, {
    required String title,
  }) async {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => BarcodeScannerModal(title: title),
    );
  }

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal> {
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
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        _hasDetected = true;
        Navigator.of(context).pop(rawValue.trim());
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TacticalDialogWindow(
      title: widget.title,
      maxWidth: 380,
      actions: TacticalDialogActions.single(
        label: AppDictionary.dlgClose,
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
                            'Camera niet beschikbaar.\nVoer het nummer handmatig in.',
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
                height: 140,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.8),
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
          const Text(
            'Plaats de barcode of QR-code van het toestel in het kader.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
