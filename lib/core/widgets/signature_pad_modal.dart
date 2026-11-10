// File: lib/core/widgets/signature_pad_modal.dart
// Responsibility: Spacious modal canvas allowing technician/customer to draw a digital signature in BO2 style.

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/widgets/signature_pad_components.dart';

class SignaturePadModal extends StatefulWidget {
  const SignaturePadModal({
    super.key,
    required this.title,
    this.initialSignatureData,
  });

  final String title;
  final String? initialSignatureData;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? initialSignatureData,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignaturePadModal(
        title: title,
        initialSignatureData: initialSignatureData,
      ),
    );
  }

  @override
  State<SignaturePadModal> createState() => _SignaturePadModalState();
}

class _SignaturePadModalState extends State<SignaturePadModal> {
  final List<Offset?> _points = [];
  bool _isSaving = false;
  Size _canvasSize = const Size(400, 300);

  void _clear() => setState(() => _points.clear());

  Future<void> _save() async {
    if (_points.where((p) => p != null).length < 2) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = true);

    try {
      // Compute the tight bounding box around the signature strokes
      double minX = double.infinity, minY = double.infinity;
      double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
      for (final p in _points) {
        if (p != null) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
          if (p.dy < minY) minY = p.dy;
          if (p.dy > maxY) maxY = p.dy;
        }
      }

      const double pad = 12.0;
      final canvasW = _canvasSize.width > 0 ? _canvasSize.width : 400.0;
      final canvasH = _canvasSize.height > 0 ? _canvasSize.height : 300.0;
      minX = (minX - pad).clamp(0.0, canvasW);
      minY = (minY - pad).clamp(0.0, canvasH);
      maxX = (maxX + pad).clamp(0.0, canvasW);
      maxY = (maxY + pad).clamp(0.0, canvasH);

      final cropWidth = (maxX - minX).clamp(40.0, canvasW).round();
      final cropHeight = (maxY - minY).clamp(24.0, canvasH).round();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
      );

      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
        bgPaint,
      );

      final strokePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2;

      canvas.translate(-minX, -minY);

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, strokePaint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(cropWidth, cropHeight);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        final bytes = byteData.buffer.asUint8List();
        final base64String = 'data:image/png;base64,${base64Encode(bytes)}';
        Navigator.of(context).pop(base64String);
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, stack) {
      debugPrint('[SignaturePadModal] _save error: $e\n$stack');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width >= 600;

    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.antiqueGold, width: 1.2),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 12,
        vertical: isTablet ? 32 : 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 680 : 540,
          maxHeight: screenSize.height * 0.78,
          minHeight: 380,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SignatureModalHeader(title: widget.title),
              const SizedBox(height: 12),
              Expanded(
                child: SignatureCanvasArea(
                  points: _points,
                  onPanStart: (pos) => setState(() => _points.add(pos)),
                  onPanUpdate: (pos) => setState(() => _points.add(pos)),
                  onPanEnd: () => setState(() => _points.add(null)),
                  onSizeChanged: (size) => _canvasSize = size,
                ),
              ),
              const SizedBox(height: 16),
              SignatureModalFooter(
                hasPoints: _points.isNotEmpty,
                isSaving: _isSaving,
                onClear: _clear,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
