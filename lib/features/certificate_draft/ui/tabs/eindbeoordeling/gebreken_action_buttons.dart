// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/gebreken_action_buttons.dart
// Responsibility: Tactical action buttons, multiline input with embedded delete button, and remediation banner.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/core/widgets/tactical_square_button.dart';
import 'package:hvac_app/features/certificate_draft/ui/widgets/dark_input_box.dart';

/// Reusable tactical multiline input box with an embedded delete button
/// in the top-right corner, matching the signature box delete button.
class TacticalMultilineInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onChanged;
  final VoidCallback onClear;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const TacticalMultilineInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.minLines = 3,
    this.maxLines = 5,
    this.maxLength = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: DarkInputBox.inputStyle,
          buildCounter: (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) {
            if (maxLength == null) return null;
            final isNearLimit = currentLength >= maxLength - 20;
            return Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '$currentLength / $maxLength',
                style: TextStyle(
                  fontSize: 11.0,
                  color: isNearLimit
                      ? AppColors.amberGold
                      : AppColors.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          decoration: DarkInputBox.decoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.only(
              left: 14.0,
              right: 40.0,
              top: 12.0,
              bottom: 12.0,
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.text.trim().isEmpty) {
                return const SizedBox.shrink();
              }
              return TacticalSquareButton(
                icon: Icons.close,
                size: 28,
                iconSize: 16,
                accentColor: AppColors.errorRed,
                borderColor: AppColors.errorRed.withValues(alpha: 0.4),
                tooltip: EindbeoordelingDictionary.btnWissen,
                onPressed: onClear,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SnelselectieButton extends StatelessWidget {
  final VoidCallback onTap;

  const SnelselectieButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: EindbeoordelingDictionary.tooltipSnelselectie,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.amberGold.withValues(alpha: 0.25),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.amberGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.amberGoldBorder,
              width: 1.0,
            ),
          ),
          child: const Icon(
            Icons.lightbulb_outline_rounded,
            size: 15,
            color: AppColors.amberGold,
          ),
        ),
      ),
    );
  }
}

class RemediationBanner extends StatelessWidget {
  const RemediationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColors.terracotta.withValues(alpha: 0.16),
          const Color(0xFF141414),
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.terracottaBorder, width: 1.0),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.terracotta, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              EindbeoordelingDictionary.bannerRemediation3Months,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Color(0xFFFFB4A2),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
