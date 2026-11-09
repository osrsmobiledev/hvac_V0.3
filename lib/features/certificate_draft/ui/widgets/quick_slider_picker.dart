import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable horizontal slider ribbon picker for fast 1-tap value selection.
///
/// Features:
/// - Horizontal gliding scroll ribbon with natural bouncing physics.
/// - Auto-glides the selected number smoothly to the center of the ribbon.
/// - Scopes scrolling STRICTLY to its own dedicated [ScrollController] to avoid
///   bubbling up and scrolling ancestor views or switching tabs in TabBarView.
/// - Starts centered on the smart recommended preset for the boiler type.
/// - Fixed-geometry chip layout: font weight & border width stay constant to prevent
///   annoying layout expansion/shifting when items are selected.
/// - Togglable tap behavior: tap to select, tap again to unselect (clears value).
/// - Haptic feedback on selection.
class QuickSliderPicker extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final List<String> options;
  final String suffix;
  final String? preferredInitialItem;

  const QuickSliderPicker({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
    this.suffix = '',
    this.preferredInitialItem,
  });

  /// Convenience factory that binds directly to a [TextEditingController].
  static Widget forController({
    Key? key,
    required TextEditingController controller,
    required List<String> options,
    required VoidCallback onChanged,
    String suffix = '',
    String? preferredInitialItem,
  }) {
    return ListenableBuilder(
      key: key,
      listenable: controller,
      builder: (context, _) {
        return QuickSliderPicker(
          selectedValue: controller.text,
          options: options,
          suffix: suffix,
          preferredInitialItem: preferredInitialItem,
          onSelected: (val) {
            controller.text = val;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: val.length),
            );
            onChanged();
          },
        );
      },
    );
  }

  @override
  State<QuickSliderPicker> createState() => _QuickSliderPickerState();
}

class _QuickSliderPickerState extends State<QuickSliderPicker> {
  final Map<String, GlobalKey> _chipKeys = {};
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerInitialItem());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QuickSliderPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue &&
        widget.selectedValue.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerKey(widget.selectedValue, animate: true);
      });
    } else if (oldWidget.preferredInitialItem != widget.preferredInitialItem &&
        widget.selectedValue.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerInitialItem();
      });
    }
  }

  void _centerInitialItem() {
    if (!mounted) return;
    final target = widget.selectedValue.trim().isNotEmpty
        ? widget.selectedValue.trim()
        : widget.preferredInitialItem;
    if (target != null && target.isNotEmpty) {
      _centerKey(target, animate: false);
    }
  }

  /// Centers the requested [option] using ONLY this widget's dedicated
  /// [_scrollController.position]. Calling [ScrollPosition.ensureVisible] directly
  /// guarantees that ancestor scrollables (such as the vertical tab scroll view or
  /// the horizontal TabBarView) will NEVER be scrolled or cause tab teleportation.
  void _centerKey(String option, {bool animate = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    final key = _chipKeys[option.toLowerCase()];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    if (renderObject is RenderBox && !renderObject.hasSize) return;

    try {
      final canAnimate = animate && TickerMode.valuesOf(context).enabled;
      _scrollController.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration:
            canAnimate ? const Duration(milliseconds: 250) : Duration.zero,
        curve: Curves.easeOutCubic,
      );
    } catch (_) {
      // Ignored if detached during tab switch.
    }
  }

  Widget _buildChip(String val, bool isSelected, bool isRecommended) {
    final displayText = widget.suffix.isEmpty ? val : '$val ${widget.suffix}';
    final key = _chipKeys.putIfAbsent(val.toLowerCase(), () => GlobalKey());

    Color borderColor;
    if (isSelected) {
      borderColor = AppColors.amberGoldBorder;
    } else if (isRecommended && widget.selectedValue.isEmpty) {
      borderColor = AppColors.amberGold.withValues(alpha: 0.45);
    } else {
      borderColor = Colors.white.withValues(alpha: 0.12);
    }

    return InkWell(
      key: key,
      canRequestFocus: false,
      onTap: () {
        HapticFeedback.selectionClick();
        _centerKey(val, animate: true);
        widget.onSelected(isSelected ? '' : val);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amberGold.withValues(alpha: 0.20)
              : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedCurrent = widget.selectedValue.trim().toLowerCase();
    final prefLower = widget.preferredInitialItem?.trim().toLowerCase();

    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < widget.options.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _buildChip(
                widget.options[i],
                trimmedCurrent == widget.options[i].trim().toLowerCase(),
                prefLower == widget.options[i].trim().toLowerCase(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
