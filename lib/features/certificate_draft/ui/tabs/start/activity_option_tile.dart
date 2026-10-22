import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Modern premium BO2 tactical selection tile for Tab 2 (Start).
///
/// Features:
/// - Smooth tactile press-scale animation (compresses slightly on touch).
/// - Non-puffed, constant 1.0px hairline border that smoothly glows amber-gold.
/// - OLED glass surface glow: subtle amber-gold tonal blend when active.
/// - Precision tactical reticle indicator with animated spring-in pip.
class ActivityOptionTile extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ActivityOptionTile> createState() => _ActivityOptionTileState();
}

class _ActivityOptionTileState extends State<ActivityOptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Surface color: subtle amber-gold tonal blend over carbon when selected
    final backgroundColor = widget.isSelected
        ? Color.alphaBlend(
            AppColors.amberGold.withValues(alpha: 0.08),
            const Color(0xFF141414),
          )
        : const Color(0xFF0C0C0C);

    final borderColor = widget.isSelected
        ? AppColors.amberGold
        : Colors.white.withValues(alpha: 0.18);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.982 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1.0, // Constant width prevents puffy border jumps
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.amberGold.withValues(alpha: 0.14),
                      blurRadius: 10,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Tactical HUD Selector Pip (Reticle)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOutCubic,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.amberGold
                        : Colors.white30,
                    width: 1.4,
                  ),
                  color: widget.isSelected
                      ? AppColors.amberGold.withValues(alpha: 0.16)
                      : Colors.transparent,
                ),
                child: Center(
                  child: AnimatedScale(
                    scale: widget.isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title with smooth text color transition
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  child: Text(widget.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
