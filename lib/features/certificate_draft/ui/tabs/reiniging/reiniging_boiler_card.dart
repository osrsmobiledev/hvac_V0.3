import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import '../../../domain/reiniging_controls_draft.dart';
import '../../widgets/bento_main_section.dart';
import '../../widgets/dark_text_form_field.dart';
import 'reiniging_checklist_tile.dart';
import 'reiniging_fuel_subgroup.dart';

/// Card 2 for Tab 5: Reiniging van het stooktoestel (Subgroups A–D, 11 items).
///
/// Highlights and prioritizes the fuel subgroup matching [fuelCategory]
/// (`'gas'`, `'vloeibaar'`, or `'vast'`) while keeping all other subgroups
/// visible and preserving any already-checked items on fuel switch.
class ReinigingBoilerCard extends StatelessWidget {
  final ReinigingControlsDraft draft;
  final String fuelCategory;
  final bool hasSelectionError;
  final TextEditingController otherTextController;
  final FocusNode otherTextFocusNode;
  final ValueChanged<ReinigingControlsDraft> onChanged;
  final VoidCallback onOtherTextChanged;

  const ReinigingBoilerCard({
    super.key,
    required this.draft,
    required this.fuelCategory,
    this.hasSelectionError = false,
    required this.otherTextController,
    required this.otherTextFocusNode,
    required this.onChanged,
    required this.onOtherTextChanged,
  });

  List<String> _orderedFuelKeys() {
    const base = ['gas', 'vloeibaar', 'vast'];
    if (!base.contains(fuelCategory)) return base;
    return [fuelCategory, ...base.where((k) => k != fuelCategory)];
  }

  @override
  Widget build(BuildContext context) {
    final orderedFuels = _orderedFuelKeys();
    return BentoMainSection(
      title: ReinigingDictionary.headerBoiler,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ReinigingSubgroupHeader(
            title: ReinigingDictionary.subAll,
            isHighlighted: false,
          ),
          const SizedBox(height: 8.0),
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemAllOther,
            isSelected: draft.allOtherChecked,
            isError: hasSelectionError,
            onTap: () => onChanged(
              draft.copyWith(allOtherChecked: !draft.allOtherChecked),
            ),
          ),
          if (draft.allOtherChecked) ...[
            const SizedBox(height: 10.0),
            DarkTextFormField(
              label: ReinigingDictionary.lblOtherText,
              hint: ReinigingDictionary.hintOtherText,
              controller: otherTextController,
              focusNode: otherTextFocusNode,
              textInputAction: TextInputAction.done,
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? ReinigingDictionary.errOtherTextRequired
                  : null,
              onChanged: onOtherTextChanged,
            ),
          ],
          const SizedBox(height: 8.0),
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemAllVentilation,
            isSelected: draft.allVentilationCheck,
            isError: hasSelectionError,
            onTap: () => onChanged(
              draft.copyWith(allVentilationCheck: !draft.allVentilationCheck),
            ),
          ),
          const SizedBox(height: 8.0),
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemAllFlueTightness,
            isSelected: draft.allFlueTightnessCheck,
            isError: hasSelectionError,
            onTap: () => onChanged(
              draft.copyWith(
                allFlueTightnessCheck: !draft.allFlueTightnessCheck,
              ),
            ),
          ),
          for (final fuelKey in orderedFuels) ...[
            const SizedBox(height: 14.0),
            ReinigingFuelSubgroup(
              fuelKey: fuelKey,
              isHighlighted: fuelCategory == fuelKey,
              draft: draft,
              hasSelectionError: hasSelectionError,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}
