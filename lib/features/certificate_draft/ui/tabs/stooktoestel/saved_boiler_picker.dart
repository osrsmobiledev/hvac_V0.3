import 'package:flutter/material.dart';

import '../../../../../app/localization/app_dictionary.dart';
import '../../../../../app/localization/saved_boiler_dictionary.dart';
import '../../../../../core/widgets/tactical_feedback.dart';
import '../../../data/saved_boiler_repository.dart';
import '../../../domain/boiler_draft.dart';
import '../../draft_save_scope.dart';

class SavedBoilerPicker extends StatefulWidget {
  final int visitId;
  final ValueChanged<BoilerDraft> onCopied;
  final SavedBoilerRepository? repository;
  const SavedBoilerPicker(
      {super.key,
      required this.visitId,
      required this.onCopied,
      this.repository});

  @override
  State<SavedBoilerPicker> createState() => _SavedBoilerPickerState();
}

class _SavedBoilerPickerState extends State<SavedBoilerPicker> {
  late final _repository = widget.repository ?? SavedBoilerRepository();
  bool _busy = false;

  Future<void> _open() async {
    if (_busy) return;
    final scope = DraftSaveScope.of(context);
    if (scope?.saves.any((save) => save.saveBlocked?.call() ?? false) ??
        false) {
      TacticalFeedback.showError(
          context, SavedBoilerDictionary.addressRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      await scope?.settle();
      final visitId = widget.visitId;
      final options = await _repository.listForVisit(visitId);
      if (!mounted || visitId != widget.visitId) return;
      final result = await showDialog<BoilerDraft>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PickerDialog(
          options: options,
          copy: (sourceId) =>
              _repository.copyToVisit(visitId, options, sourceId),
        ),
      );
      if (!mounted || result == null || visitId != widget.visitId) return;
      widget.onCopied(result);
      TacticalFeedback.showSuccess(context, SavedBoilerDictionary.done);
    } catch (error) {
      if (mounted) TacticalFeedback.showError(context, _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: _busy ? null : _open,
        icon: const Icon(Icons.history),
        label: const Text(SavedBoilerDictionary.open),
      );
}

class _PickerDialog extends StatefulWidget {
  final SavedBoilerOptions options;
  final Future<BoilerDraft> Function(int) copy;
  const _PickerDialog({required this.options, required this.copy});

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  SavedBoiler? _choice;
  String? _error;
  bool _saving = false;

  Future<void> _copy() async {
    if (_saving || _choice == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final draft = await widget.copy(_choice!.visitId);
      if (mounted) Navigator.pop(context, draft);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = _message(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: AlertDialog(
          scrollable: true,
          title: const Text(SavedBoilerDictionary.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.options.location.formattedAddress),
              if (widget.options.boilers.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(SavedBoilerDictionary.none)),
              for (final entry in widget.options.boilers)
                _BoilerOption(
                  entry: entry,
                  selected: _choice == entry,
                  onTap: _saving ? null : () => setState(() => _choice = entry),
                ),
              if (_choice != null) const Text(SavedBoilerDictionary.replace),
              if (_saving) const LinearProgressIndicator(),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: Text(_choice == null
                    ? SavedBoilerDictionary.manual
                    : AppDictionary.btnCancel)),
            if (widget.options.boilers.isNotEmpty)
              FilledButton(
                  onPressed: _saving || _choice == null ? null : _copy,
                  child: const Text(SavedBoilerDictionary.choose)),
          ],
        ),
      );
}

class _BoilerOption extends StatelessWidget {
  final SavedBoiler entry;
  final bool selected;
  final VoidCallback? onTap;
  const _BoilerOption(
      {required this.entry, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final draft = entry.boiler;
    final title = [draft.boilerBrand, draft.boilerModel]
        .where((part) => part.isNotEmpty)
        .join(' ');
    return ListTile(
      selected: selected,
      leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
      title: Text(title.isEmpty ? SavedBoilerDictionary.unknown : title),
      subtitle: Text([
        if (draft.boilerSerialNumber.isNotEmpty)
          SavedBoilerDictionary.serial(draft.boilerSerialNumber),
        SavedBoilerDictionary.lastVisit(entry.date),
      ].join('\n')),
      onTap: onTap,
    );
  }
}

String _message(Object error) => switch (error) {
      SavedBoilerException(:final problem) => switch (problem) {
          SavedBoilerProblem.addressRequired =>
            SavedBoilerDictionary.addressRequired,
          SavedBoilerProblem.draftChanged => SavedBoilerDictionary.changed,
          SavedBoilerProblem.visitStarted => SavedBoilerDictionary.visitStarted,
        },
      _ => SavedBoilerDictionary.failed,
    };
