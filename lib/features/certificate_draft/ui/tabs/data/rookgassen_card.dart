import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_feedback.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import 'package:hvac_app/features/certificate_draft/domain/measurement_slot_draft.dart';
import 'flue_gas_field_box.dart';

/// 'Rookgassen' telemetry section on Tab 1 (Data).
///
/// Features:
/// - Clean centered title 'Rookgassen' with an enlarged QR scanner button on the right.
/// - Directly renders the 21 flue gas parameter boxes without a nested dropdown accordion.
/// - Displays live telemetry from [measurement] or clean '–' placeholders.
/// - Reuses [TacticalSquareButton] for clear and QR scanner triggers.
class RookgassenCard extends StatelessWidget {
  final MeasurementSlotDraft? measurement;
  final VoidCallback? onScanQrPressed;
  final VoidCallback? onClearPressed;

  const RookgassenCard({
    super.key,
    this.measurement,
    this.onScanQrPressed,
    this.onClearPressed,
  });

  void _showScanPlaceholder(BuildContext context) {
    TacticalFeedback.showInfo(
      context,
      AppDictionary.placeholderQrScannerPending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = FlueGasField.fromMeasurement(measurement);
    final bool hasData = measurement != null &&
        (measurement!.o2Percent != null ||
            measurement!.co2Percent != null ||
            measurement!.coMgKwh != null ||
            measurement!.flueTempTg != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Row: Clear Button (left if data) + 'Rookgassen' (centered) + QR Code button (right)
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              if (hasData && onClearPressed != null)
                TacticalSquareButton(
                  key: const ValueKey('data_tab_clear_button'),
                  icon: Icons.delete_outline_rounded,
                  tooltip: AppDictionary.btnDelete,
                  accentColor: AppColors.terracotta,
                  borderColor: AppColors.terracottaBorder,
                  iconSize: 20,
                  onPressed: onClearPressed,
                )
              else
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
              TacticalSquareButton(
                key: const ValueKey('qr_scan_button'),
                icon: Icons.qr_code_scanner_rounded,
                tooltip: AppDictionary.tooltipScanEurolyzerQr,
                accentColor: AppColors.amberGold,
                iconSize: 24,
                onPressed:
                    onScanQrPressed ?? () => _showScanPlaceholder(context),
              ),
            ],
          ),
        ),

        // Parameter Boxes
        ...fields.map((field) {
          return FlueGasFieldBox(field: field);
        }),
      ],
    );
  }
}
