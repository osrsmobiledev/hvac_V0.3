// File: lib/core/widgets/signature_pad_modal.dart
// Responsibility: Modal canvas allowing technician/customer to draw a digital signature in BO2 style.

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

  void _clear() => setState(() => _points.clear());

  Future<void> _save() async {
    if (_points.where((p) => p != null).length < 2) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSaving = true);

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 200));

      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 200), bgPaint);

      final strokePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.2;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, strokePaint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(400, 200);
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
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.antiqueGold, width: 1.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SignatureModalHeader(title: widget.title),
              const SizedBox(height: 12),
              SignatureCanvasArea(
                points: _points,
                onPanStart: (pos) => setState(() => _points.add(pos)),
                onPanUpdate: (pos) => setState(() => _points.add(pos)),
                onPanEnd: () => setState(() => _points.add(null)),
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
