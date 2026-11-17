import 'dart:convert';

class VekaReport {
  static const sections = [
    'activity',
    'technician',
    'installation_address',
    'boiler',
    'assessment',
  ];
  final Map<String, Object?> values;

  VekaReport(Map<String, Object?> values)
      : values = Map.unmodifiable(values.map((key, value) => MapEntry(
            key,
            value is Map<String, Object?>
                ? Map<String, Object?>.unmodifiable(value)
                : value)));

  Map<String, Object?> section(String key) =>
      values[key] as Map<String, Object?>;

  int get visitId => values['visit_id'] as int;
  String? get id => values['snapshot_id'] as String?;
  String get address {
    final row = section('installation_address');
    final bus = row['box_number'];
    return [
      [row['street'], row['house_number'], if (bus != null) 'bus $bus']
          .whereType<String>()
          .join(' '),
      [row['postal_code'], row['municipality']].whereType<String>().join(' '),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  bool differsFrom(VekaReport other) => sections
      .any((key) => jsonEncode(section(key)) != jsonEncode(other.section(key)));

  /// Keeps the reporting correction independent of the signed certificate.
  VekaReport withActivityDate(String date) => VekaReport({
        ...values,
        'activity': {...section('activity'), 'visit_date': date},
      });

  /// Local preview of VEKA field names. The stored record is the report above.
  Map<String, Object?> get previewJson {
    final activity = section('activity');
    final technician = section('technician');
    final address = section('installation_address');
    final boiler = section('boiler');
    final assessment = section('assessment');
    return {
      'externeReferte': null,
      'ondernemingsnummer': technician['kbo_number'],
      'gegevensActiviteit': {
        'activiteitType': activity['activity_type'],
        'datumActiviteit': activity['visit_date'],
        'erkenningsnummer': technician['recognition_number'],
        'verwarmingType': boiler['heating_type'],
        'adresId': address['adres_id'],
        'gebouwId': address['gebouw_id'],
        'gebouweenheidId': address['gebouweenheid_id'],
        'gebouwIdNietGekend': false,
        'gebouweenheidIdNietGekend': false,
      },
      'installatieadres': address,
      'kenmerkenToestel': {
        'brandstof': boiler['fuel_subtype'] ?? boiler['fuel_type'],
        'nominaalVermogen': boiler['boiler_nominal_power_kw'],
        'werking': boiler['boiler_operation'],
        'branderTechnologie': boiler['burner_technology'],
        'merk': boiler['boiler_brand'],
        'merkNietGekend': boiler['boiler_brand_unknown'],
        'type': boiler['boiler_model'],
        'typeNietGekend': boiler['boiler_model_unknown'],
        'fabricatienummer': boiler['boiler_serial_number'],
        'fabricatienummerNietGekend': boiler['boiler_serial_number_unknown'],
        'bouwjaar': boiler['boiler_construction_year'],
        'bouwjaarNietGekend': boiler['boiler_construction_year_unknown'],
      },
      'eindbeoordeling': {
        'stooktoestelConform': assessment['stooktoestel_conform'],
        'rookgasafvoerkanaalConform': assessment['rookgasafvoerkanaal_conform'],
        'stookplaatsConform': assessment['stookplaats_conform'],
        'verbrandingscontrole': assessment['verbrandingscontrole'],
        'toestelWerkingGoed': assessment['toestel_werking_goed'],
        'toestelWerkingVeilig': assessment['toestel_werking_veilig'],
      },
    };
  }

  bool get supported {
    final boiler = section('boiler');
    return supportsBoiler(boiler, central: boiler['is_central'] == true);
  }

  static bool supportsBoiler(Map<String, Object?> boiler,
          {required bool central}) =>
      central &&
        (boiler['fuel_type'] == 'vloeibaar' ||
            (boiler['fuel_type'] == 'gas' &&
                boiler['fuel_subtype'] == 'aardgas'));

  /// Reports which company and technician inputs need attention.
  List<String> technicianIssues(DateTime today) {
    final activity = section('activity');
    final technician = section('technician');
    final dateText = activity['visit_date'] as String?;
    final date = DateTime.tryParse(dateText ?? '');
    final todayDate = DateTime(today.year, today.month, today.day);
    final dateValid = date != null &&
        date.toIso8601String().split('T').first == dateText &&
        !date.isAfter(todayDate);
    final prefix = section('boiler')['fuel_type'] == 'gas' ? 'GV' : 'TV';
    return [
      if (!dateValid) 'visit_date',
      if (!RegExp(r'^\d{10}$')
          .hasMatch(technician['kbo_number']?.toString() ?? ''))
        'kbo_number',
      if (!RegExp('^$prefix[0-9]{5}\$')
          .hasMatch(technician['recognition_number']?.toString() ?? ''))
        prefix,
      for (final key in [
        'company_name',
        'technician_first_name',
        'technician_last_name'
      ])
        if (technician[key] == null) key,
    ];
  }

  /// Identifies the choices the technician needs to complete on Tab 7.
  List<String> finalAssessmentIssues() {
    final boiler = section('boiler');
    final assessment = section('assessment');
    return [
      if (!const ['individueel', 'collectief', 'onbekend']
          .contains(boiler['heating_type']))
        'heating_type',
      if (!const ['condenserend', 'niet_condenserend', 'onbekend']
          .contains(boiler['boiler_operation']))
        'boiler_operation',
      for (final key in [
        'stooktoestel_conform',
        'rookgasafvoerkanaal_conform',
        'stookplaats_conform',
      ])
        if (!const ['OK', 'NOK'].contains(assessment[key])) key,
      if (!const ['Goed', 'Niet goed']
          .contains(assessment['toestel_werking_goed']))
        'toestel_werking_goed',
      if (!const ['Veilig', 'Niet veilig']
          .contains(assessment['toestel_werking_veilig']))
        'toestel_werking_veilig',
    ];
  }

  /// Returns the tabs with missing or invalid reporting fields.
  List<int> missingTabs(DateTime today) {
    final activity = section('activity');
    final location = section('installation_address');
    final boiler = section('boiler');
    final assessment = section('assessment');
    final power = boiler['boiler_nominal_power_kw'];
    final isGas = boiler['fuel_type'] == 'gas';
    final validBoiler = power is num &&
        power.isFinite &&
        power > 0 &&
        (!isGas ||
            const ['premix', 'niet_premix', 'ventilatorbrander']
                .contains(boiler['burner_technology'])) &&
        ['brand', 'model', 'serial_number', 'construction_year'].every((name) =>
            boiler['boiler_$name'] != null ||
            boiler['boiler_${name}_unknown'] == true);
    return [
      if (!const ['onderhoud', 'eerste_ingebruikname']
          .contains(activity['activity_type']))
        2,
      if (technicianIssues(today).isNotEmpty) 3,
      if (['street', 'house_number', 'postal_code', 'municipality']
          .any((key) => location[key] == null))
        4,
      if (!validBoiler) 5,
      if (!const ['OK', 'NOK'].contains(assessment['verbrandingscontrole'])) 6,
      if (finalAssessmentIssues().isNotEmpty) 7,
    ];
  }
}

class VekaRecord {
  static const pending = 'not_submitted';
  static const reported = 'reported_manually_portal';
  final VekaReport? report;
  final Map<String, Object?>? confirmation;

  const VekaRecord({this.report, this.confirmation});

  bool get confirmed => confirmation != null;

  factory VekaRecord.decode(int visitId, String status, String? raw) {
    if (status == pending && (raw == null || raw.trim().isEmpty)) {
      return const VekaRecord();
    }
    try {
      final json = jsonDecode(raw!) as Map<String, Object?>;
      final snapshot = json['local_report_snapshot'] as Map<String, Object?>;
      final report = VekaReport(snapshot);
      final confirmation =
          json['manual_confirmation_record'] as Map<String, Object?>?;
      if (json['format_version'] != 1 ||
          report.visitId != visitId ||
          report.id == null ||
          report.id!.isEmpty ||
          DateTime.tryParse(snapshot['reserved_at'] as String? ?? '') == null ||
          !VekaReport.sections
              .every((key) => snapshot[key] is Map<String, Object?>) ||
          !(status == pending && confirmation == null ||
              status == reported &&
                  confirmation != null &&
                  confirmation['snapshot_id'] == report.id &&
                  confirmation['confirmed_by'] is String &&
                  DateTime.tryParse(
                          confirmation['confirmed_at'] as String? ?? '') !=
                      null)) {
        throw const FormatException();
      }
      return VekaRecord(report: report, confirmation: confirmation);
    } catch (_) {
      throw const FormatException('Invalid stored VEKA evidence');
    }
  }

  String encode() => jsonEncode({
        'format_version': 1,
        'local_report_snapshot': report!.values,
        'manual_confirmation_record': confirmation,
      });
}
