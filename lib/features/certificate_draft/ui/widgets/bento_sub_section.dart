import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable separated sub-box container with dark grey/carbon tint and inner header.
///
/// Standardized template used across all workflow tabs (Rookgassen on Data, etc.):
/// - Dark charcoal/carbon tinted surface with antique gold rim border.
/// - Inner header pill container (#222222) with title, optional action button, and chevron.
/// - Smooth animated expand/collapse for inner fields.
class BentoSubSection extends StatefulWidget {
  final String title;
  final Widget child;
  final Widget? actionWidget;
  final bool initiallyExpanded;

  const BentoSubSection({
    super.key,
    required this.title,
    required this.child,
    this.actionWidget,
    this.initiallyExpanded = true,
  });

  @override
  State<BentoSubSection> createState() => _BentoSubSectionState();
}

class _BentoSubSectionState extends State<BentoSubSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Charcoal tinted surface matching the approved Data tab sub-box
    final subBoxTint = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.03),
      const Color(0xFF141414),
    );

    return Container(
      decoration: BoxDecoration(
        color: subBoxTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.amberGoldBorder,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
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
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
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
                      if (widget.actionWidget != null) widget.actionWidget!,
                      // Animated rotating chevron (white)
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
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
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: widget.child,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
