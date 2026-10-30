import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/meting_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'main_slot_tab.dart';
import 'proef2_modulation_badge.dart';
import 'slot_action_buttons.dart';

/// 2-Tier official statutory measurement slot selector for Tab 6 (Meting).
///
/// Features:
/// - Left-aligned Tier 1 test slots: Proef I (Initiële meting) vs. Proef II (Eindmeting)
/// - Proef II shows the active modulation mode badge (Laaglast/Hooglast) directly
///   next to the title, leaving the full subtitle width for "Eindmeting" without clipping.
/// - Dropdown chevron expands the modulation sub-tier only when needed.
/// - Tactical Quick-Action Ribbon: 1-tap import from Tab 1, QR camera, and reset.
class MeasurementSlotSelector extends StatefulWidget {
  final String activeSlot;
  final ValueChanged<String> onSlotChanged;
  final VoidCallback onCopyFromDataTab;
  final VoidCallback onScanEurolyzer;
  final VoidCallback onClearSlot;
  final bool canClear;
  final bool proef1HasData;
  final bool proef2HasData;
  final bool proef2LaagHasData;
  final bool proef2HoogHasData;

  const MeasurementSlotSelector({
    super.key,
    required this.activeSlot,
    required this.onSlotChanged,
    required this.onCopyFromDataTab,
    required this.onScanEurolyzer,
    required this.onClearSlot,
    this.canClear = true,
    this.proef1HasData = false,
    this.proef2HasData = false,
    this.proef2LaagHasData = false,
    this.proef2HoogHasData = false,
  });

  @override
  State<MeasurementSlotSelector> createState() =>
      _MeasurementSlotSelectorState();
}

class _MeasurementSlotSelectorState extends State<MeasurementSlotSelector> {
  bool _isSubMenuExpanded = false;

  @override
  void didUpdateWidget(covariant MeasurementSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSlot == 'proef1' && _isSubMenuExpanded) {
      _isSubMenuExpanded = false;
    }
  }

  void _onProef1Tap() {
    if (_isSubMenuExpanded) {
      setState(() => _isSubMenuExpanded = false);
    }
    widget.onSlotChanged('proef1');
  }

  void _onProef2Tap() {
    final bool isCurrentlyProef2 = widget.activeSlot.startsWith('proef2');
    if (isCurrentlyProef2) {
      // Toggle dropdown open/close when tapping while already on Proef II
      setState(() => _isSubMenuExpanded = !_isSubMenuExpanded);
    } else {
      // First switch to Proef II: activate Laaglast by default, keep sub-menu compact
      setState(() => _isSubMenuExpanded = false);
      widget.onSlotChanged(
        widget.activeSlot == 'proef2_hooglast'
            ? 'proef2_hooglast'
            : 'proef2_laaglast',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isProef1 = widget.activeSlot == 'proef1';
    final bool isProef2 = widget.activeSlot.startsWith('proef2');
    final bool isLaaglast = widget.activeSlot == 'proef2_laaglast';

    final Widget modeBadge = Proef2ModulationBadge(
      isLaaglast: isLaaglast,
      isSubMenuExpanded: _isSubMenuExpanded,
      hasLaagData: widget.proef2LaagHasData,
      hasHoogData: widget.proef2HoogHasData,
      isSelected: isProef2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Tier 1: Left-aligned Test Segments (Proef I vs Proef II) ---
        Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              MainSlotTab(
                title: MetingDictionary.slotProef1,
                subtitle: MetingDictionary.slotProef1Sub,
                isSelected: isProef1,
                onTap: _onProef1Tap,
                hasData: widget.proef1HasData,
              ),
              const SizedBox(width: 4),
              MainSlotTab(
                title: MetingDictionary.slotProef2,
                subtitle: MetingDictionary.slotProef2Sub,
                isSelected: isProef2,
                onTap: _onProef2Tap,
                badge: modeBadge,
                hasData: false,
              ),
            ],
          ),
        ),

        // --- Tier 2: Collapsible Modulation Sub-Toggle (Laaglast vs Hooglast) ---
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          child: isProef2 && _isSubMenuExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppColors.amberGold.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        SubSlotTab(
                          label: MetingDictionary.subSlotLaaglast,
                          badge: MetingDictionary.subSlotLaaglastBadge,
                          isSelected: isLaaglast,
                          hasData: widget.proef2LaagHasData,
                          onTap: () {
                            widget.onSlotChanged('proef2_laaglast');
                            setState(() => _isSubMenuExpanded = false);
                          },
                        ),
                        const SizedBox(width: 4),
                        SubSlotTab(
                          label: MetingDictionary.subSlotHooglast,
                          badge: MetingDictionary.subSlotHooglastBadge,
                          isSelected: !isLaaglast,
                          hasData: widget.proef2HoogHasData,
                          onTap: () {
                            widget.onSlotChanged('proef2_hooglast');
                            setState(() => _isSubMenuExpanded = false);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 10),

        // --- Action Buttons Ribbon ---
        Row(
          children: [
            Expanded(
              child: SlotActionButton(
                icon: Icons.download_rounded,
                label: MetingDictionary.btnCopyFromDataTab,
                accentColor: AppColors.amberGold,
                onTap: widget.onCopyFromDataTab,
              ),
            ),
            const SizedBox(width: 8),
            TacticalSquareButton(
              icon: Icons.qr_code_scanner_rounded,
              tooltip: MetingDictionary.btnScanEurolyzer,
              accentColor: AppColors.amberGold,
              size: 38.0,
              iconSize: 18.0,
              onPressed: widget.onScanEurolyzer,
            ),
            const SizedBox(width: 8),
            TacticalSquareButton(
              icon: Icons.delete_outline_rounded,
              tooltip: MetingDictionary.btnClearSlot,
              accentColor: const Color(0xFFEF5350),
              size: 38.0,
              iconSize: 18.0,
              onPressed: widget.canClear ? widget.onClearSlot : null,
            ),
          ],
        ),
      ],
    );
  }
}
