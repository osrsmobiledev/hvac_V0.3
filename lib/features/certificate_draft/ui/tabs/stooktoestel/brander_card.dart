import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_toggle_button.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_text_form_field.dart';
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
            DarkTextFormField(
              label: AppDictionary.lblBrand,
              controller: brandController,
              hint: AppDictionary.hintBurnerBrand,
              validator: (val) {
                if (!isSeparate) return null;
                return (val?.trim().isEmpty ?? true) ? '' : null;
              },
              onChanged: onChanged,
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
            DarkTextFormField(
              label: AppDictionary.lblModel,
              controller: modelController,
              hint: AppDictionary.hintBurnerModel,
              validator: (val) {
                if (!isSeparate) return null;
                return (val?.trim().isEmpty ?? true) ? '' : null;
              },
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),

            // Bouwjaar
            HeaderWithUnknownChip(
              title: AppDictionary.lblConstructionYear,
              isUnknown: yearUnknown,
              onUnknownChanged: onYearUnknownChanged,
            ),
            DarkTextFormField(
              label: '',
              controller: yearController,
              readOnly: yearUnknown,
              hint: yearUnknown
                  ? AppDictionary.optUnknown
                  : AppDictionary.hintBurnerYear,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (val) {
                if (!isSeparate || yearUnknown) return null;
                final text = val?.trim() ?? '';
                if (text.length != 4) return '';
                final y = int.tryParse(text);
                if (y == null || y < 1900 || y > DateTime.now().year + 1) {
                  return '';
                }
                return null;
              },
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),

            // Fabricatienummer + Barcode Scanner
            HeaderWithUnknownChip(
              title: AppDictionary.lblSerialNumber,
              isUnknown: serialUnknown,
              onUnknownChanged: onSerialUnknownChanged,
            ),
            DarkTextFormField(
              label: '',
              controller: serialController,
              readOnly: serialUnknown,
              hint: serialUnknown
                  ? AppDictionary.optUnknown
                  : AppDictionary.hintBurnerSerial,
              suffixIcon: IconButton(
                focusNode:
                    FocusNode(canRequestFocus: false, skipTraversal: true),
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color:
                      serialUnknown ? AppColors.textMuted : AppColors.amberGold,
                  size: 22,
                ),
                tooltip: AppDictionary.tooltipScanBarcode,
                onPressed: serialUnknown ? null : onScanBarcode,
              ),
              validator: (val) {
                if (!isSeparate || serialUnknown) return null;
                return (val?.trim().isEmpty ?? true) ? '' : null;
              },
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),

            // Debiet
            DarkTextFormField(
              label: AppDictionary.lblFlowRate,
              controller: flowRateController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              hint: AppDictionary.hintBurnerFlowRate,
              validator: (val) {
                if (!isSeparate) return null;
                return (val?.trim().isEmpty ?? true) ? '' : null;
              },
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}
