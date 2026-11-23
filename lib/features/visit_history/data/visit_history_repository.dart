import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../pdf_export/data/pdf_visit_data.dart';
import '../../pdf_export/data/pdf_visit_loader.dart';
import '../../reporting_delivery/data/veka_follow_up.dart';

class VisitHistoryEntry {
  final int id;
  final PdfVisitData certificate;
  final DateTime? due;
  final String? applianceKey;
  final VekaFollowUp? reporting;

  VisitHistoryEntry(this.id, Map<String, Object?> snapshot, {this.reporting})
      : certificate = PdfVisitLoader.fromSnapshot(snapshot),
        due = _date((snapshot['visit'] as Map)['next_inspection_date']),
        applianceKey = _applianceKey(snapshot);

  /// A serial at the same physical address identifies a repeated appliance.
  /// Without a serial, only a repeated stored boiler ID is safe to group.
  static String? _applianceKey(Map<String, Object?> snapshot) {
    final boiler = snapshot['boiler'] as Map;
    final location = snapshot['location'] as Map;
    String normalize(Object? value) =>
        (value ?? '').toString().trim().toLowerCase();
    final serial = normalize(boiler['boiler_serial_number']);
    final address = [
      'street',
      'house_number',
      'box_number',
      'postal_code',
      'municipality'
    ].map((key) => normalize(location[key])).toList();
    if (serial.isNotEmpty &&
        address[0].isNotEmpty &&
        address[1].isNotEmpty &&
        address[3].isNotEmpty &&
        address[4].isNotEmpty) {
      return jsonEncode([serial, ...address]);
    }
    final id = boiler['id'];
    return id == null ? null : 'boiler-$id';
  }

  static DateTime? _date(Object? value) {
    final raw = value as String? ?? '';
    final date = DateTime.tryParse(raw);
    return date != null && date.toIso8601String().split('T').first == raw
        ? date
        : null;
  }
}

class VisitHistory {
  final List<VisitHistoryEntry> entries;
  final int unreadable;

  const VisitHistory(this.entries, this.unreadable);

  List<VisitHistoryEntry> dueWithin(DateTime today, {int days = 30}) {
    final limit = DateTime(today.year, today.month, today.day + days);
    final seen = <String>{};
    final due = <VisitHistoryEntry>[];
    for (final entry in entries) {
      final key = entry.applianceKey;
      if (key != null && !seen.add(key)) continue;
      if (entry.due != null && !entry.due!.isAfter(limit)) due.add(entry);
    }
    return due..sort((a, b) => a.due!.compareTo(b.due!));
  }
}

class VisitHistoryRepository {
  final Future<Database> Function() _database;
  VisitHistoryRepository({Future<Database> Function()? database})
      : _database = database ?? (() => AppDatabase.instance.database);

  Future<bool> finalize(int visitId) async {
    final db = await _database();
    return db.transaction((tx) async {
      final rows = await tx.query('maintenance_visits',
          columns: ['is_draft', 'snapshot_json', 'klant_undo_json'],
          where: 'id = ?',
          whereArgs: [visitId],
          limit: 1);
      if (rows.isEmpty) throw StateError('Missing visit');
      final row = rows.single;
      if (row['is_draft'] == 0 && row['snapshot_json'] != null) {
        return _needsFollowUp(tx, visitId, _decode(row));
      }
      if ((row['klant_undo_json'] as String? ?? '').trim().isNotEmpty) {
        throw StateError('Unsettled customer edit');
      }
      final snapshot = await PdfVisitLoader.capture(tx, visitId, exact: true);
      PdfVisitLoader.fromSnapshot(snapshot);
      if (await tx.update(
              'maintenance_visits',
              {
                'is_draft': 0,
                'snapshot_json': jsonEncode(snapshot),
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ? AND is_draft = 1',
              whereArgs: [visitId]) !=
          1) {
        throw StateError('Visit already changed');
      }
      return _needsFollowUp(tx, visitId, snapshot);
    });
  }

  Future<bool> _needsFollowUp(
      Transaction tx, int id, Map<String, Object?> snapshot) async {
    final row = await VekaFollowUp.forVisit(tx, id);
    return row != null && VekaFollowUp.fromRow(row, snapshot) != null;
  }

  static Map<String, Object?> _decode(Map<String, Object?> row) =>
      jsonDecode(row['snapshot_json'] as String? ?? '') as Map<String, Object?>;

  Future<VisitHistory> load() async {
    final db = await _database();
    final rows = await db.rawQuery('''SELECT ${VekaFollowUp.columns}
      ${VekaFollowUp.join} WHERE mv.is_draft = 0
      ORDER BY mv.visit_date DESC, mv.id DESC''');
    final entries = <VisitHistoryEntry>[];
    var unreadable = 0;
    for (final row in rows) {
      try {
        final snapshot = _decode(row);
        entries.add(VisitHistoryEntry(row['id'] as int, snapshot,
            reporting: VekaFollowUp.fromRow(row, snapshot)));
      } catch (_) {
        unreadable++;
      }
    }
    return VisitHistory(entries, unreadable);
  }

  /// Reverts a finalized visit back to an active draft in SQLite.
  Future<void> revertFinalization(int visitId) async {
    final db = await _database();
    await db.update(
      'maintenance_visits',
      {
        'is_draft': 1,
        'snapshot_json': null,
        'pdf_status': 'draft',
        'pdf_path': null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  /// Persists a newly added customer email to the customer record if empty.
  Future<void> updateCustomerEmailForVisit(int visitId, String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    try {
      final db = await _database();
      final rows = await db.query(
        'maintenance_visits',
        columns: ['customer_id'],
        where: 'id = ?',
        whereArgs: [visitId],
        limit: 1,
      );
      if (rows.isNotEmpty && rows.first['customer_id'] != null) {
        final custId = rows.first['customer_id'] as int;
        await db.update(
          'customers',
          {'email': trimmed},
          where: 'id = ? AND (email IS NULL OR email = "")',
          whereArgs: [custId],
        );
      }
    } catch (e, stack) {
      debugPrint(
          '[VisitHistoryRepository] backfillCustomerEmail error: $e\n$stack');
    }
  }
}
