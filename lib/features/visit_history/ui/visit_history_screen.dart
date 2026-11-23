import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/localization/visit_history_dictionary.dart' as labels;
import '../../email_delivery/data/email_delivery_coordinator.dart';
import '../../email_delivery/data/email_outbox_repository.dart';
import '../../email_delivery/data/pdf_archiving_coordinator.dart';
import '../../email_delivery/ui/email_delivery_card.dart';
import '../../pdf_export/ui/pdf_preview_dialog.dart';
import '../../reporting_delivery/ui/veka_tracker.dart';
import '../data/visit_history_repository.dart';
import 'visit_history_follow_up_card.dart';
import 'visit_history_reminders_card.dart';

typedef _Text = labels.VisitHistoryDictionary;

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key, this.repository});
  final VisitHistoryRepository? repository;

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  late final _repository = widget.repository ?? VisitHistoryRepository();
  late Future<VisitHistory> _history = _repository.load();
  String _query = '';

  void _reload() => setState(() => _history = _repository.load());

  Future<void> _openReporting(VisitHistoryEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: SingleChildScrollView(
          child: VekaTracker(visitId: entry.id, archived: true),
        ),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _openEmail(VisitHistoryEntry entry) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: SingleChildScrollView(
          child: EmailDeliveryCard(
            visitId: entry.id,
            outboxRepository: EmailOutboxRepository(),
            coordinator: EmailDeliveryCoordinator.instance,
            archivingCoordinator: PdfArchivingCoordinator(),
          ),
        ),
      ),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<VisitHistory>(
              future: _history,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(_Text.loadError),
                        TextButton(
                            onPressed: _reload, child: const Text(_Text.retry)),
                      ]);
                }
                final history = snapshot.requireData;
                final today = DateTime.now();
                final day = DateTime(today.year, today.month, today.day);
                final reminders = history.dueWithin(day);
                final overdue = reminders
                    .where((entry) => entry.due!.isBefore(day))
                    .toList();
                final upcoming = reminders
                    .where((entry) => !entry.due!.isBefore(day))
                    .toList();
                final matches =
                    history.entries.where((entry) => _matches(entry, _query));
                return RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    try {
                      await _history;
                    } catch (_) {/* Rendered by FutureBuilder. */}
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (history.entries
                          .any((entry) => entry.reporting != null))
                        VisitHistoryFollowUpCard(
                          entries: history.entries,
                          open: _openReporting,
                        ),
                      VisitHistoryRemindersCard(
                        title: _Text.upcoming,
                        entries: upcoming,
                      ),
                      if (overdue.isNotEmpty)
                        VisitHistoryRemindersCard(
                          title: _Text.overdue,
                          entries: overdue,
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                            labelText: _Text.search,
                            prefixIcon: Icon(Icons.search)),
                        textInputAction: TextInputAction.search,
                        onChanged: (value) =>
                            setState(() => _query = value.trim().toLowerCase()),
                      ),
                      if (history.unreadable > 0)
                        const ListTile(title: Text(_Text.unreadable)),
                      if (history.entries.isEmpty)
                        const ListTile(title: Text(_Text.noVisits))
                      else if (matches.isEmpty)
                        const ListTile(title: Text(_Text.noResults)),
                      for (final entry in matches)
                        _VisitTile(
                          entry,
                          () => _openReporting(entry),
                          () => _openEmail(entry),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

  bool _matches(VisitHistoryEntry entry, String query) {
    final data = entry.certificate;
    return [
      data.klantNaam,
      data.klantVoornaam,
      data.klantAchternaam,
      data.klantBedrijf,
      _address(entry),
      _appliance(entry),
      data.toestelFabNummer,
      data.volgnummerAttest,
    ].join(' ').toLowerCase().contains(query);
  }
}

class _VisitTile extends StatelessWidget {
  final VisitHistoryEntry entry;
  final VoidCallback openReporting;
  final VoidCallback openEmail;
  const _VisitTile(this.entry, this.openReporting, this.openEmail);

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(_customer(entry)),
        subtitle: Text([
          entry.certificate.datumOnderhoud,
          _appliance(entry),
          _address(entry),
        ].where((line) => line.isNotEmpty).join('\n')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('visit_email_${entry.id}'),
              icon: const Icon(Icons.email_outlined),
              tooltip: EmailDeliveryDictionary.trackerDialogTitle,
              onPressed: openEmail,
            ),
            IconButton(
              key: ValueKey('visit_reporting_${entry.id}'),
              icon: const Icon(Icons.assignment_outlined),
              tooltip: _Text.reporting,
              onPressed: openReporting,
            ),
          ],
        ),
        onTap: () => PdfPreviewDialog.show(context, entry.certificate),
      );
}

String _customer(VisitHistoryEntry entry) {
  final d = entry.certificate;
  final n =
      [d.klantVoornaam, d.klantAchternaam].where((p) => p.isNotEmpty).join(' ');
  final l = [d.klantBedrijf, n].where((p) => p.isNotEmpty).join(' · ');
  return l.isEmpty ? _Text.customer : l;
}

String _appliance(VisitHistoryEntry entry) {
  final d = entry.certificate;
  final n = [d.toestelMerk, d.toestelType, d.toestelFabNummer]
      .where((p) => p.isNotEmpty)
      .join(' ');
  return n.isEmpty ? _Text.appliance : n;
}

String _address(VisitHistoryEntry entry) {
  final d = entry.certificate;
  return [
    d.locatieStraat,
    d.locatieNr,
    if (d.locatieBus.isNotEmpty) 'bus ${d.locatieBus}',
    d.locatiePostcode,
    d.locatieGemeente,
  ].where((p) => p.isNotEmpty).join(' ');
}
