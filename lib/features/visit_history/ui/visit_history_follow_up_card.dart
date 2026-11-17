import 'package:flutter/material.dart';

import '../../../app/localization/visit_history_dictionary.dart' as labels;
import '../../reporting_delivery/data/veka_follow_up.dart';
import '../data/visit_history_repository.dart';

typedef _Text = labels.VisitHistoryDictionary;

class VisitHistoryFollowUpCard extends StatelessWidget {
  const VisitHistoryFollowUpCard({
    super.key,
    required this.entries,
    required this.open,
  });

  final List<VisitHistoryEntry> entries;
  final ValueChanged<VisitHistoryEntry> open;

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          children: [
            const ListTile(title: Text(_Text.followUp)),
            for (final entry in entries)
              if (entry.reporting case final status?)
                ListTile(
                  key: ValueKey('veka-${entry.id}'),
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(_customer(entry)),
                  subtitle: Text('${_address(entry)}\n${_action(status)}'),
                  trailing: const Icon(Icons.chevron_right),
                  isThreeLine: true,
                  onTap: () => open(entry),
                ),
          ],
        ),
      );

  String _action(VekaFollowUp status) => switch (status) {
        VekaFollowUp.ready => _Text.reportReady,
        VekaFollowUp.resume => _Text.reportResume,
        VekaFollowUp.check => _Text.reportCheck,
        VekaFollowUp.correct => _Text.reportCorrect,
        VekaFollowUp.portal => _Text.reportPortal,
        VekaFollowUp.unreadable => _Text.reportUnreadable,
      };

  String _customer(VisitHistoryEntry entry) {
    final data = entry.certificate;
    final name = [data.klantVoornaam, data.klantAchternaam]
        .where((part) => part.isNotEmpty)
        .join(' ');
    final label =
        [data.klantBedrijf, name].where((part) => part.isNotEmpty).join(' · ');
    return label.isEmpty ? _Text.customer : label;
  }

  String _address(VisitHistoryEntry entry) {
    final data = entry.certificate;
    return [
      data.locatieStraat,
      data.locatieNr,
      if (data.locatieBus.isNotEmpty) 'bus ${data.locatieBus}',
      data.locatiePostcode,
      data.locatieGemeente,
    ].where((part) => part.isNotEmpty).join(' ');
  }
}
