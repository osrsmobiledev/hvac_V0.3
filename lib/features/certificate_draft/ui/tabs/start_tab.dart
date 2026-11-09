import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/core/services/app_warmup_service.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../../data/draft_repository.dart';
import '../widgets/bento_main_section.dart';
import '../widgets/dark_text_form_field.dart';
import 'start/activity_option_tile.dart';

/// Tab 2 (Start) form for Verbrandingsattest Vlaanderen.
///
/// Features:
/// - Reusable tactical activity selection buttons with zero-jump red border validation.
/// - Attest sequence number tracking with live auto-save to SQLite and red border validation.
/// - Exposes [onFormKeyReady] so the parent screen can call [FormState.validate]
///   on "Voltooien" without any database round-trip.
class StartTab extends StatefulWidget {
  final int? visitId;
  final DraftRepository? draftRepository;

  /// Called once after first build with this tab's [GlobalKey<FormState>].
  final ValueChanged<GlobalKey<FormState>>? onFormKeyReady;

  const StartTab({
    super.key,
    this.visitId,
    this.draftRepository,
    this.onFormKeyReady,
  });

  @override
  State<StartTab> createState() => _StartTabState();
}

class _StartTabState extends State<StartTab>
    with AutomaticKeepAliveClientMixin {
  late final DraftRepository _repository;
  final TextEditingController _attestNumberController = TextEditingController();

  /// Form key — exposed to parent via [StartTab.onFormKeyReady] so "Voltooien"
  /// can validate Tab 2 fields without any database round-trip.
  final _formKey = GlobalKey<FormState>();

  int? _visitId;
  String _activityType = '';
  final _debouncer = Debouncer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.draftRepository ?? DraftRepository();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFormKeyReady?.call(_formKey),
    );
    final cachedDraft = AppWarmupService.instance.cachedResult?.activeDraft;
    if (cachedDraft != null && widget.draftRepository == null) {
      _visitId = cachedDraft.id;
      _activityType = cachedDraft.activityType;
      _attestNumberController.text = cachedDraft.attestNumber;
    } else {
      _loadDraft();
    }
  }

  @override
  void didUpdateWidget(StartTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitId != widget.visitId) {
      _loadDraft();
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _attestNumberController.dispose();
    super.dispose();
  }

  /// Loads the active draft from SQLite into form state.
  Future<void> _loadDraft() async {
    try {
      final draft = widget.visitId != null
          ? await _repository.getDraftById(widget.visitId!) ??
              await _repository.getOrCreateActiveDraft()
          : await _repository.getOrCreateActiveDraft();
      if (mounted) {
        setState(() {
          _visitId = draft.id;
          _activityType = draft.activityType;
          _attestNumberController.text = draft.attestNumber;
        });
      }
    } catch (e, stack) {
      debugPrint('[StartTab] _loadDraft error: $e\n$stack');
    }
  }

  /// Immediately persists the current Start tab state to the SQLite database.
  Future<void> _saveDraft() async {
    if (_visitId == null) return;
    try {
      await _repository.updateStartTabDraft(
        visitId: _visitId!,
        activityType: _activityType,
        attestNumber: _attestNumberController.text.trim(),
      );
    } catch (e, stack) {
      debugPrint('[StartTab] _saveDraft error: $e\n$stack');
    }
  }

  void _onActivityChanged(String newType) {
    setState(() {
      if (_activityType == newType) {
        _activityType = ''; // De-selects when tapped again
      } else {
        _activityType = newType;
      }
    });
    _saveDraft();
  }

  void _onAttestNumberChanged(String value) {
    _debouncer.run(_saveDraft);
  }

  void _onAttestNumberSubmitted(String value) {
    _debouncer.flush();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: _formKey,
      child: WorkflowTabContainer(
        scrollKey: 'start_tab_scroll',
        children: [
          BentoMainSection(
            title: AppDictionary.headerActivity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Activity selection with zero-jump red border validation
                FormField<String>(
                  key: const ValueKey('start_activity_field'),
                  initialValue: _activityType,
                  validator: (_) => _activityType.isEmpty
                      ? 'Kies een activiteitstype (Onderhoud of Eerste ingebruikname)'
                      : null,
                  builder: (field) {
                    final isError = field.hasError && _activityType.isEmpty;

                    return Row(
                      children: [
                        Expanded(
                          child: ActivityOptionTile(
                            title: AppDictionary.activityMaintenance,
                            isSelected: _activityType == 'onderhoud',
                            isError: isError,
                            onTap: () {
                              _onActivityChanged('onderhoud');
                              field.didChange(_activityType);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ActivityOptionTile(
                            title: AppDictionary.activityCommissioningShort,
                            subtitle: AppDictionary.captionCommissioning,
                            isSelected: _activityType == 'eerste_ingebruikname',
                            isError: isError,
                            onTap: () {
                              _onActivityChanged('eerste_ingebruikname');
                              field.didChange(_activityType);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 14),

                // Section 2: Volgnummer Attest (required)
                DarkTextFormField(
                  fieldKey: const ValueKey('start_attestNumber'),
                  label: AppDictionary.lblSequenceNumber,
                  controller: _attestNumberController,
                  hint: AppDictionary.hintSequenceNumber,
                  prefixText: '#',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => v!.trim().isEmpty
                      ? 'Volgnummer attest is verplicht'
                      : null,
                  onChanged: () =>
                      _onAttestNumberChanged(_attestNumberController.text),
                  onSubmitted: _onAttestNumberSubmitted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
