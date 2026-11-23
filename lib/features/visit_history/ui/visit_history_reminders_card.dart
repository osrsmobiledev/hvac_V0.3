import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/localization/visit_history_dictionary.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../pdf_export/ui/pdf_preview_dialog.dart';
import '../data/visit_history_repository.dart';

/// Card rendering upcoming and overdue maintenance reminders with share capability.
class VisitHistoryRemindersCard extends StatelessWidget {
  final String title;
  final List<VisitHistoryEntry> entries;

  const VisitHistoryRemindersCard({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(title),
              trailing: Text('${entries.length}'),
            ),
            if (entries.isEmpty)
              const ListTile(
                title: Text(VisitHistoryDictionary.noReminders),
              ),
            for (final entry in entries)
              ListTile(
                title: Text(_customer(entry)),
                subtitle: Text(
                  '${_dateLabel(context, entry.due!)} · ${_address(entry)}',
                ),
                trailing: IconButton(
                  tooltip: VisitHistoryDictionary.reminder,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _share(context, entry),
                ),
                onTap: () => PdfPreviewDialog.show(context, entry.certificate),
              ),
          ],
        ),
      );

  Future<void> _share(BuildContext context, VisitHistoryEntry entry) async {
    final message = VisitHistoryDictionary.message(
      _address(entry),
      _dateLabel(context, entry.due!),
    );
    try {
      await const MethodChannel('com.example.hvac_app/reminders')
          .invokeMethod<void>('share', message);
    } catch (e, stack) {
      debugPrint('[VisitHistoryRemindersCard] share error: $e\n$stack');
      if (context.mounted) {
        TacticalFeedback.showError(context, VisitHistoryDictionary.shareFailed);
      }
    }
  }

  static String _customer(VisitHistoryEntry entry) {
    final d = entry.certificate;
    final n = [d.klantVoornaam, d.klantAchternaam]
        .where((p) => p.isNotEmpty)
        .join(' ');
    final l = [d.klantBedrijf, n].where((p) => p.isNotEmpty).join(' · ');
    return l.isEmpty ? VisitHistoryDictionary.customer : l;
  }

  static String _address(VisitHistoryEntry entry) {
    final d = entry.certificate;
    return [
      d.locatieStraat,
      d.locatieNr,
      if (d.locatieBus.isNotEmpty) 'bus ${d.locatieBus}',
      d.locatiePostcode,
      d.locatieGemeente,
    ].where((p) => p.isNotEmpty).join(' ');
  }

  static String _dateLabel(BuildContext context, DateTime date) =>
      MaterialLocalizations.of(context).formatShortDate(date);
}
