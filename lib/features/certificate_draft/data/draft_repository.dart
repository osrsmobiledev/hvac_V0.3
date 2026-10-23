import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../domain/draft_visit.dart';

/// Data service managing offline persistence for active draft visits.
///
/// Ensures every form edit on the draft tabs immediately saves into
/// the SQLite `maintenance_visits` table, preventing data loss.
class DraftRepository {
  final AppDatabase _appDatabase;

  DraftRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  /// Retrieves the existing active draft, or creates a new draft record
  /// if none currently exists.
  Future<DraftVisit> getOrCreateActiveDraft({Database? dbOverride}) async {
    final db = dbOverride ?? await _appDatabase.database;

    final rows = await db.query(
      'maintenance_visits',
      where: 'is_draft = 1',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return DraftVisit.fromMap(rows.first);
    }

    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final id = await db.insert('maintenance_visits', {
      'activity_type': 'onderhoud',
      'attest_number': '',
      'visit_date': today,
      'start_time': '',
      'end_time': '',
      'is_draft': 1,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return DraftVisit(
      id: id,
      activityType: 'onderhoud',
      attestNumber: '',
      visitDate: today,
      startTime: '',
      endTime: '',
    );
  }

  /// Updates the Tab 2 (Start) fields for the active draft visit.
  Future<void> updateStartTabDraft({
    required int visitId,
    required String activityType,
    required String attestNumber,
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;

    await db.update(
      'maintenance_visits',
      {
        'activity_type': activityType,
        'attest_number': attestNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  /// Updates the Tab 3 (Firma - Technicus) visit timings for the active draft.
  Future<void> updateVisitTimings({
    required int visitId,
    required String visitDate,
    required String startTime,
    required String endTime,
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;

    await db.update(
      'maintenance_visits',
      {
        'visit_date': visitDate,
        'start_time': startTime,
        'end_time': endTime,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  /// Updates the Tab 4 (Klant) customer and service location links for the draft.
  Future<void> updateVisitCustomer({
    required int visitId,
    int? customerId,
    int? serviceLocationId,
    Database? dbOverride,
  }) async {
    final db = dbOverride ?? await _appDatabase.database;

    await db.update(
      'maintenance_visits',
      {
        'customer_id': customerId,
        'service_location_id': serviceLocationId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }
}
