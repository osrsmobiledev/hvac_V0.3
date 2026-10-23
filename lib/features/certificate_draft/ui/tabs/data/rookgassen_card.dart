import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import '../../widgets/bento_sub_section.dart';
import 'flue_gas_field_box.dart';

/// Separated 'Rookgassen' squircle card with smooth expand/collapse animation.
///
/// Features:
/// - Reuses [BentoSubSection] for standardized dark carbon container and header pill.
/// - Eurolyzer QR scanner launch icon button in header bar.
/// - Displays the 21 flue gas parameter boxes.
class RookgassenCard extends StatelessWidget {
  final VoidCallback? onScanQrPressed;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const RookgassenCard({
    super.key,
    this.onScanQrPressed,
    this.isExpanded,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoSubSection(
      title: 'Rookgassen',
      isExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      actionWidget: IconButton(
        icon: const Icon(
          Icons.qr_code_scanner_rounded,
          color: AppColors.amberGold,
          size: 22,
        ),
        tooltip: 'Eurolyzer QR scannen',
        onPressed: onScanQrPressed ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Eurolyzer QR Scanner wordt geactiveerd in Slice 3.2',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
      ),
      child: Column(
        children: FlueGasField.defaultFields.map((field) {
          return FlueGasFieldBox(field: field);
        }).toList(),
      ),
    );
  }
}
