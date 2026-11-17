import 'package:flutter/material.dart';

import '../../../app/localization/veka_dictionary.dart';

typedef VekaConfirmation = ({
  String actor,
  String? reference,
  DateTime? submittedAt
});

class VekaConfirmationDialog extends StatefulWidget {
  final String address;
  const VekaConfirmationDialog({super.key, required this.address});

  @override
  State<VekaConfirmationDialog> createState() => _VekaConfirmationDialogState();
}

class _VekaConfirmationDialogState extends State<VekaConfirmationDialog> {
  final _actor = TextEditingController();
  final _reference = TextEditingController();
  final _date = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _actor.dispose();
    _reference.dispose();
    _date.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _date.text.trim();
    final date = DateTime.tryParse(text);
    final validDate = text.isEmpty ||
        date != null &&
            date.toIso8601String().substring(0, 16).replaceFirst('T', ' ') ==
                text &&
            !date.isAfter(DateTime.now());
    if (_actor.text.trim().isEmpty || !validDate) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context,
        (actor: _actor.text, reference: _reference.text, submittedAt: date));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(VekaDictionary.confirm),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.address),
            const SizedBox(height: 8),
            const Text(VekaDictionary.confirmQuestion),
            TextField(
                controller: _actor,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: VekaDictionary.actor)),
            TextField(
                controller: _reference,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: VekaDictionary.reference)),
            TextField(
                controller: _date,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                    labelText: VekaDictionary.submittedAt)),
            if (_invalid) const Text(VekaDictionary.invalidConfirmation),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(VekaDictionary.later)),
          FilledButton(
              onPressed: _confirm, child: const Text(VekaDictionary.confirm)),
        ],
      );
}
