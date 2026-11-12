import 'dart:typed_data';
import 'pdf_visit_data.dart';
import 'pdf_visit_loader.dart';

/// Pure mapper transforming raw SQLite maps and binary assets into strongly-typed [PdfVisitData].
abstract final class PdfDataMapper {
  /// Loads all visit details from database using [PdfVisitLoader].
  static Future<PdfVisitData> loadVisitData(int visitId) =>
      PdfVisitLoader.loadVisitData(visitId);

  /// Maps raw database rows into a validated [PdfVisitData] instance.
  static PdfVisitData mapToPdfData({
    required Map<String, Object?> visit,
    required Map<String, Object?> profile,
    required Map<String, Object?> customer,
    required Map<String, Object?> location,
    required Map<String, Object?> boiler,
    required Map<String, Object?> slotInitial,
    required Map<String, Object?> slotLow,
    required Map<String, Object?> slotHigh,
    Uint8List? techSigBytes,
    Uint8List? custSigBytes,
  }) {
    String str(Map<String, Object?> map, String key) =>
        (map[key] as String? ?? '').trim();

    String numStr(Map<String, Object?> map, String key) {
      final v = map[key];
      if (v == null) return '';
      if (v is double) {
        return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
      }
      return v.toString().trim();
    }

    String resolveCo(Map<String, Object?> slot) {
      final val = numStr(slot, 'co_mg_kwh');
      return val.isNotEmpty ? val : numStr(slot, 'co_ppm');
    }

    String resolveNetTemp(Map<String, Object?> slot) {
      final net = numStr(slot, 'net_temp_celsius');
      if (net.isNotEmpty) return net;
      final tg = (slot['flue_temp_celsius'] as num?)?.toDouble();
      final ta = (slot['ambient_temp_celsius'] as num?)?.toDouble();
      if (tg != null && ta != null) {
        final diff = tg - ta;
        return diff.toStringAsFixed(diff.truncateToDouble() == diff ? 0 : 1);
      }
      return '';
    }

    final fuel = str(boiler, 'fuel_type').toLowerCase();
    final fuelCat = fuel.contains('gas')
        ? 'gas'
        : fuel.contains('olie')
            ? 'vloeibaar'
            : fuel.contains('vast') || fuel.contains('pellet')
                ? 'vast'
                : '';

    // Co evaluation: prefer initial, fallback to final low / high
    final coOkVal = slotInitial['co_ok'] as int? ??
        slotLow['co_ok'] as int? ??
        slotHigh['co_ok'] as int?;

    // Efficiency Hi evaluation: prefer initial, fallback to final low / high
    final hiOkVal = (slotInitial['combustion_efficiency_hi_ok'] as int? ??
            slotInitial['combustion_efficiency_ok'] as int?) ??
        (slotLow['combustion_efficiency_hi_ok'] as int? ??
            slotLow['combustion_efficiency_ok'] as int?) ??
        (slotHigh['combustion_efficiency_hi_ok'] as int? ??
            slotHigh['combustion_efficiency_ok'] as int?);

    // Flue pressure in Pa: check slot captures first, then visit table
    final fluePa = numStr(slotLow, 'flue_pressure_pa').isNotEmpty
        ? numStr(slotLow, 'flue_pressure_pa')
        : numStr(slotHigh, 'flue_pressure_pa').isNotEmpty
            ? numStr(slotHigh, 'flue_pressure_pa')
            : numStr(slotInitial, 'flue_pressure_pa').isNotEmpty
                ? numStr(slotInitial, 'flue_pressure_pa')
                : numStr(visit, 'flue_pressure_pa');

    // Customer signature name fallback
    final custNameFromCustomer =
        '${str(customer, 'first_name')} ${str(customer, 'last_name')}'.trim();
    final custNameFallback = custNameFromCustomer.isNotEmpty
        ? custNameFromCustomer
        : str(customer, 'company_name');
    final custSigName = str(visit, 'customer_signature_name').isNotEmpty
        ? str(visit, 'customer_signature_name')
        : custNameFallback;

    final isSepBurner = str(boiler, 'burner_type') == 'afzonderlijk';

    return PdfVisitData(
      activiteitType: str(visit, 'activity_type'),
      volgnummerAttest: str(visit, 'attest_number'),
      firmaNaam: str(profile, 'company_name'),
      firmaStraat: str(profile, 'street'),
      firmaNr: str(profile, 'house_number'),
      firmaBus: str(profile, 'box_number'),
      firmaPostcode: str(profile, 'postal_code'),
      firmaGemeente: str(profile, 'city'),
      firmaTel: str(profile, 'phone'),
      firmaEmail: str(profile, 'email'),
      firmaKbo: str(profile, 'kbo_number'),
      technicusVoornaam: str(profile, 'technician_first_name'),
      technicusAchternaam: str(profile, 'technician_last_name'),
      technicusGv: str(profile, 'gv_number'),
      technicusTv: str(profile, 'tv_number'),
      datumOnderhoud: _formatDate(str(visit, 'visit_date')),
      arbeidsduurVan: str(visit, 'start_time'),
      arbeidsduurTot: str(visit, 'end_time'),
      klantNaam: custNameFromCustomer.isNotEmpty
          ? custNameFromCustomer
          : str(customer, 'company_name'),
      klantVoornaam: str(customer, 'first_name'),
      klantAchternaam: str(customer, 'last_name'),
      klantBedrijf: str(customer, 'company_name'),
      klantStraat: str(customer, 'street'),
      klantNr: str(customer, 'house_number'),
      klantBus: str(customer, 'box_number'),
      klantPostcode: str(customer, 'postal_code'),
      klantGemeente: str(customer, 'city'),
      klantTel: str(customer, 'phone'),
      klantEmail: str(customer, 'email'),
      locatieStraat: str(location, 'street'),
      locatieNr: str(location, 'house_number'),
      locatieBus: str(location, 'box_number'),
      locatiePostcode: str(location, 'postal_code'),
      locatieGemeente: str(location, 'municipality'),
      isCentraal: (boiler['is_central'] as int? ?? 0) == 1,
      centraalType: str(boiler, 'centraal_type'),
      typeBText: str(boiler, 'type_b_text'),
      typeCText: str(boiler, 'type_c_text'),
      brandstofCat: fuelCat,
      gasType: str(boiler, 'fuel_subtype'),
      gasAndereText: str(boiler, 'fuel_other_text'),
      branderTech: str(boiler, 'burner_technology'),
      vastType: str(boiler, 'fuel_subtype'),
      vastAndereText: str(boiler, 'fuel_other_text'),
      toestelMerk: str(boiler, 'boiler_brand'),
      toestelType: str(boiler, 'boiler_model'),
      toestelBouwjaar: numStr(boiler, 'boiler_construction_year'),
      toestelFabNummer: str(boiler, 'boiler_serial_number'),
      toestelVermogen: numStr(boiler, 'boiler_nominal_power_kw'),
      branderMerk: isSepBurner ? str(boiler, 'burner_brand') : '',
      branderType: isSepBurner ? str(boiler, 'burner_model') : '',
      branderBouwjaar:
          isSepBurner ? numStr(boiler, 'burner_construction_year') : '',
      branderFabNummer:
          isSepBurner ? str(boiler, 'burner_serial_number') : '',
      branderDebiet: isSepBurner ? str(boiler, 'burner_flow_rate') : '',
      meetToestelNaam: str(profile, 'analyzer_brand_model'),
      meetToestelSerienummer: str(profile, 'analyzer_serial_number'),
      ketelTemp: numStr(visit, 'operating_temp_celsius'),
      sproeierMerkType: str(visit, 'nozzle_brand_type'),
      sproeierDebiet: str(visit, 'nozzle_flow_rate'),
      sproeierHoek: numStr(visit, 'nozzle_angle_degrees'),
      pompdrukBar: numStr(visit, 'pump_pressure_bar'),
      gasdrukTellerMbar: numStr(visit, 'gas_pressure_meter_mbar'),
      gasdrukGasblokMbar: numStr(visit, 'gas_pressure_block_mbar'),
      gasdrukBranderbedMbar: numStr(visit, 'gas_pressure_burner_bed_mbar'),
      rookindexBacharach: numStr(visit, 'smoke_index_bacharach'),
      rookindexBeoordelingOk: _okStr(visit['smoke_index_ok'] as int?),
      proef1O2: numStr(slotInitial, 'o2_percent'),
      proef1Co2: numStr(slotInitial, 'co2_percent'),
      proef1Co: resolveCo(slotInitial),
      proef1CoOk: _okStr(coOkVal),
      proef1Tg: numStr(slotInitial, 'flue_temp_celsius'),
      proef1Ta: numStr(slotInitial, 'ambient_temp_celsius'),
      proef1NettoTemp: resolveNetTemp(slotInitial),
      proef1RendementHi: numStr(slotInitial, 'combustion_efficiency_hi'),
      proef1RendementHiOk: _okStr(hiOkVal),
      proef1RendementHs: numStr(slotInitial, 'combustion_efficiency_hs'),
      isLaaglastActive: slotLow.isNotEmpty && _hasSlotData(slotLow),
      isHooglastActive: slotHigh.isNotEmpty && _hasSlotData(slotHigh),
      proef2LaagO2: numStr(slotLow, 'o2_percent'),
      proef2LaagCo2: numStr(slotLow, 'co2_percent'),
      proef2LaagCo: resolveCo(slotLow),
      proef2LaagTg: numStr(slotLow, 'flue_temp_celsius'),
      proef2LaagTa: numStr(slotLow, 'ambient_temp_celsius'),
      proef2LaagNettoTemp: resolveNetTemp(slotLow),
      proef2LaagRendementHi: numStr(slotLow, 'combustion_efficiency_hi'),
      proef2LaagRendementHs: numStr(slotLow, 'combustion_efficiency_hs'),
      proef2HoogO2: numStr(slotHigh, 'o2_percent'),
      proef2HoogCo2: numStr(slotHigh, 'co2_percent'),
      proef2HoogCo: resolveCo(slotHigh),
      proef2HoogTg: numStr(slotHigh, 'flue_temp_celsius'),
      proef2HoogTa: numStr(slotHigh, 'ambient_temp_celsius'),
      proef2HoogNettoTemp: resolveNetTemp(slotHigh),
      proef2HoogRendementHi: numStr(slotHigh, 'combustion_efficiency_hi'),
      proef2HoogRendementHs: numStr(slotHigh, 'combustion_efficiency_hs'),
      geenOliespoorOk: _okStr(visit['no_oil_trace_ok'] as int?),
      geenCondensatieOk: _okStr(visit['no_unwanted_condensation_ok'] as int?),
      zeldenHinderlijkeRookOk:
          _okStr(visit['rarely_polluting_smoke_ok'] as int?),
      schouwtrekPa: fluePa,
      drukRookgasOk: _okStr(visit['flue_pressure_ok'] as int?),
      verluchtingStooklokaalOk: _okStr(visit['ventilation_ok'] as int?),
      dichtheidRookgasafvoerOk: _okStr((visit['flue_tightness_ok'] as int?) ??
          (visit['flue_gas_discharge_ok'] as int?)),
      dichtheidBrandstoftoevoerOk:
          _okStr(visit['fuel_supply_tightness_ok'] as int?),
      toestelWerkingGoed: str(visit, 'toestel_werking_goed'),
      toestelWerkingVeilig: str(visit, 'toestel_werking_veilig'),
      volgendeControleDatum: str(visit, 'next_inspection_date'),
      gebrekenOpmerkingen: str(visit, 'defects_notes'),
      andereOpmerkingen: str(visit, 'general_remarks'),
      technicusHandtekeningBytes: techSigBytes,
      klantHandtekeningBytes: custSigBytes,
      klantHandtekeningNaam: custSigName,
      klantHandtekeningUitzondering: str(visit, 'customer_signature_exception'),
    );
  }

  static bool _hasSlotData(Map<String, Object?> slot) {
    for (final key in [
      'o2_percent',
      'co2_percent',
      'co_mg_kwh',
      'co_ppm',
      'flue_temp_celsius',
      'combustion_efficiency_hi'
    ]) {
      if (slot[key] != null) return true;
    }
    return false;
  }

  static String _okStr(int? value) =>
      value == 1 ? 'OK' : (value == 0 ? 'Niet OK' : '');

  static String _formatDate(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    if (RegExp(r'^\d{2}[/-]\d{2}[/-]\d{4}').hasMatch(t)) {
      return t.replaceAll('-', '/');
    }
    try {
      final dt = DateTime.parse(t);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return t;
    }
  }
}
