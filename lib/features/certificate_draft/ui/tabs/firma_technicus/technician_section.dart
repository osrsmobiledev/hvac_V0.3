import 'package:flutter/material.dart';
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
      } catch (_) {}
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
      title: 'Technicus',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  label: 'Voornaam:',
                  controller: firstNameController,
                  hint: 'Jan',
                  onChanged: onProfileChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  label: 'Achternaam:',
                  controller: lastNameController,
                  hint: 'Janssens',
                  onChanged: onProfileChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FirmaField(
                  label: 'GV-nummer:',
                  controller: gvController,
                  hint: 'GV01234',
                  onChanged: onProfileChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FirmaField(
                  label: 'TV-nummer:',
                  controller: tvController,
                  hint: 'TV01234',
                  onChanged: onProfileChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.goldHairline, height: 1),
          const SizedBox(height: 14),

          // Date Picker: Datum onderhoud
          FirmaActionField(
            label: 'Datum onderhoud:',
            controller: dateController,
            hint: 'JJJJ-MM-DD',
            icon: Icons.calendar_month_rounded,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 14),

          // Time Pickers: Arbeidsduur van & tot
          Row(
            children: [
              Expanded(
                child: FirmaActionField(
                  label: 'Arbeidsduur van:',
                  controller: startTimeController,
                  hint: '08:00',
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
                  label: 'tot:',
                  controller: endTimeController,
                  hint: '10:00',
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
