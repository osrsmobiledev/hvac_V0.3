import 'package:sqflite/sqflite.dart';

import '../../../core/database/veka_attempt_schema.dart';
import 'veka_api_attempt.dart';
import 'veka_report.dart';

enum VekaFollowUp {
  ready,
  resume,
  check,
  correct,
  portal,
  unreadable;

  static const columns = '''mv.id, mv.snapshot_json, mv.veka_status,
    mv.veka_manual_note, api.status AS api_status, api.receipt_number''';
  static const join = '''FROM maintenance_visits mv
    LEFT JOIN $vekaApiAttemptsTable api ON api.id = (
      SELECT id FROM $vekaApiAttemptsTable WHERE visit_id = mv.id
      ORDER BY id DESC LIMIT 1
    )''';

  static Future<Map<String, Object?>?> forVisit(
      DatabaseExecutor db, int id) async {
    final rows = await db.rawQuery(
        'SELECT $columns $join WHERE mv.id = ? AND mv.is_draft = 0', [id]);
    return rows.firstOrNull;
  }

  static VekaFollowUp? fromRow(
      Map<String, Object?> row, Map<String, Object?> snapshot) {
    try {
      final manual = VekaRecord.decode(row['id'] as int,
          row['veka_status'] as String, row['veka_manual_note'] as String?);
      if (manual.confirmed) return null;
      if (manual.report != null) return portal;
    } on FormatException {
      return unreadable;
    }
    final apiStatus = row['api_status'];
    if (apiStatus == VekaApiStatus.accepted.value) {
      final receipt = row['receipt_number'] as String?;
      return receipt == null || receipt.trim().isEmpty ? unreadable : null;
    }
    if (apiStatus == VekaApiStatus.rejected.value) return correct;
    if (apiStatus == VekaApiStatus.technical.value) return resume;
    if (apiStatus == VekaApiStatus.uncertain.value ||
        apiStatus == VekaApiStatus.sending.value) {
      return check;
    }
    if (apiStatus != null) return unreadable;
    final boiler = snapshot['boiler'] as Map<String, Object?>;
    return VekaReport.supportsBoiler(boiler, central: boiler['is_central'] == 1)
        ? ready
        : null;
  }
}
