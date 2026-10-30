import 'package:flutter/material.dart';

/// Reusable gradient fade mask for horizontal wheel dials giving 3D horizon depth.
class WheelFadeMask extends StatelessWidget {
  final double width;
  final bool isLeft;

  const WheelFadeMask({
    super.key,
    required this.width,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      width: width,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLeft
                  ? const [Color(0xFF141414), Color(0x00141414)]
                  : const [Color(0x00141414), Color(0xFF141414)],
            ),
          ),
        ),
      ),
    );
  }
}
