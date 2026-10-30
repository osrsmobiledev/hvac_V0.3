/// Domain model representing a single combustion test slot in Tab 6 (Meting).
///
/// Corresponds to one of the 3 statutory measurement slots:
/// - Proef 1: Initiële meting (Vóór onderhoud)
/// - Proef 2: Eindmeting (Na onderhoud - Laaglast)
/// - Proef 2: Eindmeting (Na onderhoud - Hooglast)
class MeasurementSlotDraft {
  final String slot; // 'proef1', 'proef2_laaglast', 'proef2_hooglast'
  final double? o2Percent;
  final double? co2Percent;
  final double? coMgKwh;
  final bool? coOk;
  final double? flueTempTg;
  final double? ambientTempTa;
  final double? netTemp;
  final double? efficiencyHi;
  final bool? efficiencyHiOk;
  final double? efficiencyHs;
  final double? fluePressurePa;
  final int? bacharach;
  final bool? bacharachOk;
  final String? rawQrPayload;

  const MeasurementSlotDraft({
    required this.slot,
    this.o2Percent,
    this.co2Percent,
    this.coMgKwh,
    this.coOk,
    this.flueTempTg,
    this.ambientTempTa,
    this.netTemp,
    this.efficiencyHi,
    this.efficiencyHiOk,
    this.efficiencyHs,
    this.fluePressurePa,
    this.bacharach,
    this.bacharachOk,
    this.rawQrPayload,
  });

  /// Factory for an empty slot.
  factory MeasurementSlotDraft.empty(String slot) =>
      MeasurementSlotDraft(slot: slot);

  /// Automatically derives the net temperature (tg - ta) when both are known.
  double? get effectiveNetTemp {
    if (flueTempTg != null && ambientTempTa != null) {
      final diff = flueTempTg! - ambientTempTa!;
      return double.parse(diff.toStringAsFixed(1));
    }
    return netTemp;
  }

  /// Suggests compliance for Carbon Monoxide (statutory VLAREM limit <= 150 mg/kWh).
  bool? get suggestedCoOk => coMgKwh != null ? coMgKwh! <= 150.0 : null;

  /// Suggests compliance for Efficiency Hi (statutory VLAREM standard >= 90%).
  bool? get suggestedHiOk =>
      efficiencyHi != null ? efficiencyHi! >= 90.0 : null;

  /// Effective CO evaluation (manual technician choice overrides auto-suggestion).
  bool? get effectiveCoOk => coOk ?? suggestedCoOk;

  /// Effective Hi evaluation (manual technician choice overrides auto-suggestion).
  bool? get effectiveHiOk => efficiencyHiOk ?? suggestedHiOk;

  /// Maps an SQLite row from `measurement_captures` into a [MeasurementSlotDraft].
  factory MeasurementSlotDraft.fromMap(Map<String, dynamic> map) {
    return MeasurementSlotDraft(
      slot: (map['slot'] as String?) ?? 'proef1',
      o2Percent: (map['o2_percent'] as num?)?.toDouble(),
      co2Percent: (map['co2_percent'] as num?)?.toDouble(),
      coMgKwh: (map['co_mg_kwh'] as num?)?.toDouble() ??
          (map['co_ppm'] as num?)?.toDouble(),
      coOk: map['co_ok'] != null ? (map['co_ok'] as int) == 1 : null,
      flueTempTg: (map['flue_temp_celsius'] as num?)?.toDouble(),
      ambientTempTa: (map['ambient_temp_celsius'] as num?)?.toDouble(),
      netTemp: (map['net_temp_celsius'] as num?)?.toDouble(),
      efficiencyHi: (map['combustion_efficiency_hi'] as num?)?.toDouble(),
      efficiencyHiOk: map['combustion_efficiency_hi_ok'] != null
          ? (map['combustion_efficiency_hi_ok'] as int) == 1
          : null,
      efficiencyHs: (map['combustion_efficiency_hs'] as num?)?.toDouble(),
      fluePressurePa: (map['flue_pressure_pa'] as num?)?.toDouble(),
      rawQrPayload: map['raw_qr_payload'] as String?,
    );
  }

  /// Serializes into an SQLite row map for `measurement_captures`.
  Map<String, dynamic> toMap(int visitId) {
    return {
      'visit_id': visitId,
      'slot': slot,
      'raw_qr_payload': rawQrPayload,
      'o2_percent': o2Percent,
      'co2_percent': co2Percent,
      'co_mg_kwh': coMgKwh,
      'co_ok': coOk == null ? null : (coOk! ? 1 : 0),
      'flue_temp_celsius': flueTempTg,
      'ambient_temp_celsius': ambientTempTa,
      'net_temp_celsius': effectiveNetTemp,
      'combustion_efficiency_hi': efficiencyHi,
      'combustion_efficiency_hi_ok':
          efficiencyHiOk == null ? null : (efficiencyHiOk! ? 1 : 0),
      'combustion_efficiency_hs': efficiencyHs,
      'flue_pressure_pa': fluePressurePa,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copies this instance with updated fields.
  MeasurementSlotDraft copyWith({
    String? slot,
    double? o2Percent,
    double? co2Percent,
    double? coMgKwh,
    bool? coOk,
    double? flueTempTg,
    double? ambientTempTa,
    double? netTemp,
    double? efficiencyHi,
    bool? efficiencyHiOk,
    double? efficiencyHs,
    double? fluePressurePa,
    int? bacharach,
    bool? bacharachOk,
    String? rawQrPayload,
  }) {
    return MeasurementSlotDraft(
      slot: slot ?? this.slot,
      o2Percent: o2Percent ?? this.o2Percent,
      co2Percent: co2Percent ?? this.co2Percent,
      coMgKwh: coMgKwh ?? this.coMgKwh,
      coOk: coOk ?? this.coOk,
      flueTempTg: flueTempTg ?? this.flueTempTg,
      ambientTempTa: ambientTempTa ?? this.ambientTempTa,
      netTemp: netTemp ?? this.netTemp,
      efficiencyHi: efficiencyHi ?? this.efficiencyHi,
      efficiencyHiOk: efficiencyHiOk ?? this.efficiencyHiOk,
      efficiencyHs: efficiencyHs ?? this.efficiencyHs,
      fluePressurePa: fluePressurePa ?? this.fluePressurePa,
      bacharach: bacharach ?? this.bacharach,
      bacharachOk: bacharachOk ?? this.bacharachOk,
      rawQrPayload: rawQrPayload ?? this.rawQrPayload,
    );
  }
}
