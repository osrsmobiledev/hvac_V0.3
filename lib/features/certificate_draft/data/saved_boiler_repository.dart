import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/veka_attempt_schema.dart';
import '../../customers_installations/domain/service_location.dart';
import '../domain/boiler_draft.dart';

enum SavedBoilerProblem { addressRequired, draftChanged, visitStarted }

class SavedBoilerException implements Exception {
  final SavedBoilerProblem problem;
  const SavedBoilerException(this.problem);
}

typedef SavedBoiler = ({int visitId, String date, BoilerDraft boiler});

class SavedBoilerOptions {
  final ServiceLocation location;
  final int? currentBoilerId;
  final List<SavedBoiler> boilers;

  const SavedBoilerOptions(this.location, this.currentBoilerId, this.boilers);
}

/// Uses archived installation addresses because live addresses can be edited.
class SavedBoilerRepository {
  final Future<Database> Function() _database;

  SavedBoilerRepository({Future<Database> Function()? database})
      : _database = database ?? (() => AppDatabase.instance.database);

  Future<SavedBoilerOptions> listForVisit(int visitId) async {
    final db = await _database();
    return db.transaction((tx) async {
      final draft = await _draft(tx, visitId);
      final location = await _location(tx, draft);
      final rows = await tx.query('maintenance_visits',
          columns: ['id', 'visit_date', 'snapshot_json'],
          where: 'is_draft = 0 AND snapshot_json IS NOT NULL',
          orderBy: 'visit_date DESC, id DESC');
      final address = location.toMap();
      final boilers = <SavedBoiler>[];
      final seen = <String>{};
      for (final row in rows) {
        final saved = _candidate(row, address);
        if (saved == null) continue;
        final boiler = saved.boiler;
        final serial = _normalize(boiler.boilerSerialNumber);
        final identity = serial.isEmpty || boiler.boilerSerialNumberUnknown
            ? 'row:${boiler.id ?? saved.visitId}'
            : jsonEncode([
                _normalize(boiler.boilerBrand),
                _normalize(boiler.boilerModel),
                serial
              ]);
        if (seen.add(identity)) boilers.add(saved);
      }
      return SavedBoilerOptions(location, draft['boiler_id'] as int?, boilers);
    });
  }

  /// Copies only appliance data and rechecks the selected address before writing.
  Future<BoilerDraft> copyToVisit(
      int visitId, SavedBoilerOptions options, int sourceVisitId) async {
    final db = await _database();
    return db.transaction((tx) async {
      final draft = await _draft(tx, visitId);
      final location = await _location(tx, draft);
      if (location.id != options.location.id ||
          !_sameAddress(location.toMap(), options.location.toMap()) ||
          draft['boiler_id'] != options.currentBoilerId) {
        throw const SavedBoilerException(SavedBoilerProblem.draftChanged);
      }
      final rows = await tx.query('maintenance_visits',
          columns: ['id', 'visit_date', 'snapshot_json'],
          where: 'id = ? AND is_draft = 0',
          whereArgs: [sourceVisitId]);
      final candidate =
          rows.isEmpty ? null : _candidate(rows.single, location.toMap());
      if (candidate == null) {
        throw const SavedBoilerException(SavedBoilerProblem.draftChanged);
      }
      await _checkVisitWork(tx, visitId, draft);
      final now = DateTime.now().toIso8601String();
      final values = candidate.boiler.toMap()
        ..remove('id')
        ..['service_location_id'] = location.id;
      final current = options.currentBoilerId;
      final otherVisits = current == null
          ? const []
          : await tx.query(
              'maintenance_visits',
              columns: ['id'],
              where: 'boiler_id = ? AND id != ?',
              whereArgs: [current, visitId],
              limit: 1,
            );
      final updated = current != null && otherVisits.isEmpty
          ? await tx
              .update('boilers', values, where: 'id = ?', whereArgs: [current])
          : 0;
      final copyId = updated == 1
          ? current!
          : await tx.insert('boilers', {...values, 'created_at': now});
      final count = await tx.update(
          'maintenance_visits', {'boiler_id': copyId, 'updated_at': now},
          where: 'id = ? AND is_draft = 1', whereArgs: [visitId]);
      if (count != 1) {
        throw const SavedBoilerException(SavedBoilerProblem.draftChanged);
      }
      return BoilerDraft.fromMap({...values, 'id': copyId});
    });
  }

  Future<Map<String, Object?>> _draft(Transaction tx, int visitId) async {
    final rows = await tx.query('maintenance_visits',
        where: 'id = ? AND is_draft = 1', whereArgs: [visitId]);
    if (rows.isEmpty) {
      throw const SavedBoilerException(SavedBoilerProblem.draftChanged);
    }
    return rows.single;
  }

  Future<ServiceLocation> _location(
      Transaction tx, Map<String, Object?> draft) async {
    if (_normalize(draft['klant_undo_json']).isNotEmpty) {
      throw const SavedBoilerException(SavedBoilerProblem.addressRequired);
    }
    final rows = await tx.query('service_locations',
        where: 'id = ? AND customer_id = ?',
        whereArgs: [draft['service_location_id'], draft['customer_id']]);
    if (rows.isEmpty || !_complete(rows.single)) {
      throw const SavedBoilerException(SavedBoilerProblem.addressRequired);
    }
    return ServiceLocation.fromMap(rows.single);
  }

  Future<void> _checkVisitWork(
      Transaction tx, int id, Map<String, Object?> draft) async {
    const fields = [
      'stooktoestel_conform',
      'rookgasafvoerkanaal_conform',
      'stookplaats_conform',
      'verbrandingscontrole',
      'toestel_werking_goed',
      'toestel_werking_veilig',
      'technician_signature_path',
      'customer_signature_path',
      'customer_signature_exception',
      'operating_pressure_bar',
      'operating_temp_celsius',
      'gas_pressure_meter_mbar',
      'gas_pressure_block_mbar',
      'gas_pressure_burner_bed_mbar',
      'nozzle_brand_type',
      'nozzle_flow_rate',
      'nozzle_angle_degrees',
      'pump_pressure_bar',
      'smoke_index_bacharach',
      'smoke_index_ok',
      'no_oil_trace_ok',
      'no_unwanted_condensation_ok',
      'rarely_polluting_smoke_ok',
      'flue_pressure_ok',
      'flue_tightness_ok',
      'fuel_supply_tightness_ok',
      'safety_valve_ok',
      'air_supply_ok',
      'flue_gas_discharge_ok',
      'ventilation_ok',
      'defects_notes',
      'general_remarks',
      'veka_manual_note',
    ];
    if (draft['veka_status'] != 'not_submitted' ||
        fields.any((key) => _normalize(draft[key]).isNotEmpty) ||
        (await tx.rawQuery('''
          SELECT id FROM measurement_captures WHERE visit_id = ? AND slot != ?
          UNION ALL SELECT id FROM $vekaApiAttemptsTable WHERE visit_id = ?
          LIMIT 1
        ''', [id, 'tab1_raw', id])).isNotEmpty) {
      throw const SavedBoilerException(SavedBoilerProblem.visitStarted);
    }
  }

  SavedBoiler? _candidate(
      Map<String, Object?> row, Map<String, Object?> location) {
    try {
      final snapshot =
          jsonDecode(row['snapshot_json'] as String) as Map<String, Object?>;
      if (snapshot['format_version'] != 1 ||
          (snapshot['visit'] as Map)['id'] != row['id'] ||
          !_sameAddress(
              snapshot['location'] as Map<String, Object?>, location)) {
        return null;
      }
      final boiler =
          BoilerDraft.fromMap(snapshot['boiler'] as Map<String, Object?>);
      if (boiler.id == null ||
          (boiler.boilerBrand.isEmpty &&
              boiler.boilerModel.isEmpty &&
              boiler.boilerSerialNumber.isEmpty)) {
        return null;
      }
      return (
        visitId: row['id'] as int,
        date: row['visit_date'] as String,
        boiler: boiler
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static const _addressFields = [
    'street',
    'house_number',
    'postal_code',
    'municipality'
  ];

  static bool _complete(Map<String, Object?> address) =>
      _addressFields.every((key) => _normalize(address[key]).isNotEmpty);

  static bool _sameAddress(Map<String, Object?> a, Map<String, Object?> b) {
    if (!_complete(a) ||
        !_complete(b) ||
        ![..._addressFields, 'box_number']
            .every((key) => _normalize(a[key]) == _normalize(b[key]))) {
      return false;
    }
    // Missing register IDs are allowed for offline addresses. Conflicting IDs are not.
    return ['adres_id', 'gebouweenheid_id'].every((key) {
      final first = _normalize(a[key]);
      final second = _normalize(b[key]);
      return first.isEmpty || second.isEmpty || first == second;
    });
  }

  static String _normalize(Object? value) => (value ?? '')
      .toString()
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');
}
