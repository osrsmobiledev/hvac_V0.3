// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/signature_tile.dart
// Responsibility: BO2 Tactical signature tile with live preview, pre-flight validation, and clear button.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_label.dart';
import 'signature_exception_prompt.dart';

class SignatureTile extends StatelessWidget {
  const SignatureTile({
    super.key,
    required this.label,
    required this.signatureData,
    this.exception,
    this.isError = false,
    required this.onTapSign,
    required this.onClear,
  });

  final String label;
  final String? signatureData;
  final String? exception; // 'refused' | 'absent' | null
  final bool isError;
  final VoidCallback onTapSign;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasException = exception != null && exception!.isNotEmpty;
    final bool hasSignature = !hasException &&
        signatureData != null &&
        signatureData!.trim().isNotEmpty;

    final backgroundColor = hasSignature
        ? const Color(0xFF141820)
        : hasException
            ? (exception == 'refused'
                ? Color.alphaBlend(
                    AppColors.errorRed.withValues(alpha: 0.08),
                    const Color(0xFF0C0C0C),
                  )
                : Color.alphaBlend(
                    AppColors.antiqueGold.withValues(alpha: 0.08),
                    const Color(0xFF0C0C0C),
                  ))
            : isError
                ? Color.alphaBlend(
                    AppColors.errorRed.withValues(alpha: 0.08),
                    const Color(0xFF0C0C0C),
                  )
                : const Color(0xFF0C0C0C);

    final borderColor = hasSignature
        ? AppColors.amberGoldBorder
        : hasException
            ? (exception == 'refused'
                ? AppColors.errorRed
                : AppColors.amberGoldBorder)
            : isError
                ? AppColors.errorRed
                : Colors.white.withValues(alpha: 0.16);

    final shadowColor = hasException && exception == 'refused'
        ? AppColors.errorRed
        : AppColors.antiqueGold;

    final borderWidth = (hasSignature || hasException || isError) ? 1.2 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DarkInputLabel(label),
        InkWell(
          onTap: hasException
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTapSign();
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: (hasSignature || hasException)
                  ? [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: hasException
                ? SignatureExceptionPrompt(exception: exception!)
                : (hasSignature
                    ? _SignaturePreviewStack(
                        signatureData: signatureData!,
                        onClear: onClear,
                      )
                    : _SignatureEmptyPrompt(isError: isError)),
          ),
        ),
      ],
    );
  }
}

class _SignatureEmptyPrompt extends StatelessWidget {
  final bool isError;

  const _SignatureEmptyPrompt({this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.draw_outlined,
            color: isError ? AppColors.errorRed : AppColors.antiqueGold,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            EindbeoordelingDictionary.btnTikOmTeTekenen,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isError ? AppColors.errorRed : Colors.white,
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
      try {
        imageWidget = Image.memory(
          base64Decode(base64Content),
          fit: BoxFit.contain,
        );
      } catch (_) {
        imageWidget = const Icon(
          Icons.check_circle_outline,
          color: AppColors.antiqueGold,
          size: 32,
        );
      }
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
