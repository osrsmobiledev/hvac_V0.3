import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import '../../data/draft_repository.dart';
import '../widgets/bento_main_section.dart';
import '../widgets/dark_input_box.dart';
import 'start/activity_option_tile.dart';

/// Tab 2 (Start) form for Verbrandingsattest Vlaanderen.
/// Single-card layout under the gold-tinted 'Start' header with SQLite auto-save.
class StartTab extends StatefulWidget {
  final DraftRepository? draftRepository;

  const StartTab({super.key, this.draftRepository});

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
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repository = widget.draftRepository ?? DraftRepository();
    _loadDraft();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _attestNumberController.dispose();
    super.dispose();
  }

  /// Loads the active draft from SQLite into form state.
  Future<void> _loadDraft() async {
    try {
      final draft = await _repository.getOrCreateActiveDraft();
      if (mounted) {
        setState(() {
          _visitId = draft.id;
          _activityType = draft.activityType;
          _attestNumberController.text = draft.attestNumber;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Immediately persists the current Start tab state to the SQLite database.
  Future<void> _saveDraft() async {
    if (_visitId == null) return;
    await _repository.updateStartTabDraft(
      visitId: _visitId!,
      activityType: _activityType,
      attestNumber: _attestNumberController.text.trim(),
    );
  }

  void _onActivityChanged(String newType) {
    if (_activityType == newType) return;
    setState(() {
      _activityType = newType;
    });
    _saveDraft();
  }

  void _onAttestNumberChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _saveDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.amberGold),
      );
    }

    final cardBackground = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.03),
      const Color(0xFF141414),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const PageStorageKey<String>('start_tab_scroll'),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              // Standalone gold-tinted main dropdown header labeled 'Start'
              BentoMainSection(
                title: 'Start',
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.amberGoldBorder,
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: Type Activiteit
                      const Text(
                        'Type activiteit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ActivityOptionTile(
                        title: 'Onderhoud',
                        isSelected: _activityType == 'onderhoud',
                        onTap: () => _onActivityChanged('onderhoud'),
                      ),
                      const SizedBox(height: 10),
                      ActivityOptionTile(
                        title: 'Keuring voor eerste ingebruikname',
                        isSelected: _activityType == 'eerste_ingebruikname',
                        onTap: () => _onActivityChanged('eerste_ingebruikname'),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Volgnummer Attest
                      const Text(
                        'Volgnummer Attest:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _attestNumberController,
                        onChanged: _onAttestNumberChanged,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: AppColors.amberGold,
                        decoration: DarkInputBox.decoration(
                          hintText: 'bv. 2026-001',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
