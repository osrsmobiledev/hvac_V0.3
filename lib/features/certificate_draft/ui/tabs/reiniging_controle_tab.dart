import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/reiniging_dictionary.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../boiler_draft_notifier.dart';
import '../draft_save_scope.dart';
import '../../data/reiniging_repository.dart';
import '../../domain/reiniging_controls_draft.dart';
import 'reiniging/reiniging_boiler_card.dart';
import 'reiniging/reiniging_flue_card.dart';

/// Tab 5: Reiniging en controle (14 cleaning/control checkboxes + conditional text).
class ReinigingControleTab extends StatefulWidget {
  final int visitId;
  final ReinigingRepository? repository;
  final BoilerDraftNotifier? boilerNotifier;
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const ReinigingControleTab({
    super.key,
    this.visitId = 1,
    this.repository,
    this.boilerNotifier,
    this.onFormKeyReady,
  });

  @override
  State<ReinigingControleTab> createState() => _ReinigingControleTabState();
}

class _ReinigingControleTabState extends State<ReinigingControleTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _checklistFieldKey = GlobalKey<FormFieldState<bool>>();
  late final ReinigingRepository _repository;
  final _debouncer = Debouncer();
  final _otherTextController = TextEditingController();
  final _otherTextFocusNode = FocusNode();

  ReinigingControlsDraft _draft = const ReinigingControlsDraft();
  String _fuelCategory = '';
  int _loadGeneration = 0;
  bool _hasUserEdited = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReinigingRepository();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onFormKeyReady?.call(_formKey));
    widget.boilerNotifier?.addListener(_onBoilerChanged);
    _fuelCategory = widget.boilerNotifier?.draft.fuelCategory ?? '';
    _loadControls();
  }

  @override
  void didUpdateWidget(covariant ReinigingControleTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boilerNotifier != widget.boilerNotifier) {
      oldWidget.boilerNotifier?.removeListener(_onBoilerChanged);
      widget.boilerNotifier?.addListener(_onBoilerChanged);
      _fuelCategory = widget.boilerNotifier?.draft.fuelCategory ?? '';
    }
    if (oldWidget.visitId != widget.visitId) {
      _hasUserEdited = false;
      _checklistFieldKey.currentState?.reset();
      _loadControls();
    }
  }

  @override
  void dispose() {
    widget.boilerNotifier?.removeListener(_onBoilerChanged);
    _debouncer.dispose();
    _otherTextController.dispose();
    _otherTextFocusNode.dispose();
    super.dispose();
  }

  void _onBoilerChanged() {
    final nextFuel = widget.boilerNotifier?.draft.fuelCategory ?? '';
    if (!mounted || nextFuel == _fuelCategory) return;
    final pruned = _draft.clearingInactiveFuels(nextFuel);
    final changed = pruned != _draft;
    setState(() {
      _fuelCategory = nextFuel;
      if (changed) _draft = pruned;
    });
    if (changed) {
      if (_checklistFieldKey.currentState?.hasError == true) {
        _checklistFieldKey.currentState?.validate();
      }
      _queueSave(pruned, immediate: true);
    }
  }

  Future<void> _loadControls() async {
    final gen = ++_loadGeneration;
    try {
      final loaded = await _repository.loadControls(widget.visitId);
      if (!mounted || gen != _loadGeneration || _hasUserEdited) return;
      setState(() {
        _draft = loaded;
        _otherTextController.text = loaded.allOtherText ?? '';
      });
    } catch (e, stack) {
      debugPrint('[ReinigingControleTab] _loadControls error: $e\n$stack');
    }
  }

  void _onChecklistChanged(ReinigingControlsDraft next) {
    _hasUserEdited = true;
    final wasOtherChecked = _draft.allOtherChecked;
    final isNowOtherChecked = next.allOtherChecked;

    if (wasOtherChecked && !isNowOtherChecked) {
      _otherTextController.clear();
      FocusScope.of(context).unfocus();
      next = next.copyWith(allOtherChecked: false, allOtherText: null);
    } else if (isNowOtherChecked) {
      next = next.copyWith(allOtherText: _otherTextController.text);
    }

    setState(() => _draft = next);
    if (_checklistFieldKey.currentState?.hasError == true) {
      _checklistFieldKey.currentState?.validate();
    }
    _queueSave(next, immediate: true);
  }

  void _onOtherTextChanged() {
    _hasUserEdited = true;
    final next = _draft.copyWith(allOtherText: _otherTextController.text);
    _draft = next;
    _queueSave(next, immediate: false);
  }

  void _queueSave(ReinigingControlsDraft snapshot, {required bool immediate}) {
    final visitId = widget.visitId;
    Future<void> save() =>
        _repository.saveControls(visitId: visitId, draft: snapshot);
    if (immediate) {
      _debouncer.runNow(save);
    } else {
      _debouncer.run(save);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    DraftSaveScope.of(context)?.register(_debouncer);
    return Form(
      key: _formKey,
      child: WorkflowTabContainer(
        scrollKey: 'reiniging_controle_tab_${widget.visitId}',
        children: [
          FormField<bool>(
            key: _checklistFieldKey,
            initialValue: _draft.hasAnySelected,
            validator: (_) => _draft.hasAnySelected
                ? null
                : ReinigingDictionary.errSelectAtLeastOne,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReinigingFlueCard(
                  draft: _draft,
                  hasSelectionError: field.hasError,
                  onChanged: _onChecklistChanged,
                ),
                const SizedBox(height: AppTheme.bentoCardSpacing),
                ReinigingBoilerCard(
                  draft: _draft,
                  fuelCategory: _fuelCategory,
                  hasSelectionError: field.hasError,
                  otherTextController: _otherTextController,
                  otherTextFocusNode: _otherTextFocusNode,
                  onChanged: _onChecklistChanged,
                  onOtherTextChanged: _onOtherTextChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
