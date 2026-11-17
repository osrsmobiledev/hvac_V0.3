import '../../../core/utils/belgian_formatters.dart';
import 'veka_report.dart';

/// Maps saved visit records into the stable VEKA reporting model.
abstract final class VekaReportMapper {
  static VekaReport map(
    int id,
    Map<String, Object?> visit,
    Map<String, Object?> profile,
    Map<String, Object?> location,
    Map<String, Object?> boiler,
  ) {
    final isGas = boiler['fuel_type'] == 'gas';
    return VekaReport({
      'visit_id': id,
      'activity':
          _pick(visit, ['activity_type', 'visit_date', 'attest_number']),
      'technician': {
        ..._pick(profile,
            ['company_name', 'technician_first_name', 'technician_last_name']),
        'kbo_number': _clean(BelgianFormatters.stripKboPrefix(
                profile['kbo_number'] as String? ?? '')
            .replaceAll(RegExp(r'[.\s]'), '')),
        'recognition_number': _clean(
            (profile[isGas ? 'gv_number' : 'tv_number'] as String? ?? '')
                .replaceAll(RegExp(r'\s+'), '')
                .toUpperCase()),
      },
      'installation_address': _pick(location, [
        'street',
        'house_number',
        'box_number',
        'postal_code',
        'municipality',
        'adres_id',
        'gebouw_id',
        'gebouweenheid_id',
        'verification_status',
      ]),
      'boiler': {
        ..._pick(boiler, [
          'centraal_type',
          'fuel_type',
          'fuel_subtype',
          'heating_type',
          'boiler_operation',
          'burner_technology',
          'boiler_brand',
          'boiler_model',
          'boiler_serial_number',
          'boiler_construction_year',
          'boiler_nominal_power_kw',
        ]),
        'is_central': boiler['is_central'] == 1,
        for (final key in [
          'brand',
          'model',
          'serial_number',
          'construction_year'
        ])
          'boiler_${key}_unknown': _clean(boiler['boiler_$key']) == null &&
              boiler['boiler_${key}_unknown'] == 1,
      },
      'assessment': _pick(visit, [
        'stooktoestel_conform',
        'rookgasafvoerkanaal_conform',
        'stookplaats_conform',
        'verbrandingscontrole',
        'toestel_werking_goed',
        'toestel_werking_veilig',
      ]),
    });
  }

  static Map<String, Object?> _pick(
          Map<String, Object?> row, List<String> keys) =>
      {for (final key in keys) key: _clean(row[key])};

  static Object? _clean(Object? value) =>
      value is String ? (value.trim().isEmpty ? null : value.trim()) : value;
}
