import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import '../../../domain/reiniging_controls_draft.dart';
import '../../widgets/bento_main_section.dart';
import 'reiniging_checklist_tile.dart';

/// Card 1 for Tab 5: Reiniging en controle rookgasafvoerkanaal (3 items).
class ReinigingFlueCard extends StatelessWidget {
  final ReinigingControlsDraft draft;
  final bool hasSelectionError;
  final ValueChanged<ReinigingControlsDraft> onChanged;

  const ReinigingFlueCard({
    super.key,
    required this.draft,
    this.hasSelectionError = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BentoMainSection(
      title: ReinigingDictionary.headerFlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemFlueSweeping,
            isSelected: draft.flueSweeping,
            isError: hasSelectionError,
            onTap: () =>
                onChanged(draft.copyWith(flueSweeping: !draft.flueSweeping)),
          ),
          const SizedBox(height: 8.0),
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemFlueGoodOperation,
            isSelected: draft.flueGoodOperationCheck,
            isError: hasSelectionError,
            onTap: () => onChanged(
              draft.copyWith(
                flueGoodOperationCheck: !draft.flueGoodOperationCheck,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          ReinigingChecklistTile(
            label: ReinigingDictionary.itemFlueBackdraft,
            isSelected: draft.flueBackdraftCheck,
            isError: hasSelectionError,
            onTap: () => onChanged(
              draft.copyWith(flueBackdraftCheck: !draft.flueBackdraftCheck),
            ),
          ),
        ],
      ),
    );
  }
}
