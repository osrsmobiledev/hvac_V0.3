import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'tactical_binary_check.dart';

/// Tactical Bacharach soot index selector (0, 1, 2, >2) with automatic OK/Niet OK evaluation.
///
/// Features:
/// - Shares the exact slider chip aesthetic from Tab 5 (carbon dark styling, amber borders).
/// - Equal flex distribution so it never overflows on small mobile viewports.
/// - Togglable: tap an active option to unselect it and clear the check.
/// - Automatic regulatory compliance under Flemish VLAREM II:
///   - Roetindex 0 or 1 -> automatically marks OK (Green).
///   - Roetindex >2 -> automatically marks Niet OK (Red).
///   - Roetindex 2 -> records 2 (permissible on pre-1988 boilers).
class BacharachSelector extends StatelessWidget {
  final TextEditingController controller;
  final bool? isOk;
  final ValueChanged<bool?> onOkChanged;
  final VoidCallback onChanged;

  const BacharachSelector({
    super.key,
    required this.controller,
    required this.isOk,
    required this.onOkChanged,
    required this.onChanged,
  });

  static const List<String> _options = ['0', '1', '2', '>2'];

  void _select(String opt, bool isSelected) {
    HapticFeedback.selectionClick();
    if (isSelected) {
      controller.text = '';
      onOkChanged(null);
    } else {
      controller.text = opt;
      if (opt == '0' || opt == '1') {
        onOkChanged(true);
      } else if (opt == '>2') {
        onOkChanged(false);
      }
    }
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentVal = controller.text.trim();

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  for (int i = 0; i < _options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: _BacharachChip(
                        option: _options[i],
                        isSelected: currentVal == _options[i],
                        onTap: () => _select(
                          _options[i],
                          currentVal == _options[i],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 130,
              height: 32,
              child: TacticalBinaryCheck(
                value: isOk,
                onChanged: onOkChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BacharachChip extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const _BacharachChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFailed = option == '>2';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isFailed
                  ? Color.alphaBlend(
                      AppColors.terracotta.withValues(alpha: 0.18),
                      const Color(0xFF141414),
                    )
                  : Color.alphaBlend(
                      AppColors.antiqueGold.withValues(alpha: 0.12),
                      const Color(0xFF141414),
                    ))
              : const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isFailed
                    ? AppColors.terracottaBorder
                    : AppColors.amberGoldBorder)
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected
                ? (isFailed ? AppColors.terracotta : Colors.white)
                : AppColors.textSecondary,
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontFamily: AppTheme.fontFamily,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
