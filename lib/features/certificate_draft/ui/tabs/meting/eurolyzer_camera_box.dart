// File: lib/features/certificate_draft/ui/tabs/meting/eurolyzer_camera_box.dart
// Responsibility: BO2 tactical camera viewport with glass buttons, reticle, and guidance chip.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/scanner_torch_button.dart';
import 'package:hvac_app/core/widgets/tactical_reticle.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Tactical HUD camera viewport container for Eurolyzer QR scanning.
class EurolyzerCameraBox extends StatelessWidget {
  final MobileScannerController controller;
  final bool isTorchOn;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onToggleTorch;

  const EurolyzerCameraBox({
    super.key,
    required this.controller,
    required this.isTorchOn,
    required this.onDetect,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldHairline.withValues(alpha: 0.7),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: SizedBox(
          height: 255,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: controller,
                  onDetect: onDetect,
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

              // Optical corner-bracket reticle with micro crosshair
              const TacticalReticle(
                size: 140,
                cornerLength: 20,
                strokeWidth: 2.5,
                cornerRadius: 8,
                color: AppColors.amberGold,
              ),

              // Top-Right: Symmetrical glass torch toggle button
              Positioned(
                top: 10,
                right: 10,
                child: ScannerTorchButton(
                  isTorchOn: isTorchOn,
                  onToggle: onToggleTorch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
