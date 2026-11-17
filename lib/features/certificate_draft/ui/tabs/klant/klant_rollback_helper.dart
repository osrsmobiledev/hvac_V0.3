import 'package:hvac_app/core/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'klant_edit_session.dart';

/// Handles atomic SQLite rollback and visit link changes for Tab 4.
abstract final class KlantRollbackHelper {
  /// Atomically reverts draft links, restores modified rows, and cleans up created rows.
  static Future<void> rollbackInTxn({
    required AppDatabase appDatabase,
    required KlantEditSession session,
  }) async {
    final db = await appDatabase.database;
    await db.transaction((txn) async {
      await _setDraftLinks(
        txn,
        draftId: session.draftId,
        customerId: session.initialCustomerId,
        locationId: session.initialLocationId,
      );

      final customer = session.initialCustomer;
      if (customer != null && customer.id == session.activeCustomerId) {
        await txn.update(
          'customers',
          customer.toMap(),
          where: 'id = ?',
          whereArgs: [customer.id],
        );
      }

      final location = session.initialLocation;
      if (location != null && location.id == session.activeLocationId) {
        await txn.update(
          'service_locations',
          location.toMap(),
          where: 'id = ?',
          whereArgs: [location.id],
        );
      }

      // Deleting a location would cascade to its boilers. Keep any location
      // adopted by another record, then purge customers with no locations left.
      for (final id in session.createdLocationIds) {
        if (id == session.initialLocationId) continue;
        // Warmup may have created the current draft's boiler at this address.
        // Keep its appliance data while restoring the visit's original links.
        await txn.update(
          'boilers',
          {'service_location_id': session.initialLocationId},
          where: '''
            service_location_id = ?
            AND id = (SELECT boiler_id FROM maintenance_visits WHERE id = ?)
            AND NOT EXISTS (
              SELECT 1 FROM maintenance_visits
              WHERE boiler_id = boilers.id AND id != ?
            )
          ''',
          whereArgs: [id, session.draftId, session.draftId],
        );
        await txn.delete(
          'service_locations',
          where: '''
            id = ?
            AND NOT EXISTS (
              SELECT 1 FROM maintenance_visits WHERE service_location_id = ?
            )
            AND NOT EXISTS (
              SELECT 1 FROM boilers WHERE service_location_id = ?
            )
          ''',
          whereArgs: [id, id, id],
        );
      }
      for (final id in session.createdCustomerIds) {
        if (id == session.initialCustomerId) continue;
        await txn.delete(
          'customers',
          where: '''
            id = ?
            AND NOT EXISTS (
              SELECT 1 FROM maintenance_visits WHERE customer_id = ?
            )
            AND NOT EXISTS (
              SELECT 1 FROM service_locations WHERE customer_id = ?
            )
          ''',
          whereArgs: [id, id, id],
        );
      }
    });
  }

  /// Changes both draft links and clears the prior undo in a single write.
  static Future<void> setDraftLinks({
    required AppDatabase appDatabase,
    required int draftId,
    required int? customerId,
    required int? locationId,
  }) async =>
      _setDraftLinks(
        await appDatabase.database,
        draftId: draftId,
        customerId: customerId,
        locationId: locationId,
      );

  static Future<void> _setDraftLinks(
    DatabaseExecutor db, {
    required int draftId,
    required int? customerId,
    required int? locationId,
  }) async {
    final where = locationId == null
        ? 'id = ? AND is_draft = 1'
        : '''
          id = ? AND is_draft = 1 AND EXISTS (
            SELECT 1 FROM service_locations WHERE id = ? AND customer_id = ?
          )
        ''';
    final whereArgs = locationId == null
        ? <Object>[draftId]
        : <Object>[draftId, locationId, customerId!];

    final changed = await db.update(
      'maintenance_visits',
      {
        'customer_id': customerId,
        'service_location_id': locationId,
        'klant_undo_json': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: where,
      whereArgs: whereArgs,
    );
    if (changed != 1) {
      throw StateError('Could not update links for draft $draftId');
    }
  }
}
