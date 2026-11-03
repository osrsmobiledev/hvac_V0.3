// File: lib/features/certificate_draft/ui/widgets/verbrandingsattest_loading_overlay.dart
// Responsibility: Tactical BO2 HUD loading overlay shown during initial applet pre-warming.

import 'package:flutter/material.dart';
import 'package:hvac_app/app/localization/app_dictionary.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/app/theme/app_theme.dart';

/// Fullscreen tactical HUD loading overlay displayed while the combustion certificate
/// workflow pre-warms its SQLite data cache and renders all 7 workflow tabs.
class VerbrandingsattestLoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const VerbrandingsattestLoadingOverlay({
    super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isLoading
          ? Container(
              key: const ValueKey('applet_loading_overlay'),
              width: double.infinity,
              height: double.infinity,
              color: AppColors.oledBase,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36.0,
                      height: 36.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.amberGold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      'VERBRANDINGSATTEST VLAANDEREN',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                        color: AppColors.amberGold.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      AppDictionary.loadingAppletTitle,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      AppDictionary.loadingAppletSubtitle,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('applet_loaded')),
    );
  }
}
