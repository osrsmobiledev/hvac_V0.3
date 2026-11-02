// File: lib/core/widgets/signature_pad_components.dart
// Responsibility: Modular sub-components for the tactical digital signature modal.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/signature_painter.dart';
import 'package:hvac_app/core/widgets/tactical_dialog_button.dart';

class SignatureModalHeader extends StatelessWidget {
  const SignatureModalHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: EindbeoordelingDictionary.btnAnnuleren,
        ),
      ],
    );
  }
}

class SignatureCanvasArea extends StatelessWidget {
  const SignatureCanvasArea({
    super.key,
    required this.points,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final List<Offset?> points;
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Container(height: 1, color: const Color(0xFFCBD5E1)),
            ),
            GestureDetector(
              onPanStart: (d) => onPanStart(d.localPosition),
              onPanUpdate: (d) => onPanUpdate(d.localPosition),
              onPanEnd: (_) => onPanEnd(),
              child: CustomPaint(
                painter: SignaturePainter(points: points),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignatureModalFooter extends StatelessWidget {
  const SignatureModalFooter({
    super.key,
    required this.hasPoints,
    required this.isSaving,
    required this.onClear,
    required this.onCancel,
    required this.onSave,
  });

  final bool hasPoints;
  final bool isSaving;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hasPoints)
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.terracotta,
            tooltip: EindbeoordelingDictionary.btnWissen,
          ),
        const Spacer(),
        SizedBox(
          width: 105,
          child: TacticalDialogButton.secondary(
            label: EindbeoordelingDictionary.btnAnnuleren,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: TacticalDialogButton.primary(
            label: EindbeoordelingDictionary.btnOpslaan,
            onPressed: isSaving ? null : onSave,
          ),
        ),
      ],
    );
  }
}
