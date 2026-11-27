/// Immutable domain model for Tab 5 (Reiniging en controle) checklist items.
///
/// Represents the 14 cleaning/control checkboxes and the conditional
/// `andere, namelijk:` text field persisted in `reiniging_controls`.
class ReinigingControlsDraft {
  static const Object _sentinel = Object();

  const ReinigingControlsDraft({
    this.flueSweeping = false,
    this.flueGoodOperationCheck = false,
    this.flueBackdraftCheck = false,
    this.allOtherChecked = false,
    this.allOtherText,
    this.allVentilationCheck = false,
    this.allFlueTightnessCheck = false,
    this.gasDustRemoval = false,
    this.gasBurnerBedExchanger = false,
    this.gasFanBurner = false,
    this.liquidFilters = false,
    this.liquidBoiler = false,
    this.liquidBurner = false,
    this.solidGeneralCondition = false,
    this.solidInternalCleaning = false,
  });

  final bool flueSweeping;
  final bool flueGoodOperationCheck;
  final bool flueBackdraftCheck;
  final bool allOtherChecked;
  final String? allOtherText;
  final bool allVentilationCheck;
  final bool allFlueTightnessCheck;
  final bool gasDustRemoval;
  final bool gasBurnerBedExchanger;
  final bool gasFanBurner;
  final bool liquidFilters;
  final bool liquidBoiler;
  final bool liquidBurner;
  final bool solidGeneralCondition;
  final bool solidInternalCleaning;

  /// True when at least one of the 14 cleaning/control items is checked.
  bool get hasAnySelected =>
      flueSweeping ||
      flueGoodOperationCheck ||
      flueBackdraftCheck ||
      allOtherChecked ||
      allVentilationCheck ||
      allFlueTightnessCheck ||
      gasDustRemoval ||
      gasBurnerBedExchanger ||
      gasFanBurner ||
      liquidFilters ||
      liquidBoiler ||
      liquidBurner ||
      solidGeneralCondition ||
      solidInternalCleaning;

  factory ReinigingControlsDraft.fromMap(Map<String, Object?> map) {
    bool flag(String key) => (map[key] as int? ?? 0) == 1;
    final otherChecked = flag('all_other_checked');
    final rawText = (map['all_other_text'] as String?)?.trim();
    return ReinigingControlsDraft(
      flueSweeping: flag('flue_sweeping'),
      flueGoodOperationCheck: flag('flue_good_operation_check'),
      flueBackdraftCheck: flag('flue_backdraft_check'),
      allOtherChecked: otherChecked,
      allOtherText: otherChecked && rawText != null && rawText.isNotEmpty
          ? rawText
          : null,
      allVentilationCheck: flag('all_ventilation_check'),
      allFlueTightnessCheck: flag('all_flue_tightness_check'),
      gasDustRemoval: flag('gas_dust_removal'),
      gasBurnerBedExchanger: flag('gas_burner_bed_exchanger'),
      gasFanBurner: flag('gas_fan_burner'),
      liquidFilters: flag('liquid_filters'),
      liquidBoiler: flag('liquid_boiler'),
      liquidBurner: flag('liquid_burner'),
      solidGeneralCondition: flag('solid_general_condition'),
      solidInternalCleaning: flag('solid_internal_cleaning'),
    );
  }

  /// Serializes to SQLite map, pruning `all_other_text` when unchecked.
  Map<String, Object?> toMap() {
    final trimmed = allOtherText?.trim();
    final effectiveOtherText =
        allOtherChecked && trimmed != null && trimmed.isNotEmpty
            ? trimmed
            : null;
    return {
      'flue_sweeping': flueSweeping ? 1 : 0,
      'flue_good_operation_check': flueGoodOperationCheck ? 1 : 0,
      'flue_backdraft_check': flueBackdraftCheck ? 1 : 0,
      'all_other_checked': allOtherChecked ? 1 : 0,
      'all_other_text': effectiveOtherText,
      'all_ventilation_check': allVentilationCheck ? 1 : 0,
      'all_flue_tightness_check': allFlueTightnessCheck ? 1 : 0,
      'gas_dust_removal': gasDustRemoval ? 1 : 0,
      'gas_burner_bed_exchanger': gasBurnerBedExchanger ? 1 : 0,
      'gas_fan_burner': gasFanBurner ? 1 : 0,
      'liquid_filters': liquidFilters ? 1 : 0,
      'liquid_boiler': liquidBoiler ? 1 : 0,
      'liquid_burner': liquidBurner ? 1 : 0,
      'solid_general_condition': solidGeneralCondition ? 1 : 0,
      'solid_internal_cleaning': solidInternalCleaning ? 1 : 0,
    };
  }

  ReinigingControlsDraft copyWith({
    bool? flueSweeping,
    bool? flueGoodOperationCheck,
    bool? flueBackdraftCheck,
    bool? allOtherChecked,
    Object? allOtherText = _sentinel,
    bool? allVentilationCheck,
    bool? allFlueTightnessCheck,
    bool? gasDustRemoval,
    bool? gasBurnerBedExchanger,
    bool? gasFanBurner,
    bool? liquidFilters,
    bool? liquidBoiler,
    bool? liquidBurner,
    bool? solidGeneralCondition,
    bool? solidInternalCleaning,
  }) {
    final nextOtherChecked = allOtherChecked ?? this.allOtherChecked;
    final nextOtherText = identical(allOtherText, _sentinel)
        ? this.allOtherText
        : allOtherText as String?;
    return ReinigingControlsDraft(
      flueSweeping: flueSweeping ?? this.flueSweeping,
      flueGoodOperationCheck:
          flueGoodOperationCheck ?? this.flueGoodOperationCheck,
      flueBackdraftCheck: flueBackdraftCheck ?? this.flueBackdraftCheck,
      allOtherChecked: nextOtherChecked,
      allOtherText: nextOtherChecked ? nextOtherText : null,
      allVentilationCheck: allVentilationCheck ?? this.allVentilationCheck,
      allFlueTightnessCheck:
          allFlueTightnessCheck ?? this.allFlueTightnessCheck,
      gasDustRemoval: gasDustRemoval ?? this.gasDustRemoval,
      gasBurnerBedExchanger:
          gasBurnerBedExchanger ?? this.gasBurnerBedExchanger,
      gasFanBurner: gasFanBurner ?? this.gasFanBurner,
      liquidFilters: liquidFilters ?? this.liquidFilters,
      liquidBoiler: liquidBoiler ?? this.liquidBoiler,
      liquidBurner: liquidBurner ?? this.liquidBurner,
      solidGeneralCondition:
          solidGeneralCondition ?? this.solidGeneralCondition,
      solidInternalCleaning:
          solidInternalCleaning ?? this.solidInternalCleaning,
    );
  }

  /// Returns a copy with all fuel-specific flags cleared except for [fuelCategory]
  /// (`'gas'`, `'vloeibaar'`, or `'vast'`).
  ReinigingControlsDraft clearingInactiveFuels(String fuelCategory) {
    final keepGas = fuelCategory == 'gas';
    final keepLiquid = fuelCategory == 'vloeibaar';
    final keepSolid = fuelCategory == 'vast';
    return copyWith(
      gasDustRemoval: keepGas ? gasDustRemoval : false,
      gasBurnerBedExchanger: keepGas ? gasBurnerBedExchanger : false,
      gasFanBurner: keepGas ? gasFanBurner : false,
      liquidFilters: keepLiquid ? liquidFilters : false,
      liquidBoiler: keepLiquid ? liquidBoiler : false,
      liquidBurner: keepLiquid ? liquidBurner : false,
      solidGeneralCondition: keepSolid ? solidGeneralCondition : false,
      solidInternalCleaning: keepSolid ? solidInternalCleaning : false,
    );
  }
}
