// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/signature_tile.dart
// Responsibility: BO2 Tactical signature tile with live preview and clear button.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';

class SignatureTile extends StatelessWidget {
  const SignatureTile({
    super.key,
    required this.label,
    required this.signatureData,
    required this.onTapSign,
    required this.onClear,
  });

  final String label;
  final String? signatureData;
  final VoidCallback onTapSign;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasSignature =
        signatureData != null && signatureData!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarkInputLabel(label),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTapSign();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: hasSignature
                  ? const Color(0xFF141820)
                  : const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasSignature
                    ? AppColors.amberGoldBorder
                    : Colors.white.withValues(alpha: 0.16),
                width: hasSignature ? 1.2 : 1.0,
              ),
              boxShadow: hasSignature
                  ? [
                      BoxShadow(
                        color: AppColors.antiqueGold.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: hasSignature
                ? _SignaturePreviewStack(
                    signatureData: signatureData!,
                    onClear: onClear,
                  )
                : const _SignatureEmptyPrompt(),
          ),
        ),
      ],
    );
  }
}

class _SignatureEmptyPrompt extends StatelessWidget {
  const _SignatureEmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.draw_outlined,
            color: AppColors.antiqueGold,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            EindbeoordelingDictionary.btnTikOmTeTekenen,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePreviewStack extends StatelessWidget {
  const _SignaturePreviewStack({
    required this.signatureData,
    required this.onClear,
  });

  final String signatureData;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (signatureData.startsWith('data:image/png;base64,')) {
      final base64Content =
          signatureData.substring('data:image/png;base64,'.length);
      imageWidget = Image.memory(
        base64Decode(base64Content),
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = const Icon(
        Icons.check_circle_outline,
        color: AppColors.antiqueGold,
        size: 32,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: TacticalSquareButton(
            icon: Icons.close,
            size: 28,
            accentColor: AppColors.errorRed,
            borderColor: AppColors.errorRed.withValues(alpha: 0.4),
            tooltip: EindbeoordelingDictionary.tooltipClearSignature,
            onPressed: onClear,
          ),
        ),
      ],
    );
  }
}
