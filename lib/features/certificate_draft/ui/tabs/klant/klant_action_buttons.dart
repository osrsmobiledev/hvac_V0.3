import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_squircle_box.dart';

/// Top tactical action buttons bar on Tab 4 (Klant).
///
/// Implements the 4-button state-warping layout from preferred theme:
/// 1. [Zoeken] — Opens customer search directory (disabled while editing).
/// 2. [Nieuw] — Initiates new customer creation flow (disabled while editing).
/// 3. [Bewerken / Opslaan] — Warps dynamically:
///    - When viewing: 'Bewerken' (pencil, active only if customer exists).
///    - When editing: 'Opslaan' (floppy disk, vibrant green highlight).
/// 4. [Wissen / Annuleren] — Warps dynamically:
///    - When viewing: 'Wissen' (trash, red accent, active only if customer exists).
///    - When editing: 'Annuleren' (undo arrow, amber gold accent).
class KlantActionButtons extends StatelessWidget {
  final bool isEditing;
  final bool hasCustomer;
  final VoidCallback onSearch;
  final VoidCallback onNew;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const KlantActionButtons({
    super.key,
    required this.isEditing,
    required this.hasCustomer,
    required this.onSearch,
    required this.onNew,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 1) Zoeken
          Expanded(
            child: _ActionItem(
              icon: Icons.format_list_bulleted_rounded,
              label: AppDictionary.btnSearch,
              isEnabled: !isEditing,
              accentColor: AppColors.antiqueGold,
              borderColor: AppColors.amberGoldBorder,
              onTap: onSearch,
            ),
          ),

          // 2) Nieuw
          Expanded(
            child: _ActionItem(
              icon: Icons.add_rounded,
              label: AppDictionary.btnNew,
              isEnabled: !isEditing,
              accentColor: AppColors.antiqueGold,
              borderColor: AppColors.amberGoldBorder,
              onTap: onNew,
            ),
          ),

          // 3) Opslaan / Bewerken (warps sequentially depending on isEditing)
          Expanded(
            child: _WarpingActionSlot(
              child: isEditing
                  ? _ActionItem(
                      key: const ValueKey('btn_save'),
                      icon: Icons.save_rounded,
                      label: AppDictionary.btnSave,
                      isEnabled: true,
                      accentColor: const Color(0xFF26A69A),
                      borderColor: const Color(0xFF00796B),
                      onTap: onSave,
                    )
                  : _ActionItem(
                      key: const ValueKey('btn_edit'),
                      icon: Icons.edit_rounded,
                      label: AppDictionary.btnEdit,
                      isEnabled: hasCustomer,
                      accentColor: AppColors.antiqueGold,
                      borderColor: AppColors.amberGoldBorder,
                      onTap: onEdit,
                    ),
            ),
          ),

          // 4) Annuleren / Wissen (warps sequentially depending on isEditing)
          Expanded(
            child: _WarpingActionSlot(
              child: isEditing
                  ? _ActionItem(
                      key: const ValueKey('btn_cancel'),
                      icon: Icons.undo_rounded,
                      label: AppDictionary.btnCancel,
                      isEnabled: true,
                      accentColor: AppColors.antiqueGold,
                      borderColor: AppColors.amberGoldBorder,
                      onTap: onCancel,
                    )
                  : _ActionItem(
                      key: const ValueKey('btn_delete'),
                      icon: Icons.delete_outline_rounded,
                      label: AppDictionary.btnDelete,
                      isEnabled: hasCustomer,
                      accentColor: AppColors.destructiveRed,
                      borderColor:
                          AppColors.destructiveRed.withValues(alpha: 0.65),
                      onTap: onDelete,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated switcher slot creating a sequential shrink-then-grow warp transition
/// while anchoring fixed layout coordinates so neighboring buttons never shift.
class _WarpingActionSlot extends StatelessWidget {
  final Widget child;

  const _WarpingActionSlot({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        // Interval ensures the outgoing button shrinks down completely to 0
        // in the first half, then the incoming button grows up from 0 to 1 in the second half.
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.40, 1.0, curve: Curves.easeInOutCubic),
        );

        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final Color accentColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.accentColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? accentColor.withValues(alpha: 0.65);
    final textColor = isEnabled ? Colors.white70 : Colors.white24;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TacticalSquircleBox(
            width: 58,
            height: 54,
            icon: icon,
            accentColor: accentColor,
            borderColor: effectiveBorder,
            borderRadius: 16,
            iconSize: 24,
            borderWidth: 1.2,
            isEnabled: isEnabled,
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
