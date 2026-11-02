import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Floating navigation arrows overlay for switching workflow tabs.
///
/// Features:
/// - Floating semi-transparent dark-glass circular buttons (#181818, alpha 0.78).
/// - Amber-gold chevron arrows with subtle shadow and border.
/// - Positioned cleanly on middle left and right edges without obstructing form inputs.
/// - Left arrow automatically hides on Tab 1; right arrow hides on the final tab.
class TabNavOverlay extends StatelessWidget {
  final TabController controller;
  final int tabCount;

  const TabNavOverlay({
    super.key,
    required this.controller,
    required this.tabCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final index = controller.index;
        final hasPrev = index > 0;
        final hasNext = index < tabCount - 1;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (hasPrev)
              Positioned(
                left: 2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: TabNavFloatingArrow(
                    key: const ValueKey('tab_nav_prev_arrow'),
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Vorige tab',
                    onTap: () {
                      if (controller.index > 0) {
                        controller.animateTo(controller.index - 1);
                      }
                    },
                  ),
                ),
              ),
            if (hasNext)
              Positioned(
                right: 2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: TabNavFloatingArrow(
                    key: const ValueKey('tab_nav_next_arrow'),
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Volgende tab',
                    onTap: () {
                      if (controller.index < tabCount - 1) {
                        controller.animateTo(controller.index + 1);
                      }
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Compact circular floating arrow button.
class TabNavFloatingArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const TabNavFloatingArrow({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.amberGold.withValues(alpha: 0.25),
          highlightColor: AppColors.amberGold.withValues(alpha: 0.12),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF161616).withValues(alpha: 0.40),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.amberGoldBorder.withValues(alpha: 0.30),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.amberGold.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
