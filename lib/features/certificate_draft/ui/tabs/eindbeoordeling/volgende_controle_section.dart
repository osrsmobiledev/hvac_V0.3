// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/volgende_controle_section.dart
// Responsibility: Tactical statutory next combustion inspection interval selector and date picker section.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_check_button.dart';
import 'package:hvac_app/features/certificate_draft/domain/eindbeoordeling_draft.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_action_field.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';

class VolgendeControleSection extends StatelessWidget {
  const VolgendeControleSection({
    super.key,
    required this.selectedDate,
    required this.fuelType,
    this.visitDate,
    required this.onDateChanged,
  });

  final String? selectedDate;
  final String fuelType;
  final String? visitDate;
  final ValueChanged<String> onDateChanged;

  DateTime _baseDate() =>
      EindbeoordelingDraft.parseDate(visitDate) ?? DateTime.now();

  String _dateForOffset({int years = 0, int months = 0}) {
    final base = _baseDate();
    return EindbeoordelingDraft.formatDateDmy(
      DateTime(base.year + years, base.month + months, base.day),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
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
      onDateChanged(EindbeoordelingDraft.formatDateDmy(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final datePlus3M = _dateForOffset(months: 3);
    final datePlus1Y = _dateForOffset(years: 1);
    final datePlus2Y = _dateForOffset(years: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Label
        const DarkInputLabel(
          EindbeoordelingDictionary.cardTitleVolgendeControle,
        ),

        // 2. Centered action field with calendar icon
        DarkActionField(
          valueText: selectedDate,
          hint: EindbeoordelingDictionary.datePlaceholder,
          icon: Icons.calendar_month_rounded,
          onTap: () => _pickDate(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // 3. Tactical Interval Selector (+3 Maanden | +1 Jaar | +2 Jaar)
        SizedBox(
          height: 42.0,
          child: Row(
            children: [
              // +3 Maanden (statutory remediation deadline)
              Expanded(
                child: TacticalCheckButton(
                  label: EindbeoordelingDictionary.chipPlus3Months,
                  isActive: selectedDate == datePlus3M,
                  activeBackgroundColor: Color.alphaBlend(
                    AppColors.terracotta.withValues(alpha: 0.14),
                    const Color(0xFF141414),
                  ),
                  activeBorderColor: AppColors.terracottaBorder,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateChanged(selectedDate == datePlus3M ? '' : datePlus3M);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // +1 Jaar (liquid/solid statutory interval)
              Expanded(
                child: TacticalCheckButton(
                  label: EindbeoordelingDictionary.chipPlus1Year,
                  isActive: selectedDate == datePlus1Y,
                  activeBackgroundColor: Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.12),
                    const Color(0xFF141414),
                  ),
                  activeBorderColor: AppColors.amberGoldBorder,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateChanged(selectedDate == datePlus1Y ? '' : datePlus1Y);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // +2 Jaar (gas statutory interval)
              Expanded(
                child: TacticalCheckButton(
                  label: EindbeoordelingDictionary.chipPlus2Years,
                  isActive: selectedDate == datePlus2Y,
                  activeBackgroundColor: Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.12),
                    const Color(0xFF141414),
                  ),
                  activeBorderColor: AppColors.amberGoldBorder,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateChanged(selectedDate == datePlus2Y ? '' : datePlus2Y);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
