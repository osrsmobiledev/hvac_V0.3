import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/features/certificate_draft/domain/flue_gas_field.dart';
import 'flue_gas_field_box.dart';

/// Separated 'Rookgassen' squircle card with smooth expand/collapse animation.
///
/// Features:
/// - Dark grey/carbon tinted surface with amber rim border.
/// - Inner header bar with Eurolyzer QR scanner launch icon button.
/// - Animated rotating chevron toggle.
/// - Animated size transition revealing/hiding the 21 parameter boxes.
class RookgassenCard extends StatefulWidget {
  final VoidCallback? onScanQrPressed;

  const RookgassenCard({
    super.key,
    this.onScanQrPressed,
  });

  @override
  State<RookgassenCard> createState() => _RookgassenCardState();
}

class _RookgassenCardState extends State<RookgassenCard> {
  bool _isRookgassenExpanded = true;

  @override
  Widget build(BuildContext context) {
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
          // Inner Header Bar for 'Rookgassen'
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
                    _isRookgassenExpanded = !_isRookgassenExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Rookgassen',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      // QR Scanner Launch Button
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppColors.amberGold,
                          size: 22,
                        ),
                        tooltip: 'Eurolyzer QR scannen',
                        onPressed: widget.onScanQrPressed ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Eurolyzer QR Scanner wordt geactiveerd in Slice 3.2',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                      ),
                      // Smooth Rotating Chevron Icon
                      AnimatedRotation(
                        turns: _isRookgassenExpanded ? 0.5 : 0.0,
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

          // Smooth Animated Expansion of the 21 Parameter Fields
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _isRookgassenExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: FlueGasField.defaultFields.map((field) {
                          return FlueGasFieldBox(field: field);
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
