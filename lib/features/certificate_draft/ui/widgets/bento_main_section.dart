import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Reusable gold-tinted main section card with animated collapse/expand.
///
/// Standardized template used across all workflow tabs (Data, Start, etc.):
/// - Tonal amber-gold tint blended over carbon card background.
/// - Antique gold rim border with 18px squircle corners.
/// - Centered Libron title with smooth animated rotating chevron.
/// - Animated size transition revealing the separated sub-box underneath.
class BentoMainSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Color accentColor;
  final Color borderColor;

  const BentoMainSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.accentColor = AppColors.amberGold,
    this.borderColor = AppColors.amberGoldBorder,
  });

  @override
  State<BentoMainSection> createState() => _BentoMainSectionState();
}

class _BentoMainSectionState extends State<BentoMainSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Tonal amber surface: blends gold accent over carbon base
    final mainBoxTint = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.07),
      AppColors.carbonCard,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Standalone Main Box: Gold-Tinted Section Header ---
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: mainBoxTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.borderColor,
              width: 1.4,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Animated rotating chevron (0.5 turn = pointing up)
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.accentColor,
                        size: 26,
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
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
