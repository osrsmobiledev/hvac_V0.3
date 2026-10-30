/// Domain model representing operating conditions and safety assessments in Tab 6 (Meting).
///
/// Corresponds to Card 1 (Goede staat van werking) and Card 3 (Veilige staat van werking)
/// and synchronizes with the SQLite `maintenance_visits` table.
class OperatingConditionsDraft {
  final double? boilerTempCelsius;

  // Gas operating conditions
  final double? gasPressureMeterMbar;
  final double? gasPressureBlockMbar;
  final double? gasPressureBurnerBedMbar;

  // Oil / Liquid operating conditions
  final String? nozzleBrandType;
  final String? nozzleFlowRate;
  final double? nozzleAngleDegrees;
  final double? pumpPressureBar;
  final int? smokeIndexBacharach;
  final bool? smokeIndexOk;

  // Safety & Environmental Checks (Card 3)
  final bool? noOilTraceOk; // Liquid only
  final bool? noUnwantedCondensationOk; // Type B only
  final bool? rarelyPollutingSmokeOk; // Solid only
  final bool? fluePressureOk; // All installations
  final bool? ventilationOk; // All installations
  final bool? flueTightnessOk; // Type C only
  final bool? fuelSupplyTightnessOk; // Gas only

  // Official VEKA API Eindbeoordeling compliance fields
  final String? verbrandingscontrole; // 'OK' | 'NOK'
  final String? stooktoestelConform; // 'OK' | 'NOK'
  final String? rookgasafvoerkanaalConform; // 'OK' | 'NOK'
  final String? stookplaatsConform; // 'OK' | 'NOK'
  final String? toestelWerkingGoed; // 'Goed' | 'Niet goed'
  final String? toestelWerkingVeilig; // 'Veilig' | 'Niet veilig'

  const OperatingConditionsDraft({
    this.boilerTempCelsius,
    this.gasPressureMeterMbar,
    this.gasPressureBlockMbar,
    this.gasPressureBurnerBedMbar,
    this.nozzleBrandType,
    this.nozzleFlowRate,
    this.nozzleAngleDegrees,
    this.pumpPressureBar,
    this.smokeIndexBacharach,
    this.smokeIndexOk,
    this.noOilTraceOk,
    this.noUnwantedCondensationOk,
    this.rarelyPollutingSmokeOk,
    this.fluePressureOk,
    this.ventilationOk,
    this.flueTightnessOk,
    this.fuelSupplyTightnessOk,
    this.verbrandingscontrole,
    this.stooktoestelConform,
    this.rookgasafvoerkanaalConform,
    this.stookplaatsConform,
    this.toestelWerkingGoed,
    this.toestelWerkingVeilig,
  });

  /// Factory for an empty operating conditions draft.
  factory OperatingConditionsDraft.empty() => const OperatingConditionsDraft();

  /// Maps an SQLite row from `maintenance_visits` into [OperatingConditionsDraft].
  factory OperatingConditionsDraft.fromMap(Map<String, dynamic> map) {
    bool? toBool(dynamic val) => val == null ? null : (val as int) == 1;

    return OperatingConditionsDraft(
      boilerTempCelsius: (map['operating_temp_celsius'] as num?)?.toDouble(),
      gasPressureMeterMbar:
          (map['gas_pressure_meter_mbar'] as num?)?.toDouble(),
      gasPressureBlockMbar:
          (map['gas_pressure_block_mbar'] as num?)?.toDouble(),
      gasPressureBurnerBedMbar:
          (map['gas_pressure_burner_bed_mbar'] as num?)?.toDouble(),
      nozzleBrandType: map['nozzle_brand_type'] as String?,
      nozzleFlowRate: map['nozzle_flow_rate'] as String?,
      nozzleAngleDegrees: (map['nozzle_angle_degrees'] as num?)?.toDouble(),
      pumpPressureBar: (map['pump_pressure_bar'] as num?)?.toDouble(),
      smokeIndexBacharach: map['smoke_index_bacharach'] as int?,
      smokeIndexOk: toBool(map['smoke_index_ok']),
      noOilTraceOk: toBool(map['no_oil_trace_ok']),
      noUnwantedCondensationOk: toBool(map['no_unwanted_condensation_ok']),
      rarelyPollutingSmokeOk: toBool(map['rarely_polluting_smoke_ok']),
      fluePressureOk: toBool(map['flue_pressure_ok']),
      ventilationOk: toBool(map['ventilation_ok']),
      flueTightnessOk: toBool(map['flue_tightness_ok']),
      fuelSupplyTightnessOk: toBool(map['fuel_supply_tightness_ok']),
      verbrandingscontrole: map['verbrandingscontrole'] as String?,
      stooktoestelConform: map['stooktoestel_conform'] as String?,
      rookgasafvoerkanaalConform: map['rookgasafvoerkanaal_conform'] as String?,
      stookplaatsConform: map['stookplaats_conform'] as String?,
      toestelWerkingGoed: map['toestel_werking_goed'] as String?,
      toestelWerkingVeilig: map['toestel_werking_veilig'] as String?,
    );
  }

  /// Serializes into an SQLite update map for `maintenance_visits`.
  Map<String, dynamic> toMap() {
    int? fromBool(bool? b) => b == null ? null : (b ? 1 : 0);

    return {
      'operating_temp_celsius': boilerTempCelsius,
      'gas_pressure_meter_mbar': gasPressureMeterMbar,
      'gas_pressure_block_mbar': gasPressureBlockMbar,
      'gas_pressure_burner_bed_mbar': gasPressureBurnerBedMbar,
      'nozzle_brand_type': nozzleBrandType,
      'nozzle_flow_rate': nozzleFlowRate,
      'nozzle_angle_degrees': nozzleAngleDegrees,
      'pump_pressure_bar': pumpPressureBar,
      'smoke_index_bacharach': smokeIndexBacharach,
      'smoke_index_ok': fromBool(smokeIndexOk),
      'no_oil_trace_ok': fromBool(noOilTraceOk),
      'no_unwanted_condensation_ok': fromBool(noUnwantedCondensationOk),
      'rarely_polluting_smoke_ok': fromBool(rarelyPollutingSmokeOk),
      'flue_pressure_ok': fromBool(fluePressureOk),
      'ventilation_ok': fromBool(ventilationOk),
      'flue_tightness_ok': fromBool(flueTightnessOk),
      'fuel_supply_tightness_ok': fromBool(fuelSupplyTightnessOk),
      'verbrandingscontrole': verbrandingscontrole,
      'stooktoestel_conform': stooktoestelConform,
      'rookgasafvoerkanaal_conform': rookgasafvoerkanaalConform,
      'stookplaats_conform': stookplaatsConform,
      'toestel_werking_goed': toestelWerkingGoed,
      'toestel_werking_veilig': toestelWerkingVeilig,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copies this instance with optional updated fields.
  OperatingConditionsDraft copyWith({
    double? boilerTempCelsius,
    double? gasPressureMeterMbar,
    double? gasPressureBlockMbar,
    double? gasPressureBurnerBedMbar,
    String? nozzleBrandType,
    String? nozzleFlowRate,
    double? nozzleAngleDegrees,
    double? pumpPressureBar,
    int? smokeIndexBacharach,
    bool? smokeIndexOk,
    bool? noOilTraceOk,
    bool? noUnwantedCondensationOk,
    bool? rarelyPollutingSmokeOk,
    bool? fluePressureOk,
    bool? ventilationOk,
    bool? flueTightnessOk,
    bool? fuelSupplyTightnessOk,
    String? verbrandingscontrole,
    String? stooktoestelConform,
    String? rookgasafvoerkanaalConform,
    String? stookplaatsConform,
    String? toestelWerkingGoed,
    String? toestelWerkingVeilig,
  }) {
    return OperatingConditionsDraft(
      boilerTempCelsius: boilerTempCelsius ?? this.boilerTempCelsius,
      gasPressureMeterMbar: gasPressureMeterMbar ?? this.gasPressureMeterMbar,
      gasPressureBlockMbar: gasPressureBlockMbar ?? this.gasPressureBlockMbar,
      gasPressureBurnerBedMbar:
          gasPressureBurnerBedMbar ?? this.gasPressureBurnerBedMbar,
      nozzleBrandType: nozzleBrandType ?? this.nozzleBrandType,
      nozzleFlowRate: nozzleFlowRate ?? this.nozzleFlowRate,
      nozzleAngleDegrees: nozzleAngleDegrees ?? this.nozzleAngleDegrees,
      pumpPressureBar: pumpPressureBar ?? this.pumpPressureBar,
      smokeIndexBacharach: smokeIndexBacharach ?? this.smokeIndexBacharach,
      smokeIndexOk: smokeIndexOk ?? this.smokeIndexOk,
      noOilTraceOk: noOilTraceOk ?? this.noOilTraceOk,
      noUnwantedCondensationOk:
          noUnwantedCondensationOk ?? this.noUnwantedCondensationOk,
      rarelyPollutingSmokeOk:
          rarelyPollutingSmokeOk ?? this.rarelyPollutingSmokeOk,
      fluePressureOk: fluePressureOk ?? this.fluePressureOk,
      ventilationOk: ventilationOk ?? this.ventilationOk,
      flueTightnessOk: flueTightnessOk ?? this.flueTightnessOk,
      fuelSupplyTightnessOk:
          fuelSupplyTightnessOk ?? this.fuelSupplyTightnessOk,
      verbrandingscontrole: verbrandingscontrole ?? this.verbrandingscontrole,
      stooktoestelConform: stooktoestelConform ?? this.stooktoestelConform,
      rookgasafvoerkanaalConform:
          rookgasafvoerkanaalConform ?? this.rookgasafvoerkanaalConform,
      stookplaatsConform: stookplaatsConform ?? this.stookplaatsConform,
      toestelWerkingGoed: toestelWerkingGoed ?? this.toestelWerkingGoed,
      toestelWerkingVeilig: toestelWerkingVeilig ?? this.toestelWerkingVeilig,
    );
  }
}
