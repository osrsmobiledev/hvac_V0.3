import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/name_capitalization_formatter.dart';
import 'package:hvac_app/core/widgets/bo2_time_spinner.dart';
import '../../widgets/bento_main_section.dart';
import 'firma_field.dart';
import 'time_validation_helper.dart';

/// Technician and visit timing section on Tab 3 (Firma - Technicus).
class TechnicianSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController gvController;
  final TextEditingController tvController;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onProfileChanged;
  final VoidCallback onTimingsChanged;

  const TechnicianSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.gvController,
    required this.tvController,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.onProfileChanged,
    required this.onTimingsChanged,
  });

  @override
  State<TechnicianSection> createState() => _TechnicianSectionState();
}

class _TechnicianSectionState extends State<TechnicianSection> {
  final _gvFieldKey = GlobalKey<FormFieldState>();
  final _tvFieldKey = GlobalKey<FormFieldState>();
  final _startTimeKey = GlobalKey<FormFieldState>();
  final _endTimeKey = GlobalKey<FormFieldState>();

  bool get _isStartTimeSelected =>
      widget.startTimeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.startTimeController.addListener(_onStartTimeTick);
  }

  @override
  void dispose() {
    widget.startTimeController.removeListener(_onStartTimeTick);
    super.dispose();
  }

  void _onStartTimeTick() {
    if (mounted) setState(() {});
  }

  void _onGvChanged() {
    widget.onProfileChanged();
    _tvFieldKey.currentState?.validate();
  }

  void _onTvChanged() {
    widget.onProfileChanged();
    _gvFieldKey.currentState?.validate();
  }

  void _onStartTimeSelected() {
    widget.onTimingsChanged();
    setState(() {});
    _startTimeKey.currentState?.validate();
    if (widget.endTimeController.text.isNotEmpty) {
      _endTimeKey.currentState?.validate();
    }
  }

  void _onEndTimeSelected() {
    widget.onTimingsChanged();
    _endTimeKey.currentState?.validate();
    if (widget.startTimeController.text.isNotEmpty) {
      _startTimeKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: AppDictionary.headerTechnicus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  textCapitalization: TextCapitalization.characters,
                  validator: (_) => (widget.gvController.text.trim().isEmpty &&
                          widget.tvController.text.trim().isEmpty)
                      ? 'GV-nummer vereist'
                      : null,
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
                  textCapitalization: TextCapitalization.characters,
                  validator: (_) => (widget.gvController.text.trim().isEmpty &&
                          widget.tvController.text.trim().isEmpty)
                      ? 'TV-nummer vereist'
                      : null,
                  onChanged: _onTvChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.goldHairline, height: 1),
          const SizedBox(height: 12),

          // Date Picker: Datum onderhoud
          FirmaActionField(
            label: AppDictionary.lblDate,
            controller: widget.dateController,
            hint: AppDictionary.hintDateFormat,
            icon: Icons.calendar_month_rounded,
            onTap: () => TimeValidationHelper.pickDate(
              context,
              widget.dateController,
              widget.onTimingsChanged,
            ),
          ),
          const SizedBox(height: 12),

          // Time Pickers: Arbeidsduur van & tot
          Row(
            children: [
              Expanded(
                child: FirmaActionField(
                  fieldKey: _startTimeKey,
                  label: AppDictionary.lblTimeFrom,
                  controller: widget.startTimeController,
                  hint: AppDictionary.hintTimeStart,
                  icon: Icons.access_time_rounded,
                  showErrorText: false,
                  validator: (_) => TimeValidationHelper.validateStartTime(
                    widget.startTimeController.text,
                  ),
                  onTap: () => showBo2TimeSpinner(
                    context,
                    widget.startTimeController,
                    onTimeSelected: _onStartTimeSelected,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaActionField(
                  fieldKey: _endTimeKey,
                  label: AppDictionary.lblTimeTo,
                  controller: widget.endTimeController,
                  hint: AppDictionary.hintTimeEnd,
                  icon: Icons.access_time_rounded,
                  enabled: _isStartTimeSelected,
                  showErrorText: false,
                  validator: (_) => _isStartTimeSelected
                      ? TimeValidationHelper.validateEndTime(
                          widget.endTimeController.text,
                          widget.startTimeController.text,
                        )
                      : null,
                  onTap: () => showBo2TimeSpinner(
                    context,
                    widget.endTimeController,
                    fallbackTime: TimeValidationHelper.suggestedEndTime(
                      widget.startTimeController.text,
                    ),
                    onTimeSelected: _onEndTimeSelected,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
