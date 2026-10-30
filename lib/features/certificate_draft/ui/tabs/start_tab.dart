import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/debouncer.dart';
import 'package:hvac_app/core/widgets/workflow_tab_container.dart';
import '../../data/draft_repository.dart';
import '../widgets/bento_main_section.dart';
import '../widgets/dark_input_box.dart';
import '../widgets/dark_input_label.dart';
import 'start/activity_option_tile.dart';

/// Tab 2 (Start) form for Verbrandingsattest Vlaanderen.
///
/// Features:
/// - Clean activity selection under the 'Activiteit' Bento section.
/// - Attest sequence number tracking with live auto-save to SQLite.
class StartTab extends StatefulWidget {
  final int? visitId;
  final DraftRepository? draftRepository;

  const StartTab({
    super.key,
    this.visitId,
    this.draftRepository,
  });

  @override
  State<StartTab> createState() => _StartTabState();
}

class _StartTabState extends State<StartTab>
    with AutomaticKeepAliveClientMixin {
  late final DraftRepository _repository;
  final TextEditingController _attestNumberController = TextEditingController();

  int? _visitId;
  String _activityType = 'onderhoud';
  bool _isLoading = true;
  final _debouncer = Debouncer();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.draftRepository ?? DraftRepository();
    _loadDraft();
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
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('[StartTab] _loadDraft error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
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

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }

    return WorkflowTabContainer(
      scrollKey: 'start_tab_scroll',
      children: [
        // Standalone gold-tinted main dropdown header labeled 'Activiteit'
        BentoMainSection(
          title: AppDictionary.headerActivity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Side-by-side activity selector buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ActivityOptionTile(
                      title: AppDictionary.activityMaintenance,
                      isSelected: _activityType == 'onderhoud',
                      onTap: () => _onActivityChanged('onderhoud'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ActivityOptionTile(
                          title: AppDictionary.activityCommissioningShort,
                          isSelected: _activityType == 'eerste_ingebruikname',
                          onTap: () =>
                              _onActivityChanged('eerste_ingebruikname'),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () =>
                              _onActivityChanged('eerste_ingebruikname'),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppDictionary.captionCommissioning,
                              maxLines: 1,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 14),

              // Section 2: Volgnummer Attest
              const DarkInputLabel(AppDictionary.lblSequenceNumber),
              TextField(
                controller: _attestNumberController,
                onChanged: _onAttestNumberChanged,
                onSubmitted: _onAttestNumberSubmitted,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: DarkInputBox.inputStyle,
                cursorColor: AppColors.amberGoldBorder,
                decoration: DarkInputBox.decoration(
                  hintText: AppDictionary.hintSequenceNumber,
                  prefixText: '#',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
