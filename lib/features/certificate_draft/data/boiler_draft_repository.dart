import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../domain/boiler_draft.dart';

/// Repository managing offline SQLite persistence for the active visit's boiler.
class BoilerDraftRepository {
  final AppDatabase _appDatabase;

  BoilerDraftRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  /// Loads the boiler associated with the active draft visit.
  /// If no boiler exists yet, creates a default draft boiler and links it.
  Future<BoilerDraft> getOrCreateActiveBoiler({
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;

    // 1. Find active draft visit
    final visitRows = await db.query(
      'maintenance_visits',
      columns: ['id', 'boiler_id', 'service_location_id'],
      where: 'is_draft = 1',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (visitRows.isEmpty) {
      return BoilerDraft.initial();
    }

    final visit = visitRows.first;
    final int visitId = visit['id'] as int;
    final int? boilerId = visit['boiler_id'] as int?;
    final int? serviceLocationId = visit['service_location_id'] as int?;

    // 2. If boiler_id is already linked, fetch it
    if (boilerId != null) {
      final boilerRows = await db.query(
        'boilers',
        where: 'id = ?',
        whereArgs: [boilerId],
        limit: 1,
      );
      if (boilerRows.isNotEmpty) {
        return BoilerDraft.fromMap(boilerRows.first);
      }
    }

    // 3. Otherwise, create a new boiler draft and link to visit
    final now = DateTime.now().toIso8601String();
    final newBoilerId = await db.insert('boilers', {
      'service_location_id': serviceLocationId,
      'is_central': 1,
      'centraal_type': 'C',
      'type_b_text': '',
      'type_c_text': '',
      'heating_type': 'individueel',
      'boiler_operation': 'condenserend',
      'fuel_type': 'gas',
      'fuel_subtype': 'aardgas',
      'fuel_other_text': '',
      'burner_technology': 'premix',
      'boiler_brand': '',
      'boiler_brand_unknown': 0,
      'boiler_model': '',
      'boiler_model_unknown': 0,
      'boiler_serial_number': '',
      'boiler_serial_number_unknown': 0,
      'boiler_construction_year': null,
      'boiler_construction_year_unknown': 0,
      'boiler_nominal_power_kw': null,
      'boiler_type': '',
      'burner_brand': '',
      'burner_model': '',
      'burner_serial_number': '',
      'burner_construction_year': null,
      'burner_type': 'geintegreerd',
      'burner_flow_rate': '',
      'created_at': now,
      'updated_at': now,
    });

    await db.update(
      'maintenance_visits',
      {'boiler_id': newBoilerId, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [visitId],
    );

    return BoilerDraft(
      id: newBoilerId,
      serviceLocationId: serviceLocationId,
    );
  }

  /// Persists updated boiler draft fields to SQLite.
  Future<void> saveBoilerDraft(
    BoilerDraft boiler, {
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;
    if (boiler.id == null) return;

    final map = boiler.toMap();
    map.remove('id');

    await db.update(
      'boilers',
      map,
      where: 'id = ?',
      whereArgs: [boiler.id],
    );
  }
}
