import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_toggle_button.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/dark_input_label.dart';
import 'brand_quick_picker.dart';
import 'integrated_burner_badge.dart';
import 'unknown_badge.dart';

/// Bento Card 3: Brander (enkel CV).
///
/// Features:
/// - Smart TacticalToggleButton: Afzonderlijke brander (OFF = geïntegreerd in ketel, ON = apart toestel).
/// - Default OFF (integrated) for modern condensing/premix gas boilers (95%+ visits).
/// - Tactical badge with VEKA & statutory compliance notice when integrated.
/// - Full burner nameplate form with quick-chips for oil & blast burner brands when separate.
class BranderCard extends StatelessWidget {
  final String burnerType;
  final ValueChanged<String> onBurnerTypeChanged;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController serialController;
  final TextEditingController flowRateController;
  final bool yearUnknown;
  final bool serialUnknown;
  final ValueChanged<bool> onYearUnknownChanged;
  final ValueChanged<bool> onSerialUnknownChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onChanged;

  const BranderCard({
    super.key,
    required this.burnerType,
    required this.onBurnerTypeChanged,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.serialController,
    required this.flowRateController,
    required this.yearUnknown,
    required this.serialUnknown,
    required this.onYearUnknownChanged,
    required this.onSerialUnknownChanged,
    required this.onScanBarcode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSeparate = burnerType == 'afzonderlijk';

    return BentoMainSection(
      title: '${AppDictionary.headerBurner} ${AppDictionary.subBurner}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tactical Toggle: Afzonderlijke brander (OFF = geïntegreerd, ON = apart)
          TacticalToggleButton(
            label: AppDictionary.lblSeparateBurner,
            subtitle: AppDictionary.subSeparateBurner,
            value: isSeparate,
            onChanged: (val) {
              onBurnerTypeChanged(val ? 'afzonderlijk' : 'geintegreerd');
            },
          ),
          const SizedBox(height: 12),

          // 2. Dynamic Content: Tactical Badge or Full Burner Form
          if (!isSeparate)
            const IntegratedBurnerBadge()
          else ...[
            // Merk + Burner Brand Quick-Chips
            const DarkInputLabel(AppDictionary.lblBrand),
            TextFormField(
              controller: brandController,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: DarkInputBox.decoration(
                hintText: AppDictionary.hintBurnerBrand,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 6),
            ListenableBuilder(
              listenable: brandController,
              builder: (context, _) {
                return BrandQuickPicker(
                  selectedBrand: brandController.text,
                  brands: BrandQuickPicker.defaultBurnerBrands,
                  onBrandSelected: (brand) {
                    brandController.text = brand;
                    brandController.selection = TextSelection.fromPosition(
                      TextPosition(offset: brand.length),
                    );
                    onChanged();
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Type / Model
            const DarkInputLabel(AppDictionary.lblModel),
            TextFormField(
              controller: modelController,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: DarkInputBox.decoration(
                hintText: AppDictionary.hintBurnerModel,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),

            // Bouwjaar
            HeaderWithUnknownChip(
              title: AppDictionary.lblConstructionYear,
              isUnknown: yearUnknown,
              onUnknownChanged: onYearUnknownChanged,
            ),
            TextFormField(
              controller: yearController,
              enabled: !yearUnknown,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: DarkInputBox.decoration(
                hintText: yearUnknown
                    ? AppDictionary.optUnknown
                    : AppDictionary.hintBurnerYear,
                readOnly: yearUnknown,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),

            // Fabricatienummer + Barcode Scanner
            HeaderWithUnknownChip(
              title: AppDictionary.lblSerialNumber,
              isUnknown: serialUnknown,
              onUnknownChanged: onSerialUnknownChanged,
            ),
            TextFormField(
              controller: serialController,
              enabled: !serialUnknown,
              style: DarkInputBox.inputStyle,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: DarkInputBox.decoration(
                hintText: serialUnknown
                    ? AppDictionary.optUnknown
                    : AppDictionary.hintBurnerSerial,
                readOnly: serialUnknown,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: serialUnknown
                        ? AppColors.textMuted
                        : AppColors.amberGold,
                    size: 22,
                  ),
                  tooltip: AppDictionary.tooltipScanBarcode,
                  onPressed: serialUnknown ? null : onScanBarcode,
                ),
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),

            // Debiet
            const DarkInputLabel(AppDictionary.lblFlowRate),
            TextFormField(
              controller: flowRateController,
              style: DarkInputBox.inputStyle,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: DarkInputBox.decoration(
                hintText: AppDictionary.hintBurnerFlowRate,
              ),
              onChanged: (_) => onChanged(),
            ),
          ],
        ],
      ),
    );
  }
}
