/// Domain model for the appliance (Toestel) and burner (Brander) specifications.
///
/// Captures all Flemish statutory certificate fields (decree 8 Dec 2006) and
/// VEKA Meldingen API requirements (POST /meldingCentraleStooktoestellen).
class BoilerDraft {
  final int? id;
  final int? serviceLocationId;
  final bool isCentral;
  final String centraalType; // 'B' or 'C'
  final String typeBText;
  final String typeCText;
  final String heatingType; // 'individueel', 'collectief', 'onbekend'
  final String
      boilerOperation; // 'condenserend', 'niet_condenserend', 'onbekend'
  final String fuelCategory; // 'gas', 'vloeibaar', 'vast'
  final String
      fuelSubtype; // 'aardgas', 'LPG', 'houtpellets', 'houtblokken', 'andere'
  final String fuelOtherText;
  final String burnerTechnology; // 'niet_premix', 'premix', 'ventilatorbrander'

  // Toestel
  final String boilerBrand;
  final bool boilerBrandUnknown;
  final String boilerModel;
  final bool boilerModelUnknown;
  final int? boilerConstructionYear;
  final bool boilerConstructionYearUnknown;
  final String boilerSerialNumber;
  final bool boilerSerialNumberUnknown;
  final double? boilerNominalPowerKw;
  final String boilerType;

  // Brander
  final String burnerBrand;
  final String burnerModel;
  final String burnerSerialNumber;
  final int? burnerConstructionYear;
  final String burnerType;
  final String burnerFlowRate;

  const BoilerDraft({
    this.id,
    this.serviceLocationId,
    this.isCentral = true,
    this.centraalType = 'C',
    this.typeBText = '',
    this.typeCText = '',
    this.heatingType = 'individueel',
    this.boilerOperation = 'condenserend',
    this.fuelCategory = 'gas',
    this.fuelSubtype = 'aardgas',
    this.fuelOtherText = '',
    this.burnerTechnology = 'premix',
    this.boilerBrand = '',
    this.boilerBrandUnknown = false,
    this.boilerModel = '',
    this.boilerModelUnknown = false,
    this.boilerConstructionYear,
    this.boilerConstructionYearUnknown = false,
    this.boilerSerialNumber = '',
    this.boilerSerialNumberUnknown = false,
    this.boilerNominalPowerKw,
    this.boilerType = '',
    this.burnerBrand = '',
    this.burnerModel = '',
    this.burnerSerialNumber = '',
    this.burnerConstructionYear,
    this.burnerType = 'geintegreerd',
    this.burnerFlowRate = '',
  });

  /// Effective burner brand for official PDF rendering ('/' when integrated).
  String get effectiveBurnerBrand =>
      burnerType == 'geintegreerd' && burnerBrand.isEmpty ? '/' : burnerBrand;

  /// Effective burner model for official PDF rendering ('/' when integrated).
  String get effectiveBurnerModel =>
      burnerType == 'geintegreerd' && burnerModel.isEmpty ? '/' : burnerModel;

  /// Effective burner construction year for official PDF rendering ('/' when integrated).
  String get effectiveBurnerYear =>
      burnerType == 'geintegreerd' && burnerConstructionYear == null
          ? '/'
          : (burnerConstructionYear?.toString() ?? '');

  /// Effective burner serial number for official PDF rendering ('/' when integrated).
  String get effectiveBurnerSerialNumber =>
      burnerType == 'geintegreerd' && burnerSerialNumber.isEmpty
          ? '/'
          : burnerSerialNumber;

  /// Effective burner flow rate for official PDF rendering ('/' when integrated).
  String get effectiveBurnerFlowRate =>
      burnerType == 'geintegreerd' && burnerFlowRate.isEmpty
          ? '/'
          : burnerFlowRate;

  /// Factory for an initial default boiler draft.
  factory BoilerDraft.initial() => const BoilerDraft();

  /// Maps an SQLite row map into a [BoilerDraft] entity.
  factory BoilerDraft.fromMap(Map<String, dynamic> map) {
    return BoilerDraft(
      id: map['id'] as int?,
      serviceLocationId: map['service_location_id'] as int?,
      isCentral: (map['is_central'] as int?) != 0,
      centraalType: (map['centraal_type'] as String?) ?? 'C',
      typeBText: (map['type_b_text'] as String?) ?? '',
      typeCText: (map['type_c_text'] as String?) ?? '',
      heatingType: (map['heating_type'] as String?) ?? 'individueel',
      boilerOperation: (map['boiler_operation'] as String?) ?? 'condenserend',
      fuelCategory: (map['fuel_type'] as String?) ?? 'gas',
      fuelSubtype: (map['fuel_subtype'] as String?) ?? 'aardgas',
      fuelOtherText: (map['fuel_other_text'] as String?) ?? '',
      burnerTechnology: (map['burner_technology'] as String?) ?? 'premix',
      boilerBrand: (map['boiler_brand'] as String?) ?? '',
      boilerBrandUnknown: (map['boiler_brand_unknown'] as int?) == 1,
      boilerModel: (map['boiler_model'] as String?) ?? '',
      boilerModelUnknown: (map['boiler_model_unknown'] as int?) == 1,
      boilerConstructionYear: map['boiler_construction_year'] as int?,
      boilerConstructionYearUnknown:
          (map['boiler_construction_year_unknown'] as int?) == 1,
      boilerSerialNumber: (map['boiler_serial_number'] as String?) ?? '',
      boilerSerialNumberUnknown:
          (map['boiler_serial_number_unknown'] as int?) == 1,
      boilerNominalPowerKw:
          (map['boiler_nominal_power_kw'] as num?)?.toDouble(),
      boilerType: (map['boiler_type'] as String?) ?? '',
      burnerBrand: (map['burner_brand'] as String?) ?? '',
      burnerModel: (map['burner_model'] as String?) ?? '',
      burnerSerialNumber: (map['burner_serial_number'] as String?) ?? '',
      burnerConstructionYear: map['burner_construction_year'] as int?,
      burnerType: ((map['burner_type'] as String?)?.isNotEmpty ?? false)
          ? (map['burner_type'] as String)
          : 'geintegreerd',
      burnerFlowRate: (map['burner_flow_rate'] as String?) ?? '',
    );
  }

  /// Converts this entity into a map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'service_location_id': serviceLocationId,
      'is_central': isCentral ? 1 : 0,
      'centraal_type': centraalType,
      'type_b_text': typeBText,
      'type_c_text': typeCText,
      'heating_type': heatingType,
      'boiler_operation': boilerOperation,
      'fuel_type': fuelCategory,
      'fuel_subtype': fuelSubtype,
      'fuel_other_text': fuelOtherText,
      'burner_technology': burnerTechnology,
      'boiler_brand': boilerBrand,
      'boiler_brand_unknown': boilerBrandUnknown ? 1 : 0,
      'boiler_model': boilerModel,
      'boiler_model_unknown': boilerModelUnknown ? 1 : 0,
      'boiler_construction_year': boilerConstructionYear,
      'boiler_construction_year_unknown': boilerConstructionYearUnknown ? 1 : 0,
      'boiler_serial_number': boilerSerialNumber,
      'boiler_serial_number_unknown': boilerSerialNumberUnknown ? 1 : 0,
      'boiler_nominal_power_kw': boilerNominalPowerKw,
      'boiler_type': boilerType,
      'burner_brand': burnerBrand,
      'burner_model': burnerModel,
      'burner_serial_number': burnerSerialNumber,
      'burner_construction_year': burnerConstructionYear,
      'burner_type': burnerType,
      'burner_flow_rate': burnerFlowRate,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copies this instance with optional updated fields.
  BoilerDraft copyWith({
    int? id,
    int? serviceLocationId,
    bool? isCentral,
    String? centraalType,
    String? typeBText,
    String? typeCText,
    String? heatingType,
    String? boilerOperation,
    String? fuelCategory,
    String? fuelSubtype,
    String? fuelOtherText,
    String? burnerTechnology,
    String? boilerBrand,
    bool? boilerBrandUnknown,
    String? boilerModel,
    bool? boilerModelUnknown,
    int? boilerConstructionYear,
    bool? boilerConstructionYearUnknown,
    String? boilerSerialNumber,
    bool? boilerSerialNumberUnknown,
    double? boilerNominalPowerKw,
    String? boilerType,
    String? burnerBrand,
    String? burnerModel,
    String? burnerSerialNumber,
    int? burnerConstructionYear,
    String? burnerType,
    String? burnerFlowRate,
  }) {
    return BoilerDraft(
      id: id ?? this.id,
      serviceLocationId: serviceLocationId ?? this.serviceLocationId,
      isCentral: isCentral ?? this.isCentral,
      centraalType: centraalType ?? this.centraalType,
      typeBText: typeBText ?? this.typeBText,
      typeCText: typeCText ?? this.typeCText,
      heatingType: heatingType ?? this.heatingType,
      boilerOperation: boilerOperation ?? this.boilerOperation,
      fuelCategory: fuelCategory ?? this.fuelCategory,
      fuelSubtype: fuelSubtype ?? this.fuelSubtype,
      fuelOtherText: fuelOtherText ?? this.fuelOtherText,
      burnerTechnology: burnerTechnology ?? this.burnerTechnology,
      boilerBrand: boilerBrand ?? this.boilerBrand,
      boilerBrandUnknown: boilerBrandUnknown ?? this.boilerBrandUnknown,
      boilerModel: boilerModel ?? this.boilerModel,
      boilerModelUnknown: boilerModelUnknown ?? this.boilerModelUnknown,
      boilerConstructionYear:
          boilerConstructionYear ?? this.boilerConstructionYear,
      boilerConstructionYearUnknown:
          boilerConstructionYearUnknown ?? this.boilerConstructionYearUnknown,
      boilerSerialNumber: boilerSerialNumber ?? this.boilerSerialNumber,
      boilerSerialNumberUnknown:
          boilerSerialNumberUnknown ?? this.boilerSerialNumberUnknown,
      boilerNominalPowerKw: boilerNominalPowerKw ?? this.boilerNominalPowerKw,
      boilerType: boilerType ?? this.boilerType,
      burnerBrand: burnerBrand ?? this.burnerBrand,
      burnerModel: burnerModel ?? this.burnerModel,
      burnerSerialNumber: burnerSerialNumber ?? this.burnerSerialNumber,
      burnerConstructionYear:
          burnerConstructionYear ?? this.burnerConstructionYear,
      burnerType: burnerType ?? this.burnerType,
      burnerFlowRate: burnerFlowRate ?? this.burnerFlowRate,
    );
  }
}
