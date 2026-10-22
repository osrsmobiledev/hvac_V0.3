import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Reusable main bento card template for all applet tabs.
///
/// Features:
/// - Tonal tinted surface matching the dashboard applet tile aesthetic.
/// - Colored squircle rim border with 20px radius.
/// - Centered Libron title with expand/collapse chevron toggle.
/// - Standardized container to host sub-boxes across all tabs.
class BentoCollapsibleCard extends StatefulWidget {
  final String title;
  final Widget child;
  final Color accentColor;
  final Color borderColor;
  final bool initiallyExpanded;

  const BentoCollapsibleCard({
    super.key,
    required this.title,
    required this.child,
    this.accentColor = AppColors.amberGold,
    this.borderColor = AppColors.amberGoldBorder,
    this.initiallyExpanded = true,
  });

  @override
  State<BentoCollapsibleCard> createState() => _BentoCollapsibleCardState();
}

class _BentoCollapsibleCardState extends State<BentoCollapsibleCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Tonal surface: blend accent tint over the dark carbon background
    final tonalBackground = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.06),
      AppColors.carbonCard,
    );

    return Container(
      decoration: BoxDecoration(
        color: tonalBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.borderColor,
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with tap-to-toggle behavior
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
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
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: widget.accentColor,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Section (visible when expanded)
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}
