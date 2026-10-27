import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import 'flue_gas_field_box.dart';

/// 'Rookgassen' telemetry section on Tab 1 (Data).
///
/// Features:
/// - Clean centered title 'Rookgassen' with an enlarged QR scanner button on the right.
/// - Directly renders the 21 flue gas parameter boxes without a nested dropdown accordion.
class RookgassenCard extends StatelessWidget {
  final VoidCallback? onScanQrPressed;

  const RookgassenCard({
    super.key,
    this.onScanQrPressed,
  });

  void _showScanPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppDictionary.placeholderQrScannerPending),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Row: 'Rookgassen' (centered) + Enlarged QR Code button in the right corner
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              // Balanced left spacer equal to QR button width (40px) so title is perfectly centered
              const SizedBox(width: 40),
              const Expanded(
                child: Text(
                  AppDictionary.headerRookgassen,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('qr_scan_button'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.amberGold.withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.amberGold,
                    size: 24,
                  ),
                ),
                tooltip: AppDictionary.tooltipScanEurolyzerQr,
                onPressed:
                    onScanQrPressed ?? () => _showScanPlaceholder(context),
              ),
            ],
          ),
        ),

        // Parameter Boxes
        ...FlueGasField.defaultFields.map((field) {
          return FlueGasFieldBox(field: field);
        }),
      ],
    );
  }
}
