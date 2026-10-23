import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Standardized single reusable dropdown section for all workflow tabs.
///
/// Encapsulates both:
/// 1. The gold-tinted header trigger with animated rotating chevron.
/// 2. The unified drop-down content container with a subtle neutral
///    gray/white border (M3 compliant), rounded corners, and consistent padding.
class BentoMainSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool initiallyExpanded;
  final Color accentColor;
  final Color borderColor;
  final bool wrapInCard;
  final EdgeInsetsGeometry contentPadding;

  const BentoMainSection({
    super.key,
    required this.title,
    required this.child,
    this.isExpanded,
    this.onExpansionChanged,
    this.initiallyExpanded = true,
    this.accentColor = AppColors.antiqueGold,
    this.borderColor = AppColors.antiqueGold,
    this.wrapInCard = true,
    this.contentPadding = const EdgeInsets.all(16.0),
  });

  @override
  State<BentoMainSection> createState() => _BentoMainSectionState();
}

class _BentoMainSectionState extends State<BentoMainSection> {
  late bool _internalExpanded;
  /// Guards the PageStorage read so it only runs once (not on every dependency change).
  bool _hasRestoredState = false;

  bool get _effectiveExpanded => widget.isExpanded ?? _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.initiallyExpanded;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only restore persisted state on the first dependency resolution;
    // subsequent calls (e.g., theme or locale changes) must not override
    // state that the user has already changed interactively.
    if (!_hasRestoredState && widget.isExpanded == null) {
      _hasRestoredState = true;
      final saved = PageStorage.maybeOf(context)?.readState(
        context,
        identifier: 'bento_main_${widget.title}',
      ) as bool?;
      if (saved != null) {
        _internalExpanded = saved;
      }
    }
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    final next = !_effectiveExpanded;
    if (widget.isExpanded == null) {
      setState(() {
        _internalExpanded = next;
      });
      PageStorage.maybeOf(context)?.writeState(
        context,
        next,
        identifier: 'bento_main_${widget.title}',
      );
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    // Tonal amber surface: blends gold accent over carbon base
    final mainBoxTint = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.07),
      AppColors.carbonCard,
    );

    final cardBackground = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.03),
      const Color(0xFF141414),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Standalone Main Box: Gold-Tinted Section Header ---
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: mainBoxTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Animated rotating chevron (0.5 turn = pointing up)
                    AnimatedRotation(
                      turns: _effectiveExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.accentColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- Smooth Animated Expansion for Separated Sub-Box ---
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _effectiveExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: widget.wrapInCard
                        ? Container(
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.borderSubtle,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: widget.contentPadding,
                            child: widget.child,
                          )
                        : widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
