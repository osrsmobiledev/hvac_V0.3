import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'wheel_fade_mask.dart';

/// Reusable tactical horizontal 3D cylindrical wheel dial.
///
/// Adapted from legacy time picker (bo2_time_spinner.dart) with Cupertino
/// [FixedExtentScrollPhysics] and true 3D perspective projection.
class HorizontalWheelPicker extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String suffix;
  final String? preferredInitialItem;
  final double height;
  final double itemExtent;

  const HorizontalWheelPicker({
    super.key,
    required this.items,
    required this.controller,
    required this.onChanged,
    this.suffix = '',
    this.preferredInitialItem,
    this.height = 38.0,
    this.itemExtent = 64.0,
  });

  /// Creates a wheel from an integer range (e.g. 50 to 80).
  factory HorizontalWheelPicker.range({
    Key? key,
    required int min,
    required int max,
    int step = 1,
    required TextEditingController controller,
    required VoidCallback onChanged,
    String suffix = '',
    String? preferredInitialItem,
    double height = 38.0,
    double itemExtent = 64.0,
  }) {
    return HorizontalWheelPicker(
      key: key,
      items: List.generate(
          ((max - min) ~/ step) + 1, (i) => (min + i * step).toString()),
      controller: controller,
      onChanged: onChanged,
      suffix: suffix,
      preferredInitialItem: preferredInitialItem,
      height: height,
      itemExtent: itemExtent,
    );
  }

  @override
  State<HorizontalWheelPicker> createState() => _HorizontalWheelPickerState();
}

class _HorizontalWheelPickerState extends State<HorizontalWheelPicker> {
  late FixedExtentScrollController _scrollController;
  int _currentIndex = 0;
  bool _isWheeling = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = _findMatchingIndex(widget.controller.text);
    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant HorizontalWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _onControllerChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  int _findMatchingIndex(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      final index = widget.items.indexOf(trimmed);
      if (index >= 0) return index;
    }
    if (widget.preferredInitialItem != null) {
      final pref = widget.items.indexOf(widget.preferredInitialItem!);
      if (pref >= 0) return pref;
    }
    return (widget.items.length / 2).floor();
  }

  void _onControllerChanged() {
    if (_isWheeling || !mounted) return;
    final index = widget.items.indexOf(widget.controller.text.trim());
    if (index >= 0 && index != _currentIndex && _scrollController.hasClients) {
      _currentIndex = index;
      _scrollController.animateToItem(index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic);
      setState(() {});
    }
  }

  void _applySelection(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _isWheeling = true;
    widget.controller.text = widget.items[index];
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.items[index].length),
    );
    widget.onChanged();
    _isWheeling = false;
  }

  void _onSelectedItemChanged(int index) {
    if (_currentIndex == index && widget.controller.text.isNotEmpty) return;
    _applySelection(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Center indicator reticle (amber gold frame)
          Container(
            width: widget.itemExtent + 2,
            height: widget.height - 6,
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: AppColors.amberGoldBorder,
                width: 1.2,
              ),
            ),
          ),

          // 2. 3D Cylindrical Wheel (Rotated ListWheelScrollView with Cupertino physics)
          RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: widget.itemExtent,
              diameterRatio: 1.5,
              perspective: 0.003,
              magnification: 1.15,
              useMagnifier: true,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onSelectedItemChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.items.length,
                builder: (context, index) {
                  if (index < 0 || index >= widget.items.length) return null;
                  return _buildItem(index);
                },
              ),
            ),
          ),

          // 3. Edge gradient fade masks (giving 3D horizon depth)
          const WheelFadeMask(width: 28.0, isLeft: true),
          const WheelFadeMask(width: 28.0, isLeft: false),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final isSelected = index == _currentIndex;
    final val = widget.items[index];
    final numStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: isSelected ? 12.5 : 11.0,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: isSelected ? Colors.white : AppColors.textMuted,
    );
    final unitStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: isSelected ? 10.5 : 9.5,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      color: isSelected
          ? AppColors.amberGold.withValues(alpha: 0.9)
          : AppColors.textMuted.withValues(alpha: 0.7),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index != _currentIndex && _scrollController.hasClients) {
          _scrollController.animateToItem(index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic);
        } else if (widget.controller.text.isEmpty) {
          _applySelection(index);
        }
      },
      child: RotatedBox(
        quarterTurns: 1,
        child: Center(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: val, style: numStyle),
              if (widget.suffix.isNotEmpty)
                TextSpan(text: ' ${widget.suffix}', style: unitStyle),
            ]),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
    );
  }
}
