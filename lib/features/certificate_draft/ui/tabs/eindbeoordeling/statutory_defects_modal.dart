// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/statutory_defects_modal.dart
// Responsibility: Tactical dark modal bottom sheet for multi-selecting statutory defects and linked remedies.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';
import 'package:hvac_app/features/certificate_draft/domain/statutory_defect_preset.dart';
import 'statutory_category_ribbon.dart';
import 'statutory_defect_tile.dart';

class StatutoryDefectsModal extends StatefulWidget {
  final String fuelType;
  final String boilerType;
  final ValueChanged<List<StatutoryDefectPreset>> onApply;
  final String existingDefects;
  final String existingRemarks;
  final int maxChars;

  const StatutoryDefectsModal({
    super.key,
    required this.fuelType,
    required this.boilerType,
    required this.onApply,
    this.existingDefects = '',
    this.existingRemarks = '',
    this.maxChars = 200,
  });

  static Future<void> show({
    required BuildContext context,
    required String fuelType,
    required String boilerType,
    required ValueChanged<List<StatutoryDefectPreset>> onApply,
    String existingDefects = '',
    String existingRemarks = '',
    int maxChars = 200,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => StatutoryDefectsModal(
          fuelType: fuelType,
          boilerType: boilerType,
          onApply: onApply,
          existingDefects: existingDefects,
          existingRemarks: existingRemarks,
          maxChars: maxChars,
        ),
      );

  @override
  State<StatutoryDefectsModal> createState() => _StatutoryDefectsModalState();
}

class _StatutoryDefectsModalState extends State<StatutoryDefectsModal> {
  final Set<String> _selectedIds = {};
  String _activeCategory = 'all';

  void _togglePreset(String id) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id));
  }

  void _handleApply(List<StatutoryDefectPreset> allMatching) {
    final selected = allMatching.where((p) => _selectedIds.contains(p.id)).toList();
    widget.onApply(selected);
    Navigator.of(context).pop();
  }

  bool _isAlreadyAdded(StatutoryDefectPreset preset) {
    final d = widget.existingDefects.toLowerCase();
    final r = widget.existingRemarks.toLowerCase();
    return d.contains(preset.defectText.toLowerCase()) || r.contains(preset.measureText.toLowerCase());
  }

  int _calculateProjectedLen(
    String base,
    List<StatutoryDefectPreset> presets,
    String Function(StatutoryDefectPreset) sel,
  ) {
    if (presets.isEmpty) return base.trim().length;
    final b = StringBuffer(base.trim());
    for (final p in presets) {
      if (b.isNotEmpty) b.write('\n');
      b.write('• ${sel(p)}');
    }
    return b.length;
  }

  bool _wouldExceedLimit(StatutoryDefectPreset preset, List<StatutoryDefectPreset> allMatching) {
    final list = [...allMatching.where((p) => _selectedIds.contains(p.id)), preset];
    final d = _calculateProjectedLen(widget.existingDefects, list, (p) => p.defectText);
    final r = _calculateProjectedLen(widget.existingRemarks, list, (p) => p.measureText);
    return d > widget.maxChars || r > widget.maxChars;
  }

  @override
  Widget build(BuildContext context) {
    final matchingPresets = StatutoryDefectPreset.filter(
      fuel: widget.fuelType,
      boilerType: widget.boilerType,
      categoryFilter: _activeCategory,
    );
    final allMatching = StatutoryDefectPreset.filter(
      fuel: widget.fuelType,
      boilerType: widget.boilerType,
    );
    final selectedPresets =
        allMatching.where((p) => _selectedIds.contains(p.id)).toList();
    final currentDefectsLen = _calculateProjectedLen(
      widget.existingDefects,
      selectedPresets,
      (p) => p.defectText,
    );
    final remainingChars =
        (widget.maxChars - currentDefectsLen).clamp(0, widget.maxChars);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.goldHairline, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          StatutoryDefectHeader(
            fuel: widget.fuelType,
            boilerType: widget.boilerType,
            onClose: () => Navigator.of(context).pop(),
            remainingChars: remainingChars,
          ),
          const Divider(height: 1, color: AppColors.goldHairline),

          // Category filter ribbon
          StatutoryCategoryRibbon(
            activeCategory: _activeCategory,
            onCategorySelected: (cat) => setState(() => _activeCategory = cat),
          ),

          // Presets list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: matchingPresets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final preset = matchingPresets[index];
                final isSelected = _selectedIds.contains(preset.id);
                final isAlreadyAdded = _isAlreadyAdded(preset);
                final isOverLimit = !isSelected &&
                    !isAlreadyAdded &&
                    _wouldExceedLimit(preset, allMatching);

                return StatutoryDefectPresetCard(
                  preset: preset,
                  isSelected: isSelected,
                  isAlreadyAdded: isAlreadyAdded,
                  isOverLimit: isOverLimit,
                  onTap: () => _togglePreset(preset.id),
                );
              },
            ),
          ),

          // Sticky bottom action bar
          _BottomActionBar(
            selectedCount: _selectedIds.length,
            onApply: () => _handleApply(allMatching),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onApply;
  final VoidCallback onCancel;

  const _BottomActionBar({
    required this.selectedCount,
    required this.onApply,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: AppColors.goldHairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TacticalDialogButton.secondary(
              label: 'Annuleren',
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TacticalDialogButton.primary(
              label: selectedCount > 0
                  ? '${EindbeoordelingDictionary.btnToepassen} ($selectedCount)'
                  : EindbeoordelingDictionary.btnToepassen,
              onPressed: selectedCount > 0 ? onApply : null,
            ),
          ),
        ],
      ),
    );
  }
}
