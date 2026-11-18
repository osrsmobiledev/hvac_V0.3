import 'dart:convert';

import 'veka_report.dart';

enum VekaApiStatus {
  sending('sending'),
  accepted('accepted_api'),
  rejected('rejected_api'),
  technical('technical_error'),
  uncertain('timeout_uncertain');

  final String value;
  const VekaApiStatus(this.value);
}

class VekaApiPrepared {
  final VekaReport report;
  final String requestReference;
  final String requestJson;
  final String contractVersion;

  const VekaApiPrepared({
    required this.report,
    required this.requestReference,
    required this.requestJson,
    required this.contractVersion,
  });
}

class VekaApiFieldError {
  final String detail;
  final String? field;

  const VekaApiFieldError(this.detail, {this.field});
}

class VekaApiAttempt {
  final int id;
  final int visitId;
  final String requestReference;
  final String requestJson;
  final VekaReport report;
  final String contractVersion;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final VekaApiStatus status;
  final int? responseStatus;
  final String? responseJson;
  final String? receiptNumber;
  final int dispatchNumber;

  VekaApiAttempt.fromRow(Map<String, Object?> row)
      : id = row['id'] as int,
        visitId = row['visit_id'] as int,
        requestReference = row['request_reference'] as String,
        requestJson = row['request_json'] as String,
        report = _report(row['report_json'] as String),
        contractVersion = row['contract_version'] as String,
        createdAt = DateTime.parse(row['created_at'] as String),
        resolvedAt = DateTime.tryParse(row['resolved_at'] as String? ?? ''),
        status =
            VekaApiStatus.values.singleWhere((s) => s.value == row['status']),
        responseStatus = row['response_status'] as int?,
        responseJson = row['response_json'] as String?,
        receiptNumber = row['receipt_number'] as String?,
        dispatchNumber = row['dispatch_number'] as int;

  bool get allowsManual =>
      status == VekaApiStatus.rejected || status == VekaApiStatus.technical;
  bool get allowsNewAttempt => status == VekaApiStatus.rejected;
  bool get canCorrectActivityDate =>
      allowsNewAttempt &&
      fieldErrors.isNotEmpty &&
      fieldErrors.every((error) =>
          error.field?.split(RegExp(r'[./]')).last == 'datumActiviteit');

  List<VekaApiFieldError> get fieldErrors =>
      readFieldErrors(decodeVekaApiBody(responseJson));

  List<String> get messages {
    final warnings = decodeVekaApiBody(responseJson)['opmerkingen'];
    return [
      if (warnings is List)
        ...warnings.whereType<String>().where((s) => s.trim().isNotEmpty),
      ...fieldErrors.map((error) => error.detail),
    ];
  }

  static VekaReport _report(String raw) {
    final snapshot = jsonDecode(raw) as Map<String, Object?>;
    if (snapshot['format_version'] != 1) {
      throw const FormatException('Unknown API snapshot format');
    }
    return VekaReport(snapshot['values'] as Map<String, Object?>);
  }
}

class VekaApiDispatch {
  final int number;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final VekaApiStatus status;
  final int? responseStatus;
  final String? responseJson;

  VekaApiDispatch.fromRow(Map<String, Object?> row)
      : number = row['dispatch_number'] as int,
        startedAt = DateTime.parse(row['started_at'] as String),
        finishedAt = DateTime.tryParse(row['finished_at'] as String? ?? ''),
        status =
            VekaApiStatus.values.singleWhere((s) => s.value == row['status']),
        responseStatus = row['response_status'] as int?,
        responseJson = row['response_json'] as String?;
}

Map<String, Object?> decodeVekaApiBody(String? body) {
  if (body == null) return const {};
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, Object?> ? decoded : const {};
  } on FormatException {
    return const {};
  }
}

List<VekaApiFieldError> readFieldErrors(Map<String, Object?> data) {
  final errors = data['errors'];
  if (errors is! List) return const [];
  return [
    for (final error in errors.whereType<Map<String, Object?>>())
      if (error['detail'] case final String detail
          when detail.trim().isNotEmpty)
        VekaApiFieldError(detail,
            field: switch (error['field'] ?? error['source']) {
              final String field => field,
              {'pointer': final String pointer} => pointer,
              _ => null,
            }),
  ];
}
