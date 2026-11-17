import 'package:flutter/material.dart';

import '../../../app/localization/veka_dictionary.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/widgets/tactical_binary_check.dart';
import '../../certificate_draft/ui/draft_save_scope.dart';
import '../../certificate_draft/ui/boiler_draft_notifier.dart';
import '../data/veka_conformity_repository.dart';
import 'veka_attributes_section.dart';

class VekaAssessments extends StatefulWidget {
  final int visitId;
  final VekaConformityRepository? repository;
  final BoilerDraftNotifier? boiler;

  const VekaAssessments(
      {super.key, required this.visitId, this.repository, this.boiler});

  @override
  State<VekaAssessments> createState() => _VekaAssessmentsState();
}

class _VekaAssessmentsState extends State<VekaAssessments> {
  late final _repository = widget.repository ?? VekaConformityRepository();
  final _saves = Debouncer();
  Map<VekaConformity, String?>? _values;
  bool _loadFailed = false;
  Object? _fuel;

  @override
  void initState() {
    super.initState();
    widget.boiler?.addListener(_boilerChanged);
    _fuel = _fuelKey;
    _load();
  }

  Object? get _fuelKey {
    final boiler = widget.boiler?.draft;
    return boiler == null
        ? null
        : (boiler.isCentral, boiler.fuelCategory, boiler.fuelSubtype);
  }

  void _boilerChanged() {
    if (_fuel == _fuelKey) {
      setState(() {});
      return;
    }
    setState(() {
      _fuel = _fuelKey;
      _values = null;
      _loadFailed = false;
    });
    _load();
  }

  @override
  void didUpdateWidget(covariant VekaAssessments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boiler != widget.boiler) {
      oldWidget.boiler?.removeListener(_boilerChanged);
      widget.boiler?.addListener(_boilerChanged);
      _boilerChanged();
    }
  }

  Future<void> _load() async {
    final fuel = _fuel;
    try {
      await _saves.settle();
      await widget.boiler?.draftSaves.settle();
      final values = await _repository.load(widget.visitId);
      if (mounted && fuel == _fuel) setState(() => _values = values);
    } catch (_) {
      if (mounted && fuel == _fuel) setState(() => _loadFailed = true);
    }
  }

  void _apply(VekaConformity field, bool? checked) {
    final value =
        switch (checked) { true => 'OK', false => 'NOK', null => null };
    final values = {..._values!, field: value};
    setState(() => _values = values);
    final visitId = widget.visitId;
    _saves.runNow(() => _repository.save(visitId, values));
  }

  @override
  void dispose() {
    widget.boiler?.removeListener(_boilerChanged);
    _saves.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DraftSaveScope.of(context)?.register(_saves);
    final boiler = widget.boiler?.draft;
    if (boiler != null &&
        (!boiler.isCentral ||
            !(boiler.fuelCategory == 'vloeibaar' ||
                boiler.fuelCategory == 'gas' &&
                    boiler.fuelSubtype == 'aardgas'))) {
      return const SizedBox.shrink();
    }
    if (_loadFailed) {
      return TextButton(
        onPressed: () {
          setState(() => _loadFailed = false);
          _load();
        },
        child: const Text(VekaDictionary.retryConformity),
      );
    }
    final values = _values;
    if (values == null) return const LinearProgressIndicator();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (boiler != null) ...[
          VekaAttributesSection(
            heatingType: boiler.heatingType,
            boilerOperation: boiler.boilerOperation,
            onHeatingTypeChanged: (value) => widget.boiler!.updateDraft(
                widget.boiler!.draft.copyWith(heatingType: value),
                immediateSave: true),
            onBoilerOperationChanged: (value) => widget.boiler!.updateDraft(
                widget.boiler!.draft.copyWith(boilerOperation: value),
                immediateSave: true),
          ),
          const Divider(height: 32, thickness: 1),
        ],
        Text(VekaDictionary.assessments,
            style: Theme.of(context).textTheme.titleSmall),
        for (final (field, label) in const [
          (VekaConformity.appliance, VekaDictionary.appliance),
          (VekaConformity.flue, VekaDictionary.flue),
          (VekaConformity.room, VekaDictionary.room),
        ]) ...[
          const SizedBox(height: 10),
          Text(label),
          TacticalBinaryCheck(
            value: switch (values[field]) {
              'OK' => true,
              'NOK' => false,
              _ => null
            },
            onChanged: (value) => _apply(field, value),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }
}
