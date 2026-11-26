import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import '../../../domain/reiniging_controls_draft.dart';
import 'reiniging_checklist_tile.dart';

/// Fuel-specific checklist subgroup block (Gas, Vloeibaar, or Vast) for Card 2.
///
/// Highlights the active fuel subgroup with an `amberGold` border and badge
/// without hiding or clearing items from other fuel categories.
class ReinigingFuelSubgroup extends StatelessWidget {
  final String fuelKey;
  final bool isHighlighted;
  final ReinigingControlsDraft draft;
  final bool hasSelectionError;
  final ValueChanged<ReinigingControlsDraft> onChanged;

  const ReinigingFuelSubgroup({
    super.key,
    required this.fuelKey,
    required this.isHighlighted,
    required this.draft,
    required this.hasSelectionError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final (String title, List<Widget> tiles) = switch (fuelKey) {
      'gas' => (
          ReinigingDictionary.subGas,
          [
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemGasDustRemoval,
              isSelected: draft.gasDustRemoval,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(gasDustRemoval: !draft.gasDustRemoval),
              ),
            ),
            const SizedBox(height: 8.0),
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemGasBurnerBedExchanger,
              isSelected: draft.gasBurnerBedExchanger,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(
                  gasBurnerBedExchanger: !draft.gasBurnerBedExchanger,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemGasFanBurner,
              isSelected: draft.gasFanBurner,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(gasFanBurner: !draft.gasFanBurner),
              ),
            ),
          ],
        ),
      'vloeibaar' => (
          ReinigingDictionary.subLiquid,
          [
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemLiquidFilters,
              isSelected: draft.liquidFilters,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(liquidFilters: !draft.liquidFilters),
              ),
            ),
            const SizedBox(height: 8.0),
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemLiquidBoiler,
              isSelected: draft.liquidBoiler,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(liquidBoiler: !draft.liquidBoiler),
              ),
            ),
            const SizedBox(height: 8.0),
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemLiquidBurner,
              isSelected: draft.liquidBurner,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(liquidBurner: !draft.liquidBurner),
              ),
            ),
          ],
        ),
      _ => (
          ReinigingDictionary.subSolid,
          [
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemSolidGeneralCondition,
              isSelected: draft.solidGeneralCondition,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(
                  solidGeneralCondition: !draft.solidGeneralCondition,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ReinigingChecklistTile(
              label: ReinigingDictionary.itemSolidInternalCleaning,
              isSelected: draft.solidInternalCleaning,
              isError: hasSelectionError,
              onTap: () => onChanged(
                draft.copyWith(
                  solidInternalCleaning: !draft.solidInternalCleaning,
                ),
              ),
            ),
          ],
        ),
    };

    return Container(
      padding: isHighlighted ? const EdgeInsets.all(10.0) : EdgeInsets.zero,
      decoration: isHighlighted
          ? BoxDecoration(
              color: AppColors.antiqueGold.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: AppColors.amberGoldBorder.withValues(alpha: 0.5),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReinigingSubgroupHeader(title: title, isHighlighted: isHighlighted),
          const SizedBox(height: 8.0),
          ...tiles,
        ],
      ),
    );
  }
}

/// Shared subgroup title row with optional active-fuel badge.
class ReinigingSubgroupHeader extends StatelessWidget {
  final String title;
  final bool isHighlighted;

  const ReinigingSubgroupHeader({
    super.key,
    required this.title,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color:
                  isHighlighted ? AppColors.amberGold : AppColors.textSecondary,
            ),
          ),
        ),
        if (isHighlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: AppColors.amberGoldBorder),
            ),
            child: const Text(
              ReinigingDictionary.badgeActiveFuel,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: AppColors.amberGold,
              ),
            ),
          ),
      ],
    );
  }
}
