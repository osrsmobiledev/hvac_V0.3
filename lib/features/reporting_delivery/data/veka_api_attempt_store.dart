import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/veka_attempt_schema.dart';
import 'veka_api_attempt.dart';
import 'veka_api_transport.dart';

abstract final class VekaApiAttemptStore {
  static String now() => DateTime.now().toUtc().toIso8601String();

  static Future<VekaApiAttempt?> latest(
      DatabaseExecutor db, int visitId) async {
    final rows = await db.query(vekaApiAttemptsTable,
        where: 'visit_id = ?',
        whereArgs: [visitId],
        orderBy: 'id DESC',
        limit: 1);
    return rows.isEmpty ? null : VekaApiAttempt.fromRow(rows.single);
  }

  static Future<VekaApiAttempt> start(
      Transaction tx, VekaApiPrepared prepared) async {
    final row = <String, Object?>{
      'visit_id': prepared.report.visitId,
      'request_reference': prepared.requestReference,
      'request_json': prepared.requestJson,
      'report_json': _reportJson(prepared.report.values),
      'contract_version': prepared.contractVersion,
      'status': VekaApiStatus.sending.value,
      'created_at': now(),
      'dispatch_number': 1,
    };
    final id = await tx.insert(vekaApiAttemptsTable, row);
    final attempt = VekaApiAttempt.fromRow({...row, 'id': id});
    await _recordDispatch(tx, attempt);
    return attempt;
  }

  static Future<VekaApiAttempt> startNext(
      Transaction tx, VekaApiAttempt attempt) async {
    final row = {
      'status': VekaApiStatus.sending.value,
      'dispatch_number': attempt.dispatchNumber + 1,
      'resolved_at': null,
      'response_status': null,
      'response_json': null,
      'receipt_number': null,
    };
    final next = await _update(tx, attempt, row);
    await _recordDispatch(tx, next);
    return next;
  }

  static Future<void> _recordDispatch(
      Transaction tx, VekaApiAttempt attempt) async {
    await tx.insert(vekaApiDispatchesTable, {
      'attempt_id': attempt.id,
      'dispatch_number': attempt.dispatchNumber,
      'status': VekaApiStatus.sending.value,
      'started_at': now(),
    });
  }

  /// The dispatch row keeps its outcome even if an authorized retry follows.
  static Future<VekaApiAttempt> finish(
      Transaction tx, VekaApiAttempt attempt, VekaApiResponse? response,
      {bool forceUncertain = false}) async {
    final result = forceUncertain || response == null
        ? (status: VekaApiStatus.uncertain, receiptNumber: null)
        : response.classify(attempt.requestReference);
    final details = {
      'status': result.status.value,
      'response_status': response?.statusCode,
      'response_json': response?.body,
    };
    final resolvedAt = now();
    final finished = await _update(tx, attempt, {
      ...details,
      'receipt_number': result.receiptNumber,
      'resolved_at': resolvedAt,
    });
    // Reconciliation adds response evidence to the attempt, keeping the
    // original uncertain dispatch evidence intact for review.
    if (attempt.status == VekaApiStatus.sending) {
      final matched = await tx.update(
          vekaApiDispatchesTable, {...details, 'finished_at': resolvedAt},
          where: 'attempt_id = ? AND dispatch_number = ? AND status = ?',
          whereArgs: [
            attempt.id,
            attempt.dispatchNumber,
            VekaApiStatus.sending.value
          ]);
      // An unlogged result cannot establish acceptance. Recovery still needs
      // to mark an orphaned sending attempt uncertain and keep it blocked.
      if (matched != 1 && result.status != VekaApiStatus.uncertain) {
        throw StateError('The API dispatch log is missing');
      }
    }
    return finished;
  }

  /// A failed receipt commit cannot safely clear the sending hold.
  static VekaApiAttempt unresolved(VekaApiAttempt attempt) =>
      VekaApiAttempt.fromRow({
        ..._row(attempt),
        'status': VekaApiStatus.uncertain.value,
        'resolved_at': now(),
      });

  static Future<VekaApiAttempt> _update(Transaction tx, VekaApiAttempt attempt,
      Map<String, Object?> changes) async {
    final count = await tx.update(vekaApiAttemptsTable, changes,
        where: 'id = ? AND status = ? AND dispatch_number = ?',
        whereArgs: [attempt.id, attempt.status.value, attempt.dispatchNumber]);
    if (count != 1) throw StateError('The API dispatch was changed');
    return VekaApiAttempt.fromRow({..._row(attempt), ...changes});
  }

  static Map<String, Object?> _row(VekaApiAttempt attempt) => {
        'id': attempt.id,
        'visit_id': attempt.visitId,
        'request_reference': attempt.requestReference,
        'request_json': attempt.requestJson,
        'report_json': _reportJson(attempt.report.values),
        'contract_version': attempt.contractVersion,
        'status': attempt.status.value,
        'created_at': attempt.createdAt.toIso8601String(),
        'resolved_at': attempt.resolvedAt?.toIso8601String(),
        'response_status': attempt.responseStatus,
        'response_json': attempt.responseJson,
        'receipt_number': attempt.receiptNumber,
        'dispatch_number': attempt.dispatchNumber,
      };

  static String _reportJson(Map<String, Object?> values) =>
      jsonEncode({'format_version': 1, 'values': values});
}
