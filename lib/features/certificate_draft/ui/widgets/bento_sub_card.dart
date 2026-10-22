import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Reusable sub-box template nested inside main bento cards.
///
/// Features:
/// - Inner squircle container with subtle tonal tint.
/// - Bordered header bar with title, optional action icon (e.g. QR scan), and chevron.
/// - Tap-to-toggle accordion behavior for inner input fields.
class BentoSubCard extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final Color accentColor;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? actionTooltip;
  final bool initiallyExpanded;

  const BentoSubCard({
    super.key,
    required this.title,
    required this.children,
    this.accentColor = AppColors.amberGold,
    this.actionIcon,
    this.onActionPressed,
    this.actionTooltip,
    this.initiallyExpanded = true,
  });

  @override
  State<BentoSubCard> createState() => _BentoSubCardState();
}

class _BentoSubCardState extends State<BentoSubCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Subtle inner tonal background
    final subBackground = Color.alphaBlend(
      widget.accentColor.withValues(alpha: 0.03),
      const Color(0xFF161616),
    );

    return Container(
      decoration: BoxDecoration(
        color: subBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-Box Header Bar with action button and toggle chevron
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
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
                      if (widget.actionIcon != null) ...[
                        IconButton(
                          icon: Icon(
                            widget.actionIcon,
                            color: widget.accentColor,
                            size: 22,
                          ),
                          tooltip: widget.actionTooltip,
                          onPressed: widget.onActionPressed,
                        ),
                      ],
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sub-Box Input Fields / Parameter Boxes
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: widget.children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
