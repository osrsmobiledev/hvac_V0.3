import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/reiniging_controls_draft.dart';

/// SQLite persistence layer for Tab 5 (Reiniging en controle) and
/// Reiniging-specific technician role flags on `maintenance_visits`.
class ReinigingRepository {
  ReinigingRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  final AppDatabase _appDatabase;

  /// Loads saved cleaning/control items for [visitId], or defaults if none exist.
  Future<ReinigingControlsDraft> loadControls(
    int visitId, {
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;
    final rows = await db.query(
      'reiniging_controls',
      where: 'visit_id = ?',
      whereArgs: [visitId],
      limit: 1,
    );
    if (rows.isEmpty) return const ReinigingControlsDraft();
    return ReinigingControlsDraft.fromMap(rows.first);
  }

  /// Upserts Tab 5 cleaning/control items for [visitId].
  ///
  /// Enforces `all_other_text = NULL` at the data boundary whenever
  /// `all_other_checked` is false.
  Future<void> saveControls({
    required int visitId,
    required ReinigingControlsDraft draft,
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;
    final now = DateTime.now().toIso8601String();
    final payload = draft.toMap()
      ..['visit_id'] = visitId
      ..['updated_at'] = now;

    final existing = await db.query(
      'reiniging_controls',
      columns: ['id'],
      where: 'visit_id = ?',
      whereArgs: [visitId],
      limit: 1,
    );

    if (existing.isEmpty) {
      payload['created_at'] = now;
      await db.insert('reiniging_controls', payload);
    } else {
      await db.update(
        'reiniging_controls',
        payload,
        where: 'visit_id = ?',
        whereArgs: [visitId],
      );
    }
  }

  /// Persists technician qualification roles on `maintenance_visits`.
  Future<void> updateTechnicianRoles({
    required int visitId,
    required bool isErkendTechnicus,
    required bool isSchoorsteenveger,
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;
    final count = await db.update(
      'maintenance_visits',
      {
        'technician_role_erkend': isErkendTechnicus ? 1 : 0,
        'technician_role_schoorsteenveger': isSchoorsteenveger ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
    if (count != 1) throw StateError('Missing visit');
  }
}
