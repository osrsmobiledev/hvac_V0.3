import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'wheel_fade_mask.dart';

/// Reusable tactical horizontal 3D cylindrical wheel dial with infinite looping.
class HorizontalWheelPicker extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String suffix;
  final String? preferredInitialItem;
  final double height, itemExtent;

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
  }) =>
      HorizontalWheelPicker(
        key: key,
        items: List.generate(
          ((max - min) ~/ step) + 1,
          (i) => (min + i * step).toString(),
        ),
        controller: controller,
        onChanged: onChanged,
        suffix: suffix,
        preferredInitialItem: preferredInitialItem,
        height: height,
        itemExtent: itemExtent,
      );

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
    final t = text.trim();
    if (t.isNotEmpty) {
      final index = widget.items.indexOf(t);
      if (index >= 0) return index;
      if (t.contains(RegExp(r'[,.]'))) {
        final intIndex = widget.items.indexOf(t.split(RegExp(r'[,.]')).first);
        if (intIndex >= 0) return intIndex;
      }
    }
    if (widget.preferredInitialItem != null) {
      final pref = widget.items.indexOf(widget.preferredInitialItem!);
      if (pref >= 0) return pref;
    }
    return (widget.items.length / 2).floor();
  }

  int _diffToTarget(int target) {
    final len = widget.items.length;
    final cur = _scrollController.selectedItem;
    final curNorm = ((cur % len) + len) % len;
    var d = target - curNorm;
    if (d > len / 2) d -= len;
    if (d < -len / 2) d += len;
    return d;
  }

  void _onControllerChanged() {
    if (_isWheeling || !mounted || widget.items.isEmpty) return;
    final t = widget.controller.text.trim();
    var idx = widget.items.indexOf(t);
    if (idx < 0 && t.contains(RegExp(r'[,.]'))) {
      idx = widget.items.indexOf(t.split(RegExp(r'[,.]')).first);
    }
    if (idx >= 0 && idx != _currentIndex && _scrollController.hasClients) {
      _currentIndex = idx;
      _scrollController
          .jumpToItem(_scrollController.selectedItem + _diffToTarget(idx));
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

  void _animateToNearestIndex(int targetIndex) {
    if (!_scrollController.hasClients || widget.items.isEmpty) return;
    _scrollController.animateToItem(
      _scrollController.selectedItem + _diffToTarget(targetIndex),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final len = widget.items.length;
    return Container(
      width: double.infinity,
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.itemExtent + 2,
            height: widget.height - 6,
            decoration: BoxDecoration(
              color: AppColors.amberGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: AppColors.amberGoldBorder, width: 1.2),
            ),
          ),
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
              onSelectedItemChanged: (raw) {
                if (len == 0) return;
                final norm = ((raw % len) + len) % len;
                if (_currentIndex != norm || widget.controller.text.isEmpty) {
                  _applySelection(norm);
                }
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(len, (i) => _buildItem(i)),
              ),
            ),
          ),
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
          _animateToNearestIndex(index);
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
