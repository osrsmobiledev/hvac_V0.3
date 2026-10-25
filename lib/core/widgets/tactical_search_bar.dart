import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable Material 3 SearchBar configured with BO2 Tactical HUD styling.
///
/// Follows the official Material 3 specification:
/// https://m3.material.io/components/search/overview
///
/// Key Features:
/// - 100% pill-shaped geometry ([StadiumBorder]).
/// - Dynamic leading icon that smoothly animates via [AnimatedSwitcher]
///   between a search magnifying glass [Icons.search_rounded] (resting)
///   and a back arrow [Icons.arrow_back_rounded] (focused or with text).
/// - Dynamic trailing clear button [Icons.close_rounded] when query is present.
/// - Amber gold hairline focus border highlighting the active state.
/// - Self-contained [FocusNode] and [TextEditingController] handling when not provided.
class TacticalSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onBack;
  final VoidCallback? onTap;
  final List<Widget>? trailing;
  final bool enabled;
  final bool autofocus;

  const TacticalSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onBack,
    this.onTap,
    this.trailing,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<TacticalSearchBar> createState() => _TacticalSearchBarState();
}

class _TacticalSearchBarState extends State<TacticalSearchBar> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleStateChange);
    _effectiveController.addListener(_handleStateChange);
  }

  @override
  void didUpdateWidget(covariant TacticalSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          ?.removeListener(_handleStateChange);
      _effectiveFocusNode.addListener(_handleStateChange);
    }
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_handleStateChange);
      _effectiveController.addListener(_handleStateChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleStateChange);
    _effectiveController.removeListener(_handleStateChange);
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) setState(() {});
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  void _handleBack() {
    _effectiveFocusNode.unfocus();
    if (_effectiveController.text.isNotEmpty) {
      _handleClear();
    }
    widget.onBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching =
        _effectiveFocusNode.hasFocus || _effectiveController.text.isNotEmpty;

    return SearchBar(
      controller: _effectiveController,
      focusNode: _effectiveFocusNode,
      autoFocus: widget.autofocus,
      enabled: widget.enabled,
      hintText: widget.hintText ?? AppDictionary.searchCustomerHint,
      hintStyle: const WidgetStatePropertyAll(
        TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF0C0C0C)),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(
            color: AppColors.amberGoldBorder,
            width: 1.4,
          );
        }
        return BorderSide(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.0,
        );
      }),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8),
      ),
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: isSearching
            ? IconButton(
                key: const ValueKey('search_back_button'),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.amberGold,
                  size: 22,
                ),
                tooltip: AppDictionary.btnBack,
                onPressed: _handleBack,
              )
            : const Padding(
                key: ValueKey('search_glass_icon'),
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.amberGold,
                  size: 20,
                ),
              ),
      ),
      trailing: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: isSearching
              ? IconButton(
                  key: const ValueKey('search_clear_button'),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: AppDictionary.dlgClose,
                  onPressed: _handleClear,
                )
              : const SizedBox.shrink(key: ValueKey('empty_trailing')),
        ),
        if (widget.trailing != null) ...widget.trailing!,
      ],
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
