import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/veka_attempt_schema.dart';
import 'veka_api_attempt.dart';
import 'veka_api_attempt_store.dart';
import 'veka_api_payload.dart';
import 'veka_api_transport.dart';
import 'veka_reference.dart';
import 'veka_report.dart';
import 'veka_report_repository.dart';

/// Claims a mock dispatch in SQLite before any transport call.
class VekaApiRepository {
  final Future<Database> Function() _database;
  final VekaApiTransport _transport;
  final Duration _timeout;

  // Another connection or screen must distinguish a live local dispatch from
  // one interrupted by a process restart. The reference is globally unique.
  static final _activeReferences = <String>{};

  VekaApiRepository({
    Future<Database> Function()? database,
    VekaApiTransport? transport,
    Duration timeout = const Duration(seconds: 10),
  })  : _database = database ?? (() => AppDatabase.instance.database),
        _transport = transport ?? VekaMockTransport.send,
        _timeout = timeout;

  VekaApiPrepared prepare(VekaReport reviewed) {
    final reference = newVekaReference();
    return VekaApiPrepared(
      report: reviewed,
      requestReference: reference,
      requestJson:
          VekaApiPayload.fromReport(reviewed, reference, DateTime.now()).json,
      contractVersion: VekaApiPayload.contractVersion,
    );
  }

  Future<VekaApiAttempt?> read(int visitId) async {
    final db = await _database();
    return db.transaction((tx) async {
      final latest = await VekaApiAttemptStore.latest(tx, visitId);
      if (latest == null ||
          latest.status != VekaApiStatus.sending ||
          _activeReferences.contains(latest.requestReference)) {
        return latest;
      }
      return VekaApiAttemptStore.finish(tx, latest, null);
    });
  }

  Future<List<VekaApiAttempt>> history(int visitId) async {
    await read(visitId);
    final db = await _database();
    final rows = await db.query(vekaApiAttemptsTable,
        where: 'visit_id = ?', whereArgs: [visitId], orderBy: 'id DESC');
    return rows.map(VekaApiAttempt.fromRow).toList();
  }

  Future<List<VekaApiDispatch>> dispatches(VekaApiAttempt attempt) async {
    final rows = await (await _database()).query(vekaApiDispatchesTable,
        where: 'attempt_id = ?',
        whereArgs: [attempt.id],
        orderBy: 'dispatch_number DESC');
    return rows.map(VekaApiDispatch.fromRow).toList();
  }

  Future<VekaApiAttempt> submit(VekaReport reviewed,
      {VekaApiPrepared? prepared,
      VekaApiAttempt? corrects,
      VekaMockOutcome outcome = VekaMockOutcome.accepted}) async {
    final candidate = prepared ?? prepare(reviewed);
    final db = await _database();
    final reports = VekaReportRepository(database: _database);
    return _claimAndSend(db, candidate.requestReference, outcome, (tx) async {
      var fresh = await reports.previewForApi(tx, reviewed.visitId,
          requireArchived: corrects != null);
      final last = await VekaApiAttemptStore.latest(tx, reviewed.visitId);
      if (corrects != null) {
        final date = reviewed.section('activity')['visit_date'];
        if (last == null ||
            last.id != corrects.id ||
            last.requestReference != corrects.requestReference ||
            last.dispatchNumber != corrects.dispatchNumber ||
            !last.canCorrectActivityDate ||
            date is! String ||
            date == last.report.section('activity')['visit_date']) {
          throw const VekaException(VekaIssue.changed);
        }
        fresh = fresh.withActivityDate(date);
      }
      if (candidate.report.visitId != reviewed.visitId ||
          candidate.report.differsFrom(reviewed) ||
          fresh.differsFrom(reviewed) ||
          candidate.contractVersion != VekaApiPayload.contractVersion ||
          !RegExp(r'^[a-f0-9]{32}$').hasMatch(candidate.requestReference) ||
          candidate.requestJson !=
              VekaApiPayload.fromReport(
                      fresh, candidate.requestReference, DateTime.now())
                  .json) {
        throw const VekaException(VekaIssue.changed);
      }
      if (!canSubmit(candidate, previous: last)) {
        throw const VekaException(VekaIssue.changed);
      }
      // The reviewed sections and outgoing payload match. Freeze the snapshot
      // read here, with an ID tied to this attempt and its reservation time.
      return VekaApiAttemptStore.start(
        tx,
        VekaApiPrepared(
          report: VekaReport({
            ...fresh.values,
            'snapshot_id': candidate.requestReference,
            'reserved_at': VekaApiAttemptStore.now(),
          }),
          requestReference: candidate.requestReference,
          requestJson: candidate.requestJson,
          contractVersion: candidate.contractVersion,
        ),
      );
    });
  }

  /// A correction must change a field that will actually be sent.
  bool canSubmit(VekaApiPrepared candidate, {VekaApiAttempt? previous}) =>
      previous == null ||
      (previous.allowsNewAttempt &&
          candidate.requestJson !=
              jsonEncode({
                ...decodeVekaApiBody(previous.requestJson),
                'externeReferte': candidate.requestReference,
              }));

  /// Simulates an explicit absence check before reusing the original request.
  Future<VekaApiAttempt> confirmAbsentAndRetry(
    int visitId,
    String requestReference, {
    required int expectedDispatchNumber,
    required VekaMockOutcome outcome,
  }) async {
    final db = await _database();
    return _claimAndSend(db, requestReference, outcome, (tx) async {
      final attempt = await _matchingAttempt(tx, visitId, requestReference,
          expectedDispatchNumber, VekaApiStatus.uncertain);
      return VekaApiAttemptStore.startNext(tx, attempt);
    });
  }

  /// Replays a refused request after access is restored, unless the visit changed
  /// or the technician has already reserved the report for the portal.
  Future<VekaApiAttempt> retryAfterAccessRestored(
    VekaApiAttempt reviewed, {
    required VekaMockOutcome outcome,
  }) async {
    final db = await _database();
    final reports = VekaReportRepository(database: _database);
    return _claimAndSend(db, reviewed.requestReference, outcome, (tx) async {
      final attempt = await _matchingAttempt(
          tx,
          reviewed.visitId,
          reviewed.requestReference,
          reviewed.dispatchNumber,
          VekaApiStatus.technical);
      final fresh = await reports.previewForApi(tx, attempt.visitId);
      if (fresh.differsFrom(attempt.report)) {
        throw const VekaException(VekaIssue.changed);
      }
      return VekaApiAttemptStore.startNext(tx, attempt);
    });
  }

  /// Simulates verification against matching evidence without sending again.
  Future<VekaApiAttempt> reconcileReceipt(
    int visitId,
    String requestReference, {
    required int expectedDispatchNumber,
  }) async {
    final db = await _database();
    return db.transaction((tx) async {
      final attempt = await _matchingAttempt(tx, visitId, requestReference,
          expectedDispatchNumber, VekaApiStatus.uncertain);
      return VekaApiAttemptStore.finish(
          tx, attempt, VekaMockTransport.receipt(attempt.requestReference));
    });
  }

  Future<VekaApiAttempt> _matchingAttempt(Transaction tx, int visitId,
      String reference, int dispatch, VekaApiStatus status) async {
    final attempt = await VekaApiAttemptStore.latest(tx, visitId);
    if (attempt == null ||
        attempt.requestReference != reference ||
        attempt.status != status ||
        attempt.dispatchNumber != dispatch) {
      throw const VekaException(VekaIssue.changed);
    }
    return attempt;
  }

  Future<VekaApiAttempt> _claimAndSend(
    Database db,
    String reference,
    VekaMockOutcome outcome,
    Future<VekaApiAttempt> Function(Transaction) claim,
  ) async {
    if (!_activeReferences.add(reference)) {
      throw const VekaException(VekaIssue.changed);
    }
    try {
      final attempt = await db.transaction(claim);
      VekaApiResponse? response;
      try {
        response =
            await _transport(attempt.requestJson, outcome).timeout(_timeout);
      } catch (_) {
        // A thrown transport error leaves delivery unconfirmed.
      }
      try {
        return await db.transaction(
            (tx) => VekaApiAttemptStore.finish(tx, attempt, response));
      } catch (_) {
        try {
          return await db.transaction((tx) => VekaApiAttemptStore.finish(
              tx, attempt, response,
              forceUncertain: true));
        } catch (_) {
          // A new connection will recover the durable sending hold later.
          return VekaApiAttemptStore.unresolved(attempt);
        }
      }
    } finally {
      _activeReferences.remove(reference);
    }
  }
}
