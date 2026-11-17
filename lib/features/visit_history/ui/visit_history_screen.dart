import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/localization/visit_history_dictionary.dart' as labels;
import '../../pdf_export/ui/pdf_preview_dialog.dart';
import '../../reporting_delivery/ui/veka_tracker.dart';
import '../data/visit_history_repository.dart';
import 'visit_history_follow_up_card.dart';

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
                      _Reminders(_Text.upcoming, upcoming),
                      if (overdue.isNotEmpty)
                        _Reminders(_Text.overdue, overdue),
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
                        _VisitTile(entry, () => _openReporting(entry)),
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

class _Reminders extends StatelessWidget {
  final String title;
  final List<VisitHistoryEntry> entries;
  const _Reminders(this.title, this.entries);

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(title),
                trailing: Text('${entries.length}')),
            if (entries.isEmpty) const ListTile(title: Text(_Text.noReminders)),
            for (final entry in entries)
              ListTile(
                title: Text(_customer(entry)),
                subtitle: Text(
                    '${_dateLabel(context, entry.due!)} · ${_address(entry)}'),
                trailing: IconButton(
                  tooltip: _Text.reminder,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _share(context, entry),
                ),
                onTap: () => PdfPreviewDialog.show(context, entry.certificate),
              ),
          ],
        ),
      );

  Future<void> _share(BuildContext context, VisitHistoryEntry entry) async {
    final message =
        _Text.message(_address(entry), _dateLabel(context, entry.due!));
    try {
      await const MethodChannel('com.example.hvac_app/reminders')
          .invokeMethod<void>('share', message);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(_Text.shareFailed)));
      }
    }
  }
}

class _VisitTile extends StatelessWidget {
  final VisitHistoryEntry entry;
  final VoidCallback openReporting;
  const _VisitTile(this.entry, this.openReporting);

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(_customer(entry)),
        subtitle: Text([
          entry.certificate.datumOnderhoud,
          _appliance(entry),
          _address(entry),
        ].where((line) => line.isNotEmpty).join('\n')),
        trailing: IconButton(
          icon: const Icon(Icons.assignment_outlined),
          tooltip: _Text.reporting,
          onPressed: openReporting,
        ),
        onTap: () => PdfPreviewDialog.show(context, entry.certificate),
      );
}

String _customer(VisitHistoryEntry entry) {
  final data = entry.certificate;
  final name = [data.klantVoornaam, data.klantAchternaam]
      .where((part) => part.isNotEmpty)
      .join(' ');
  final label =
      [data.klantBedrijf, name].where((part) => part.isNotEmpty).join(' · ');
  return label.isEmpty ? _Text.customer : label;
}

String _appliance(VisitHistoryEntry entry) {
  final data = entry.certificate;
  final name = [data.toestelMerk, data.toestelType, data.toestelFabNummer]
      .where((part) => part.isNotEmpty)
      .join(' ');
  return name.isEmpty ? _Text.appliance : name;
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

String _dateLabel(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatShortDate(date);
