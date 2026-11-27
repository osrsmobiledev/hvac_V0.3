// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/reiniging_next_inspection_section.dart
// Responsibility: Dual next-inspection date pickers for Reinigingsattest Tab 6.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/bento_main_section.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_action_field.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';

class ReinigingNextInspectionSection extends StatelessWidget {
  const ReinigingNextInspectionSection({
    super.key,
    required this.nextBoilerDate,
    required this.nextChimneyDate,
    this.visitDate,
    required this.onBoilerDateChanged,
    required this.onChimneyDateChanged,
  });

  final String? nextBoilerDate;
  final String? nextChimneyDate;
  final String? visitDate;
  final ValueChanged<String> onBoilerDateChanged;
  final ValueChanged<String> onChimneyDateChanged;

  DateTime _baseDate() =>
      EindbeoordelingDraft.parseDate(visitDate) ?? DateTime.now();

  Future<void> _pickDate(
    BuildContext context,
    ValueChanged<String> onChanged,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseDate(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.amberGold,
            onPrimary: Colors.black,
            surface: AppColors.charcoalGlass,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onChanged(EindbeoordelingDraft.formatDateDmy(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: EindbeoordelingDictionary.cardTitleVolgendeControleReiniging,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DarkInputLabel(
            EindbeoordelingDictionary.lblNextReinigingStooktoestel,
            maxLines: 2,
          ),
          DarkActionField(
            key: const ValueKey('reiniging_next_boiler_date'),
            valueText: nextBoilerDate,
            hint: EindbeoordelingDictionary.datePlaceholder,
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDate(context, onBoilerDateChanged),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const DarkInputLabel(
            EindbeoordelingDictionary.lblNextReinigingRookgas,
            maxLines: 2,
          ),
          DarkActionField(
            key: const ValueKey('reiniging_next_chimney_date'),
            valueText: nextChimneyDate,
            hint: EindbeoordelingDictionary.datePlaceholder,
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDate(context, onChimneyDateChanged),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
