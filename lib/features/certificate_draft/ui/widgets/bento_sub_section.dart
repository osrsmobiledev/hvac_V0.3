import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable inner collapsible section used within BentoMainSection (e.g. Rookgassen on Data).
///
/// Features:
/// - Inner header pill container (#222222) with title, optional action button, and chevron.
/// - Smooth animated expand/collapse for inner fields.
/// - Supports both controlled (via [isExpanded]) and uncontrolled (via [PageStorage]) state.
/// - Automatically displays [actionWidget] (e.g. QR scanner button) only when expanded.
class BentoSubSection extends StatefulWidget {
  final String title;
  final Widget child;
  final Widget? actionWidget;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool initiallyExpanded;

  const BentoSubSection({
    super.key,
    required this.title,
    required this.child,
    this.actionWidget,
    this.isExpanded,
    this.onExpansionChanged,
    this.initiallyExpanded = true,
  });

  @override
  State<BentoSubSection> createState() => _BentoSubSectionState();
}

class _BentoSubSectionState extends State<BentoSubSection> {
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
    // Only restore persisted state on the first dependency resolution.
    if (!_hasRestoredState && widget.isExpanded == null) {
      _hasRestoredState = true;
      final saved = PageStorage.maybeOf(context)?.readState(
        context,
        identifier: 'bento_sub_${widget.title}',
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
        identifier: 'bento_sub_${widget.title}',
      );
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Inner Header Bar ---
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _handleTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    // Action button appears only when expanded
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      ),
                      child: (_effectiveExpanded && widget.actionWidget != null)
                          ? Padding(
                              key: const ValueKey('bento_sub_action_visible'),
                              padding: const EdgeInsets.only(right: 6.0),
                              child: widget.actionWidget!,
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('bento_sub_action_hidden'),
                            ),
                    ),
                    // Animated rotating chevron (white)
                    AnimatedRotation(
                      turns: _effectiveExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- Animated Size for Inner Fields ---
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _effectiveExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
