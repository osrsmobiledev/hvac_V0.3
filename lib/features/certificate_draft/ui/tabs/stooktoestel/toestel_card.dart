import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_input_box.dart';
import '../../widgets/dark_input_label.dart';
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
          const DarkInputLabel(AppDictionary.lblBrand),
          TextFormField(
            controller: brandController,
            style: DarkInputBox.inputStyle,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: DarkInputBox.decoration(
              hintText: AppDictionary.hintBoilerBrand,
            ),
            onChanged: (_) => onChanged(),
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
          const DarkInputLabel(AppDictionary.lblModel),
          TextFormField(
            controller: modelController,
            style: DarkInputBox.inputStyle,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: DarkInputBox.decoration(
              hintText: AppDictionary.hintBoilerModel,
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),

          // 3. Bouwjaar (Full-width with Onbekend chip in header)
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
                  : AppDictionary.hintBoilerYear,
              readOnly: yearUnknown,
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),

          // 4. Fabricatienummer + Barcode Scanner (Full-width with Onbekend chip in header)
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
                  : AppDictionary.hintBoilerSerial,
              readOnly: serialUnknown,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color:
                      serialUnknown ? AppColors.textMuted : AppColors.amberGold,
                  size: 22,
                ),
                tooltip: AppDictionary.tooltipScanBarcode,
                onPressed: serialUnknown ? null : onScanBarcode,
              ),
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),

          // 5. Nominaal vermogen (kW)
          const DarkInputLabel(AppDictionary.lblNominalPower),
          TextFormField(
            controller: powerController,
            style: DarkInputBox.inputStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            decoration: DarkInputBox.decoration(
              hintText: AppDictionary.hintBoilerPower,
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}
