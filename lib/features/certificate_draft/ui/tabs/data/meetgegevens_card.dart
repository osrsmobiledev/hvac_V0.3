import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'rookgassen_card.dart';

/// Standalone 'Meetgegevens' card with smooth expand/collapse transition.
///
/// Features:
/// - Amber gold tonal tint matching the dashboard applet tile aesthetic.
/// - Antique gold rim border with 18px squircle radius.
/// - Centered Libron title with smooth animated rotating chevron.
/// - Animated size transition revealing/hiding the separated [RookgassenCard] below.
class MeetgegevensCard extends StatefulWidget {
  final VoidCallback? onScanQrPressed;

  const MeetgegevensCard({
    super.key,
    this.onScanQrPressed,
  });

  @override
  State<MeetgegevensCard> createState() => _MeetgegevensCardState();
}

class _MeetgegevensCardState extends State<MeetgegevensCard> {
  bool _isMeetgegevensExpanded = true;

  @override
  Widget build(BuildContext context) {
    final mainBoxTint = Color.alphaBlend(
      AppColors.amberGold.withValues(alpha: 0.07),
      AppColors.carbonCard,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. Standalone Main Box: 'Meetgegevens' (Gold Tinted) ---
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: mainBoxTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.amberGoldBorder,
              width: 1.4,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _isMeetgegevensExpanded = !_isMeetgegevensExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Meetgegevens',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Animated rotating chevron (down <-> up)
                    AnimatedRotation(
                      turns: _isMeetgegevensExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.amberGold,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- 2. Smooth Animated Expansion for Separated 'Rookgassen' Card ---
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: _isMeetgegevensExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: RookgassenCard(
                      onScanQrPressed: widget.onScanQrPressed,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
