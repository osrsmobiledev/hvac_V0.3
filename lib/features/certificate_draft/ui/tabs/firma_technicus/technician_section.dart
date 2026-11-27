import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/name_capitalization_formatter.dart';
import 'package:hvac_app/core/utils/technician_recognition_formatters.dart';
import '../../widgets/bento_main_section.dart';
import 'firma_field.dart';
import 'technician_role_section.dart';
import 'technician_timing_fields.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';

/// Technician, instrument serial number, and visit timing section on Tab 3 (Firma - Technicus).
class TechnicianSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController gvController;
  final TextEditingController tvController;
  final TextEditingController analyzerBrandController;
  final TextEditingController analyzerSerialController;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onProfileChanged;
  final VoidCallback onTimingsChanged;
  final String? fuelType;
  final String certificateType;
  final bool isErkendTechnicus;
  final bool isSchoorsteenveger;
  final VoidCallback? onToggleErkend;
  final VoidCallback? onToggleSchoorsteenveger;

  const TechnicianSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.gvController,
    required this.tvController,
    required this.analyzerBrandController,
    required this.analyzerSerialController,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.onProfileChanged,
    required this.onTimingsChanged,
    this.fuelType,
    this.certificateType = 'verbranding',
    this.isErkendTechnicus = true,
    this.isSchoorsteenveger = false,
    this.onToggleErkend,
    this.onToggleSchoorsteenveger,
  });

  @override
  State<TechnicianSection> createState() => _TechnicianSectionState();
}

class _TechnicianSectionState extends State<TechnicianSection> {
  final _gvFieldKey = GlobalKey<FormFieldState>();
  final _tvFieldKey = GlobalKey<FormFieldState>();

  void _onGvChanged() {
    widget.onProfileChanged();
    _tvFieldKey.currentState?.validate();
  }

  void _onTvChanged() {
    widget.onProfileChanged();
    _gvFieldKey.currentState?.validate();
  }

  @override
  void didUpdateWidget(covariant TechnicianSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isErkendTechnicus != widget.isErkendTechnicus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_gvFieldKey.currentState?.hasError == true) {
          _gvFieldKey.currentState?.validate();
        }
        if (_tvFieldKey.currentState?.hasError == true) {
          _tvFieldKey.currentState?.validate();
        }
      });
    }
  }

  bool get _requireRecognition =>
      widget.certificateType == 'verbranding' || widget.isErkendTechnicus;

  @override
  Widget build(BuildContext context) {
    final isReiniging = widget.certificateType == 'reiniging';
    final showRoles = widget.certificateType != 'verbranding';

    return BentoMainSection(
      title: AppDictionary.headerTechnicus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showRoles) ...[
            TechnicianRoleSection(
              isErkendTechnicus: widget.isErkendTechnicus,
              isSchoorsteenveger: widget.isSchoorsteenveger,
              onToggleErkend: widget.onToggleErkend ?? () {},
              onToggleSchoorsteenveger:
                  widget.onToggleSchoorsteenveger ?? () {},
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('technician_firstName'),
                  label: AppDictionary.lblFirstName,
                  controller: widget.firstNameController,
                  hint: AppDictionary.hintTechFirstName,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: const [CapitalizeWordsInputFormatter()],
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Voornaam is verplicht' : null,
                  onChanged: widget.onProfileChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  fieldKey: const ValueKey('technician_lastName'),
                  label: AppDictionary.lblLastName,
                  controller: widget.lastNameController,
                  hint: AppDictionary.hintTechLastName,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: const [CapitalizeWordsInputFormatter()],
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Achternaam is verplicht' : null,
                  onChanged: widget.onProfileChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  fieldKey: _gvFieldKey,
                  label: AppDictionary.lblGV,
                  controller: widget.gvController,
                  hint: AppDictionary.hintGvNumber,
                  prefixText: TechnicianRecognitionFormatters.gvPrefix,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (_) => TechnicianRecognitionFormatters.validateGv(
                    widget.gvController.text,
                    fuelType: widget.fuelType,
                    isTvEmpty: widget.tvController.text.trim().isEmpty,
                    requireRecognition: _requireRecognition,
                  ),
                  onChanged: _onGvChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  fieldKey: _tvFieldKey,
                  label: AppDictionary.lblTV,
                  controller: widget.tvController,
                  hint: AppDictionary.hintTvNumber,
                  prefixText: TechnicianRecognitionFormatters.tvPrefix,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (_) => TechnicianRecognitionFormatters.validateTv(
                    widget.tvController.text,
                    fuelType: widget.fuelType,
                    isGvEmpty: widget.gvController.text.trim().isEmpty,
                    requireRecognition: _requireRecognition,
                  ),
                  onChanged: _onTvChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!isReiniging) ...[
            // Flue-Gas Analyzer Instrument Details (Brand/Type + Serial stacked full-width)
            FirmaField(
              fieldKey: const ValueKey('technician_analyzerBrand'),
              label: AppDictionary.lblAnalyzerBrand,
              controller: widget.analyzerBrandController,
              hint: AppDictionary.hintAnalyzerBrand,
              onChanged: widget.onProfileChanged,
            ),
            const SizedBox(height: 12),
            FirmaField(
              fieldKey: const ValueKey('technician_analyzerSerial'),
              label: AppDictionary.lblAnalyzerSerial,
              controller: widget.analyzerSerialController,
              hint: AppDictionary.hintAnalyzerSerial,
              textCapitalization: TextCapitalization.characters,
              onChanged: widget.onProfileChanged,
            ),
            const SizedBox(height: 14),
          ],
          const Divider(color: AppColors.goldHairline, height: 1),
          const SizedBox(height: 12),

          // Visit Date and Time Pickers
          TechnicianTimingFields(
            dateController: widget.dateController,
            startTimeController: widget.startTimeController,
            endTimeController: widget.endTimeController,
            onTimingsChanged: widget.onTimingsChanged,
            dateLabel: isReiniging
                ? ReinigingDictionary.lblDateReiniging
                : AppDictionary.lblDate,
          ),
        ],
      ),
    );
  }
}
