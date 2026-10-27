import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/bo2_time_spinner.dart';
import '../../widgets/bento_main_section.dart';
import 'firma_field.dart';

/// Technician and visit timing section on Tab 3 (Firma - Technicus).
class TechnicianSection extends StatelessWidget {
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

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    DateTime initial = DateTime.now();
    if (dateController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(dateController.text);
      } catch (e) {
        debugPrint(
            '[TechnicianSection] parse date "${dateController.text}" failed: $e');
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.amberGold,
              onPrimary: Colors.black,
              surface: AppColors.charcoalGlass,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      dateController.text = '$y-$m-$d';
      onTimingsChanged();
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
                  label: AppDictionary.lblFirstName,
                  controller: firstNameController,
                  hint: AppDictionary.hintTechFirstName,
                  onChanged: onProfileChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  label: AppDictionary.lblLastName,
                  controller: lastNameController,
                  hint: AppDictionary.hintTechLastName,
                  onChanged: onProfileChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  label: AppDictionary.lblGV,
                  controller: gvController,
                  hint: AppDictionary.hintGvNumber,
                  onChanged: onProfileChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  label: AppDictionary.lblTV,
                  controller: tvController,
                  hint: AppDictionary.hintTvNumber,
                  onChanged: onProfileChanged,
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
            controller: dateController,
            hint: AppDictionary.hintDateFormat,
            icon: Icons.calendar_month_rounded,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 12),

          // Time Pickers: Arbeidsduur van & tot
          Row(
            children: [
              Expanded(
                child: FirmaActionField(
                  label: AppDictionary.lblTimeFrom,
                  controller: startTimeController,
                  hint: AppDictionary.hintTimeStart,
                  icon: Icons.access_time_rounded,
                  onTap: () => showBo2TimeSpinner(
                    context,
                    startTimeController,
                    onTimeSelected: onTimingsChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaActionField(
                  label: AppDictionary.lblTimeTo,
                  controller: endTimeController,
                  hint: AppDictionary.hintTimeEnd,
                  icon: Icons.access_time_rounded,
                  onTap: () => showBo2TimeSpinner(
                    context,
                    endTimeController,
                    onTimeSelected: onTimingsChanged,
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
