import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_text_form_field.dart';
import 'brand_quick_picker.dart';
import 'unknown_badge.dart';

/// Bento Card 2: Toestel (Appliance / Boiler).
///
/// Features:
/// - Brand with tactical quick-selection ribbon for top brands in Flanders.
/// - Model, construction year, serial number, and nominal power inputs.
/// - Full-width input boxes with generous breathing room for the technician.
/// - Integrated tactical 'Onbekend' header chips for year and serial number.
/// - Camera barcode scanner action button for `fabricatienummer`.
class ToestelCard extends StatelessWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController serialController;
  final TextEditingController powerController;
  final bool serialUnknown;
  final bool yearUnknown;
  final ValueChanged<bool> onSerialUnknownChanged;
  final ValueChanged<bool> onYearUnknownChanged;
  final VoidCallback onScanBarcode;
  final VoidCallback onChanged;

  const ToestelCard({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.serialController,
    required this.powerController,
    required this.serialUnknown,
    required this.yearUnknown,
    required this.onSerialUnknownChanged,
    required this.onYearUnknownChanged,
    required this.onScanBarcode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerAppliance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Merk
          DarkTextFormField(
            label: AppDictionary.lblBrand,
            controller: brandController,
            hint: AppDictionary.hintBoilerBrand,
            validator: (val) => (val?.trim().isEmpty ?? true) ? '' : null,
            onChanged: onChanged,
          ),
          const SizedBox(height: 6),
          ListenableBuilder(
            listenable: brandController,
            builder: (context, _) {
              return BrandQuickPicker(
                selectedBrand: brandController.text,
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

          // 2. Type / Model
          DarkTextFormField(
            label: AppDictionary.lblModel,
            controller: modelController,
            hint: AppDictionary.hintBoilerModel,
            validator: (val) => (val?.trim().isEmpty ?? true) ? '' : null,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 3. Bouwjaar (Full-width with Onbekend chip in header)
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
                : AppDictionary.hintBoilerYear,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (val) {
              if (yearUnknown) return null;
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

          // 4. Fabricatienummer + Barcode Scanner
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
                : AppDictionary.hintBoilerSerial,
            suffixIcon: IconButton(
              focusNode: FocusNode(canRequestFocus: false, skipTraversal: true),
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
              if (serialUnknown) return null;
              return (val?.trim().isEmpty ?? true) ? '' : null;
            },
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),

          // 5. Nominaal vermogen (kW)
          DarkTextFormField(
            label: AppDictionary.lblNominalPower,
            controller: powerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            hint: AppDictionary.hintBoilerPower,
            validator: (val) {
              final text = val?.trim().replaceAll(',', '.') ?? '';
              if (text.isEmpty) return '';
              final p = double.tryParse(text);
              if (p == null || p <= 0) return '';
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
