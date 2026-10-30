import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../domain/boiler_draft.dart';
import '../domain/measurement_slot_draft.dart';
import '../domain/operating_conditions_draft.dart';

/// SQLite repository for Tab 6 (Meting) draft persistence.
///
/// Manages operating conditions in `maintenance_visits` and multi-slot
/// combustion captures in `measurement_captures`.
class MeasurementDraftRepository {
  final AppDatabase _dbProvider;

  MeasurementDraftRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db async => await _dbProvider.database;

  /// Loads the active boiler draft to read installation fuel and NBN type.
  Future<BoilerDraft> loadActiveBoilerDraft() async {
    try {
      final db = await _db;
      if (!db.isOpen) return BoilerDraft.initial();

      // Query boiler associated with the active draft visit first
      final rows = await db.rawQuery('''
        SELECT b.* FROM boilers b
        INNER JOIN maintenance_visits v ON v.boiler_id = b.id
        WHERE v.is_draft = 1
        ORDER BY v.id DESC
        LIMIT 1
      ''');
      if (rows.isNotEmpty) {
        return BoilerDraft.fromMap(rows.first);
      }

      // Fallback: latest boiler if visit has not yet linked a boiler
      final fallbackRows =
          await db.query('boilers', orderBy: 'id DESC', limit: 1);
      if (fallbackRows.isNotEmpty) {
        return BoilerDraft.fromMap(fallbackRows.first);
      }
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] loadActiveBoilerDraft error: $e\n$stack');
    }
    return BoilerDraft.initial();
  }

  /// Loads the operating conditions and safety assessments for a visit.
  Future<OperatingConditionsDraft> loadOperatingConditions(int visitId) async {
    try {
      final db = await _db;
      if (!db.isOpen) return OperatingConditionsDraft.empty();
      final rows = await db.query(
        'maintenance_visits',
        where: 'id = ?',
        whereArgs: [visitId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return OperatingConditionsDraft.fromMap(rows.first);
      }
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] loadOperatingConditions error: $e\n$stack');
    }
    return OperatingConditionsDraft.empty();
  }

  /// Saves updated operating conditions and safety assessments.
  Future<void> saveOperatingConditions(
    int visitId,
    OperatingConditionsDraft draft,
  ) async {
    try {
      final db = await _db;
      if (!db.isOpen) return;
      await db.update(
        'maintenance_visits',
        draft.toMap(),
        where: 'id = ?',
        whereArgs: [visitId],
      );
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] saveOperatingConditions error: $e\n$stack');
    }
  }

  /// Loads all 3 measurement slots ('proef1', 'proef2_laaglast', 'proef2_hooglast').
  Future<Map<String, MeasurementSlotDraft>> loadMeasurementSlots(
      int visitId) async {
    final Map<String, MeasurementSlotDraft> result = {
      'proef1': MeasurementSlotDraft.empty('proef1'),
      'proef2_laaglast': MeasurementSlotDraft.empty('proef2_laaglast'),
      'proef2_hooglast': MeasurementSlotDraft.empty('proef2_hooglast'),
    };

    try {
      final db = await _db;
      if (!db.isOpen) return result;
      final rows = await db.query(
        'measurement_captures',
        where: 'visit_id = ?',
        whereArgs: [visitId],
      );
      for (final row in rows) {
        final slotKey = row['slot'] as String?;
        if (slotKey != null && result.containsKey(slotKey)) {
          result[slotKey] = MeasurementSlotDraft.fromMap(row);
        }
      }
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] loadMeasurementSlots error: $e\n$stack');
    }

    return result;
  }

  /// Saves or updates a single measurement slot.
  Future<void> saveMeasurementSlot(
    int visitId,
    MeasurementSlotDraft slotDraft,
  ) async {
    try {
      final db = await _db;
      if (!db.isOpen) return;
      await db.insert(
        'measurement_captures',
        slotDraft.toMap(visitId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] saveMeasurementSlot error: $e\n$stack');
    }
  }

  /// Clears a measurement slot from the database.
  Future<void> clearMeasurementSlot(int visitId, String slot) async {
    try {
      final db = await _db;
      if (!db.isOpen) return;
      await db.delete(
        'measurement_captures',
        where: 'visit_id = ? AND slot = ?',
        whereArgs: [visitId, slot],
      );
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] clearMeasurementSlot error: $e\n$stack');
    }
  }

  /// Loads raw flue-gas measurement captured on Tab 1 ('tab1_raw').
  Future<MeasurementSlotDraft?> loadTab1RawMeasurement(int visitId) async {
    try {
      final db = await _db;
      if (!db.isOpen) return null;
      final rows = await db.query(
        'measurement_captures',
        where: 'visit_id = ? AND slot = ?',
        whereArgs: [visitId, 'tab1_raw'],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return MeasurementSlotDraft.fromMap(rows.first);
      }
    } catch (e, stack) {
      debugPrint(
          '[MeasurementDraftRepository] loadTab1RawMeasurement error: $e\n$stack');
    }
    return null;
  }
}
