import 'package:flutter/material.dart';

import '../../../app/localization/veka_api_dictionary.dart';
import '../../../app/localization/veka_dictionary.dart';
import '../data/veka_api_attempt.dart';
import '../data/veka_report.dart';

String vekaApiStatusLabel(VekaApiStatus status) => switch (status) {
      VekaApiStatus.sending => VekaApiDictionary.sending,
      VekaApiStatus.accepted => VekaApiDictionary.accepted,
      VekaApiStatus.rejected => VekaApiDictionary.rejected,
      VekaApiStatus.technical => VekaApiDictionary.technical,
      VekaApiStatus.uncertain => VekaApiDictionary.uncertain,
    };

class VekaApiAttemptSummary extends StatelessWidget {
  const VekaApiAttemptSummary({super.key, required this.attempt});

  final VekaApiAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final hint = switch (attempt.status) {
      VekaApiStatus.rejected => VekaApiDictionary.rejectedHint,
      VekaApiStatus.technical => VekaApiDictionary.technicalHint,
      VekaApiStatus.uncertain => VekaApiDictionary.uncertainHint,
      _ => null,
    };
    final icon = switch (attempt.status) {
      VekaApiStatus.sending => Icons.sync,
      VekaApiStatus.accepted => Icons.check_circle_outline,
      VekaApiStatus.rejected => Icons.error_outline,
      VekaApiStatus.technical => Icons.error_outline,
      VekaApiStatus.uncertain => Icons.help_outline,
    };
    final colors = Theme.of(context).colorScheme;
    final color = switch (attempt.status) {
      VekaApiStatus.rejected || VekaApiStatus.technical => colors.error,
      VekaApiStatus.uncertain => colors.tertiary,
      _ => colors.primary,
    };
    final receipt = attempt.receiptNumber;
    final fieldErrors = attempt.fieldErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(vekaApiStatusLabel(attempt.status),
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          ],
        ),
        Text(attempt.report.address),
        if (receipt != null)
          VekaApiValue(label: VekaApiDictionary.receipt, value: receipt),
        if (hint != null) Text(hint),
        for (final error in fieldErrors)
          Text(error.field == null
              ? error.detail
              : VekaApiDictionary.fieldError(
                  VekaApiDictionary.fieldLabel(error.field!), error.detail)),
        for (final message in attempt.messages)
          if (!fieldErrors.any((error) => error.detail == message))
            Text(message),
      ],
    );
  }
}

class VekaApiPayloadDetails extends StatelessWidget {
  const VekaApiPayloadDetails({
    super.key,
    required this.report,
    required this.requestReference,
    required this.contractVersion,
    required this.requestJson,
  });

  final VekaReport report;
  final String requestReference;
  final String contractVersion;
  final String requestJson;

  @override
  Widget build(BuildContext context) {
    final activity = report.section('activity');
    final technician = report.section('technician');
    final boiler = report.section('boiler');
    final assessment = report.section('assessment');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VekaApiValue(
          label: VekaApiDictionary.address,
          value:
              report.address.isEmpty ? VekaDictionary.missing : report.address,
        ),
        VekaApiValue(
          label: VekaDictionary.sections['activity']!,
          value: _fields([activity['activity_type'], activity['visit_date']]),
        ),
        VekaApiValue(
          label: VekaDictionary.sections['technician']!,
          value: '${_fields([
                _fields([
                  technician['technician_first_name'],
                  technician['technician_last_name'],
                ], separator: ' '),
                technician['recognition_number'],
              ])}\n${_display(technician['company_name'])}',
        ),
        VekaApiValue(
          label: VekaDictionary.sections['boiler']!,
          value: '${_fields([
                _boiler(boiler, 'brand'),
                _boiler(boiler, 'model')
              ], separator: ' ')}\n'
              '${VekaDictionary.fields['boiler_serial_number']!}: ${_boiler(boiler, 'serial_number')}',
        ),
        VekaApiValue(
          label: VekaApiDictionary.result,
          value: _fields([
            '${VekaDictionary.fields['verbrandingscontrole']!}: ${_display(assessment['verbrandingscontrole'])}',
            assessment['toestel_werking_goed'],
            assessment['toestel_werking_veilig'],
          ]),
        ),
        VekaApiValue(
          label: VekaApiDictionary.reference,
          value: requestReference,
        ),
        VekaApiValue(
          label: VekaApiDictionary.version,
          value: contractVersion,
        ),
        VekaApiJson(
          label: VekaApiDictionary.exactJson,
          json: requestJson,
        ),
      ],
    );
  }

  static String _display(Object? value) =>
      VekaDictionary.values[value] ??
      value?.toString() ??
      VekaDictionary.missing;

  static String _fields(List<Object?> values, {String separator = ' · '}) =>
      values.map(_display).join(separator);

  static Object? _boiler(Map<String, Object?> values, String name) =>
      values['boiler_${name}_unknown'] == true
          ? 'onbekend'
          : values['boiler_$name'];
}

class VekaApiValue extends StatelessWidget {
  const VekaApiValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            SelectableText(value),
          ],
        ),
      );
}

class VekaApiJson extends StatelessWidget {
  const VekaApiJson({super.key, required this.label, required this.json});

  final String label;
  final String json;

  @override
  Widget build(BuildContext context) => ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(label),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        expandedAlignment: Alignment.centerLeft,
        children: [SelectableText(json)],
      );
}
