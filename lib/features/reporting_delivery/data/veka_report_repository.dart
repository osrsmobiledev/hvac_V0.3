import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import 'veka_api_attempt_store.dart';
import 'veka_reference.dart';
import 'veka_report.dart';
import 'veka_report_mapper.dart';

enum VekaIssue { customerEditing, changed, ineligible, save }

class VekaException implements Exception {
  final VekaIssue issue;

  const VekaException(this.issue);
}

class VekaReportRepository {
  final Future<Database> Function() _database;

  VekaReportRepository({Future<Database> Function()? database})
      : _database = database ?? (() => AppDatabase.instance.database);

  Future<VekaRecord> read(int visitId) async =>
      _record(visitId, await _visit(await _database(), visitId));

  Future<VekaReport> preview(int visitId,
      {bool requireSettledCustomer = true}) async {
    final db = await _database();
    return db.transaction((tx) async {
      final visit = await _visit(tx, visitId);
      if (requireSettledCustomer) _checkCustomer(visit);
      return _snapshot(tx, visitId, visit);
    });
  }

  /// Gate the API claim on the same transaction as the reviewed snapshot.
  Future<VekaReport> previewForApi(Transaction tx, int visitId,
      {bool requireArchived = false}) async {
    final visit = await _visit(tx, visitId);
    if (_record(visitId, visit).report != null ||
        (requireArchived && visit['is_draft'] != 0)) {
      throw const VekaException(VekaIssue.changed);
    }
    _checkCustomer(visit);
    return _snapshot(tx, visitId, visit);
  }

  /// Compare the reviewed values again inside the same transaction as the write.
  Future<VekaRecord> reserve(VekaReport reviewed,
      {required String? replaces}) async {
    final db = await _database();
    return db.transaction((tx) async {
      final visit = await _visitForManual(tx, reviewed.visitId);
      final current = _record(reviewed.visitId, visit);
      if (current.confirmed || current.report?.id != replaces) {
        throw const VekaException(VekaIssue.changed);
      }
      _checkCustomer(visit);
      final fresh = await _snapshot(tx, reviewed.visitId, visit);
      final now = DateTime.now();
      if (fresh.differsFrom(reviewed)) {
        throw const VekaException(VekaIssue.changed);
      }
      if (!fresh.supported || fresh.missingTabs(now).isNotEmpty) {
        throw const VekaException(VekaIssue.ineligible);
      }
      final record = VekaRecord(
          report: VekaReport({
        ...fresh.values,
        'snapshot_id': newVekaReference(),
        'reserved_at': now.toUtc().toIso8601String(),
      }));
      await _write(tx, reviewed.visitId, record);
      return record;
    });
  }

  Future<VekaRecord> confirm(
    int visitId,
    String snapshotId, {
    required String actor,
    String? reference,
    DateTime? submittedAt,
  }) async {
    final db = await _database();
    return db.transaction((tx) async {
      final current = _record(visitId, await _visitForManual(tx, visitId));
      if (current.report?.id != snapshotId) {
        throw const VekaException(VekaIssue.changed);
      }
      if (current.confirmed) return current;
      final now = DateTime.now();
      if (actor.trim().isEmpty || (submittedAt?.isAfter(now) ?? false)) {
        throw const VekaException(VekaIssue.ineligible);
      }
      final confirmation = VekaRecord(report: current.report, confirmation: {
        'snapshot_id': snapshotId,
        'confirmed_by': actor.trim(),
        'confirmed_at': now.toUtc().toIso8601String(),
        'portal_reference': _clean(reference),
        'portal_submitted_at': submittedAt?.toUtc().toIso8601String(),
      });
      await _write(tx, visitId, confirmation);
      return confirmation;
    });
  }

  Future<Map<String, Object?>> _visitForManual(
      Transaction tx, int visitId) async {
    final attempt = await VekaApiAttemptStore.latest(tx, visitId);
    if (attempt?.allowsManual == false) {
      throw const VekaException(VekaIssue.changed);
    }
    return _visit(tx, visitId);
  }

  Future<void> _write(Transaction tx, int id, VekaRecord record) async {
    final count = await tx.update(
        'maintenance_visits',
        {
          'veka_status':
              record.confirmed ? VekaRecord.reported : VekaRecord.pending,
          'veka_manual_note': record.encode(),
        },
        where: 'id = ?',
        whereArgs: [id]);
    if (count != 1) throw const VekaException(VekaIssue.save);
  }

  VekaRecord _record(int id, Map<String, Object?> row) => VekaRecord.decode(
      id, row['veka_status'] as String, row['veka_manual_note'] as String?);

  Future<Map<String, Object?>> _visit(DatabaseExecutor db, int id) async {
    final row = await _row(db, 'maintenance_visits', id);
    if (row.isEmpty) throw const VekaException(VekaIssue.save);
    return row;
  }

  void _checkCustomer(Map<String, Object?> visit) {
    if (_clean(visit['klant_undo_json']) != null) {
      throw const VekaException(VekaIssue.customerEditing);
    }
  }

  static Object? _clean(Object? value) =>
      value is String ? (value.trim().isEmpty ? null : value.trim()) : value;

  Future<Map<String, Object?>> _row(
      DatabaseExecutor db, String table, Object? id) async {
    if (id == null) return const {};
    final rows =
        await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? const {} : rows.single;
  }

  Future<VekaReport> _snapshot(
      Transaction tx, int id, Map<String, Object?> visit) async {
    if (visit['is_draft'] == 0) {
      final snapshot =
          jsonDecode(visit['snapshot_json'] as String? ?? '') as Map;
      if (snapshot['format_version'] != 1) throw const FormatException();
      return VekaReportMapper.map(
          id,
          snapshot['visit'] as Map<String, Object?>,
          snapshot['profile'] as Map<String, Object?>,
          snapshot['location'] as Map<String, Object?>,
          snapshot['boiler'] as Map<String, Object?>);
    }
    final location =
        await _row(tx, 'service_locations', visit['service_location_id']);
    final boiler = await _row(tx, 'boilers', visit['boiler_id']);
    final profiles =
        await tx.query('technician_profile', orderBy: 'id ASC', limit: 1);
    return VekaReportMapper.map(
        id, visit, profiles.isEmpty ? {} : profiles.single, location, boiler);
  }
}
