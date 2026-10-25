import 'package:flutter/material.dart';
import '../localization/app_dictionary.dart';
import '../theme/app_colors.dart';

/// Placeholder displayed when an unbuilt applet or management section is selected.
class AppletContentPlaceholder extends StatelessWidget {
  final String appBarTitle;
  final String? description;
  final VoidCallback onBackToHome;

  const AppletContentPlaceholder({
    super.key,
    required this.appBarTitle,
    this.description,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.carbonCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.hairlineBorder),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 26,
                  color: AppColors.amberGold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appBarTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description ?? AppDictionary.placeholderUnderConstruction,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onBackToHome,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(AppDictionary.btnBackToDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
