// File: lib/features/certificate_draft/ui/tabs/eindbeoordeling/signature_exception_prompt.dart
// Responsibility: Status prompt banner when customer refuses to sign or is absent.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/eindbeoordeling_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

class SignatureExceptionPrompt extends StatelessWidget {
  final String exception;

  const SignatureExceptionPrompt({super.key, required this.exception});

  @override
  Widget build(BuildContext context) {
    final isRefused = exception == 'refused';
    final icon = isRefused ? Icons.block : Icons.person_off_outlined;
    final title = isRefused
        ? EindbeoordelingDictionary.statusKlantWeigert
        : EindbeoordelingDictionary.statusKlantAfwezig;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isRefused ? AppColors.errorRed : AppColors.amberGoldBorder,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isRefused ? AppColors.errorRed : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            EindbeoordelingDictionary.subStatutairVermeld,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
