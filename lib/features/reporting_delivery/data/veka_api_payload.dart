import 'dart:convert';

import 'veka_report.dart';
import 'veka_report_repository.dart';

/// Maps a reviewed local report to the versioned mock transport contract.
/// Historical attempts retain the original JSON whenever this mapper changes.
class VekaApiPayload {
  static const contractVersion = 'veka-mock-v1';
  static final _registryId = RegExp(r'^[0-9]+$');

  final String json;

  const VekaApiPayload._(this.json);

  /// This mock covers fully resolved installations. Partial or manual addresses
  /// continue through the existing portal flow pending live contract checks.
  static List<int> missingTabs(VekaReport report, DateTime now) {
    final address = report.section('installation_address');
    final tabs = report.missingTabs(now).toSet();
    if (address['verification_status'] != 'verified' ||
        ['adres_id', 'gebouw_id', 'gebouweenheid_id'].any((key) {
          final id = address[key];
          return id is! String || !_registryId.hasMatch(id);
        })) {
      tabs.add(4);
    }
    return tabs.toList()..sort();
  }

  factory VekaApiPayload.fromReport(
      VekaReport report, String reference, DateTime now) {
    if (reference.trim().isEmpty ||
        !report.supported ||
        missingTabs(report, now).isNotEmpty) {
      throw const VekaException(VekaIssue.ineligible);
    }

    final preview = report.previewJson;
    final activity = preview['gegevensActiviteit'] as Map<String, Object?>;
    final boiler = preview['kenmerkenToestel'] as Map<String, Object?>;
    final assessment = preview['eindbeoordeling'] as Map<String, Object?>;
    final isGas = report.section('boiler')['fuel_type'] == 'gas';
    boiler.remove('branderTechnologie');

    // Use the casing and NOK spelling from the published sample for the mock.
    return VekaApiPayload._(jsonEncode({
      'externeReferte': reference,
      'ondernemingsnummer': preview['ondernemingsnummer'],
      'gegevensActiviteit': {
        ...activity,
        'activiteitType': _activity[activity['activiteitType']],
        'verwarmingType': _heating[activity['verwarmingType']],
      },
      'kenmerkenToestel': {
        ...boiler,
        'brandstof': isGas ? 'Aardgas' : 'Stookolie',
        'werking': _operation[boiler['werking']],
        if (isGas)
          'branderTechnologie':
              _burner[report.section('boiler')['burner_technology']],
      },
      'eindbeoordeling': assessment,
    }));
  }

  static const _activity = {
    'onderhoud': 'Onderhoud',
    'eerste_ingebruikname': 'Keuring voor eerste ingebruikname',
  };
  static const _heating = {
    'individueel': 'Individueel',
    'collectief': 'Collectief',
    'onbekend': 'Onbekend',
  };
  static const _operation = {
    'condenserend': 'Condenserende ketel',
    'niet_condenserend': 'Niet-condenserende ketel',
    'onbekend': 'Onbekend',
  };
  static const _burner = {
    'premix': 'Premix (GI)',
    'niet_premix': 'Niet premix (GI)',
    'ventilatorbrander': 'Gasketel met ventillatorbrander (GI)',
  };
}
