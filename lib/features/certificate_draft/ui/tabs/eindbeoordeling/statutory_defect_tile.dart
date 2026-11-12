// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/statutory_defect_tile.dart
// Responsibility: Tactical card and header widgets for statutory defect selection.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/features/certificate_draft/domain/statutory_defect_preset.dart';

class StatutoryDefectHeader extends StatelessWidget {
  final String fuel;
  final String boilerType;
  final VoidCallback onClose;
  final int remainingChars;

  const StatutoryDefectHeader({
    super.key,
    required this.fuel,
    required this.boilerType,
    required this.onClose,
    this.remainingChars = 200,
  });

  @override
  Widget build(BuildContext context) {
    final fuelLabel = fuel == 'vloeibaar'
        ? 'Stookolie'
        : fuel == 'vast'
            ? 'Vaste brandstof'
            : 'Aardgas';
    final typeLabel = boilerType == 'B' ? 'Type B (Open)' : 'Type C (Gesloten)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  EindbeoordelingDictionary.modalTitleSnelselectie,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$fuelLabel • $typeLabel • $remainingChars tekens over',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.amberGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class StatutoryDefectPresetCard extends StatelessWidget {
  final StatutoryDefectPreset preset;
  final bool isSelected;
  final bool isAlreadyAdded;
  final bool isOverLimit;
  final VoidCallback? onTap;

  const StatutoryDefectPresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    this.isAlreadyAdded = false,
    this.isOverLimit = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isAlreadyAdded || isOverLimit;
    final double opacity = isAlreadyAdded ? 0.45 : (isOverLimit ? 0.35 : 1.0);

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.amberGold.withValues(alpha: 0.12)
                : const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.amberGoldBorder
                  : Colors.white.withValues(alpha: 0.12),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAlreadyAdded
                        ? Icons.check_circle_rounded
                        : (isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded),
                    color: isAlreadyAdded
                        ? Colors.white38
                        : (isSelected ? AppColors.amberGold : Colors.white38),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preset.title,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isAlreadyAdded)
                    const _StatusTag(
                      text: 'Reeds toegevoegd',
                      color: Colors.white38,
                    )
                  else if (isOverLimit)
                    const _StatusTag(
                      text: 'Max 200 tekens',
                      color: AppColors.amberGold,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _DetailLine(
                label: EindbeoordelingDictionary.lblDefectPrefix,
                text: preset.defectText,
                labelColor: const Color(0xFFFFB4A2),
              ),
              const SizedBox(height: 4),
              _DetailLine(
                label: EindbeoordelingDictionary.lblMeasurePrefix,
                text: preset.measureText,
                labelColor: const Color(0xFF80D8FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 9.5,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String text;
  final Color labelColor;

  const _DetailLine({required this.label, required this.text, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: labelColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
