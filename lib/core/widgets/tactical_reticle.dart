// File: lib/core/widgets/tactical_reticle.dart
// Responsibility: Minimal tactical optical corner-bracket reticle with micro crosshair.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';

/// Minimal tactical optical reticle with 4 corner brackets and a center crosshair.
class TacticalReticle extends StatelessWidget {
  final double size;
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;
  final Color color;

  const TacticalReticle({
    super.key,
    this.size = 160.0,
    this.cornerLength = 22.0,
    this.strokeWidth = 2.5,
    this.cornerRadius = 8.0,
    this.color = AppColors.amberGold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ReticlePainter(
          cornerLength: cornerLength,
          strokeWidth: strokeWidth,
          cornerRadius: cornerRadius,
          color: color,
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;
  final Color color;

  _ReticlePainter({
    required this.cornerLength,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final l = cornerLength;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, l)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(l, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(w - l, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, l);
    canvas.drawPath(pathTR, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(w, h - l)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(w - l, h);
    canvas.drawPath(pathBR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(l, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..lineTo(0, h - l);
    canvas.drawPath(pathBL, paint);

    // Center micro crosshair
    final crossPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    const ch = 5.0;
    final cx = w / 2;
    final cy = h / 2;
    canvas.drawLine(Offset(cx - ch, cy), Offset(cx + ch, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - ch), Offset(cx, cy + ch), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
