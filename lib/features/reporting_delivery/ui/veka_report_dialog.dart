import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../app/localization/app_dictionary.dart';
import '../../../app/localization/veka_dictionary.dart';
import '../../certificate_draft/ui/tabs/klant/address_verification_badge.dart';
import '../data/veka_report.dart';

class VekaReportDialog extends StatelessWidget {
  final VekaReport report;
  final String title;
  final String? action;
  final String? warning;
  final List<int> missingTabs;
  final Map<String, Object?>? confirmation;

  const VekaReportDialog({
    super.key,
    required this.report,
    required this.title,
    this.action,
    this.warning,
    this.missingTabs = const [],
    this.confirmation,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        report.section('installation_address')['verification_status'];
    return AlertDialog(
      title: Text(title),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(report.address.isEmpty ? VekaDictionary.missing : report.address,
              style: Theme.of(context).textTheme.titleMedium),
          if (report.address.isNotEmpty)
            AddressVerificationBadge(status: status as String? ?? 'unverified'),
          if (report.address.isNotEmpty && status == 'unverified')
            const Text(VekaDictionary.manualAddress),
          if (warning != null) Text(warning!),
          for (final tab in missingTabs) ...[
            Text(VekaDictionary.missingIn(tab)),
            if (tab == 3)
              for (final issue in report.technicianIssues(DateTime.now()))
                Text(VekaDictionary.technicianIssue[issue]!),
            if (tab == 6) const Text(VekaDictionary.combustionIssue),
            if (tab == 7)
              for (final key in report.finalAssessmentIssues())
                Text(VekaDictionary.assessmentIssue(key)),
          ],
          for (final key in VekaReport.sections
              .where((key) => key != 'installation_address'))
            _ReportSection(VekaDictionary.sections[key]!, report.section(key)),
          if (confirmation != null)
            _ReportSection(
                VekaDictionary.sections['confirmation']!, confirmation!),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                scrollable: true,
                title: const Text(VekaDictionary.json),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(VekaDictionary.jsonPreviewHint),
                    const SizedBox(height: 12),
                    SelectableText(const JsonEncoder.withIndent('  ')
                        .convert(report.previewJson)),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppDictionary.btnOk))
                ],
              ),
            ),
            child: const Text(VekaDictionary.json),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(action == null
                ? AppDictionary.btnOk
                : AppDictionary.btnCancel)),
        if (action != null)
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action!)),
      ],
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final Map<String, Object?> values;
  const _ReportSection(this.title, this.values);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            for (final entry in values.entries)
              if (VekaDictionary.fields[entry.key] case final label?)
                Text('$label: ${_display(entry)}'),
          ],
        ),
      );

  String _display(MapEntry<String, Object?> entry) {
    final value = entry.value;
    if (value == null) {
      return values['${entry.key}_unknown'] == true
          ? VekaDictionary.values['onbekend']!
          : VekaDictionary.missing;
    }
    return VekaDictionary.values[value] ?? value.toString();
  }
}
