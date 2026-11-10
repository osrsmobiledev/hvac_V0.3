import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/widgets/bo2_time_spinner.dart';
import 'firma_field.dart';
import 'time_validation_helper.dart';

/// Visit date and work duration pickers displayed in Tab 3 (Firma - Technicus).
class TechnicianTimingFields extends StatefulWidget {
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onTimingsChanged;

  const TechnicianTimingFields({
    super.key,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.onTimingsChanged,
  });

  @override
  State<TechnicianTimingFields> createState() => _TechnicianTimingFieldsState();
}

class _TechnicianTimingFieldsState extends State<TechnicianTimingFields> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
    );
  }
}
