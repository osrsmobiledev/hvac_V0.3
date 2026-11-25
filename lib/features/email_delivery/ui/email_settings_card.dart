import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/tactical_feedback.dart';
import '../../certificate_draft/ui/widgets/bento_main_section.dart';
import '../../certificate_draft/ui/widgets/dark_text_form_field.dart';
import '../data/email_settings_model.dart';
import 'email_banners.dart';
import 'email_clear_dialog.dart';
import 'email_settings_actions.dart';
import 'email_settings_form_sections.dart';
import 'email_settings_notifier.dart';

/// Bento Squircle HUD Card for Outbound SMTP settings.
class EmailSettingsCard extends StatelessWidget {
  final EmailSettingsNotifier notifier;

  const EmailSettingsCard({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        if (notifier.isLoading) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.amberGold),
            ),
          );
        }

        final settings = notifier.settings;
        final isClearing = settings.smtpState == 'clearing';
        final hasClearErr = isClearing || notifier.clearErrorMessage != null;

        return BentoMainSection(
          title: EmailDeliveryDictionary.cardTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasClearErr) ...[
                EmailClearingErrorBanner(
                  onRetry: () => _handleRetryClear(context),
                  enabled: !notifier.isClearing,
                ),
                const SizedBox(height: 12),
              ] else if (settings.needsAttention) ...[
                const EmailNeedsAttentionBanner(),
                const SizedBox(height: 12),
              ],
              AbsorbPointer(
                absorbing: isClearing || notifier.isClearing,
                child: Opacity(
                  opacity: isClearing ? 0.6 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EmailProviderToggle(
                        current: settings.provider,
                        onSelected: notifier.setProvider,
                      ),
                      const SizedBox(height: 12),
                      if (settings.provider == SmtpProviderType.custom) ...[
                        EmailCustomHostPortRow(
                          hostController: notifier.hostController,
                          portController: notifier.portController,
                        ),
                        const SizedBox(height: 12),
                        EmailEncryptionToggle(
                          useSsl: settings.useSsl,
                          onSelected: notifier.setUseSsl,
                        ),
                        const SizedBox(height: 12),
                      ],
                      DarkTextFormField(
                        label: EmailDeliveryDictionary.usernameLabel,
                        hint: EmailDeliveryDictionary.usernameHint,
                        controller: notifier.usernameController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: isClearing,
                        onChanged: () {},
                      ),
                      const SizedBox(height: 12),
                      EmailPasswordField(
                        controller: notifier.passwordController,
                        hasSavedPassword: settings.hasPassword,
                        isPasswordVisible: notifier.isPasswordVisible,
                        readOnly: isClearing,
                        onToggleVisibility: notifier.togglePasswordVisibility,
                      ),
                      if (settings.provider == SmtpProviderType.gmail) ...[
                        const SizedBox(height: 8),
                        const EmailGmailHelpText(),
                      ],
                      const SizedBox(height: 14),
                      EmailSwitchTiles(
                        settings: settings,
                        notifier: notifier,
                        isEnabled: !isClearing,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EmailSettingsActionButtons(
                isTesting: notifier.isTesting,
                isSaving: notifier.isSaving,
                canAct: !notifier.isTesting &&
                    !notifier.isSaving &&
                    !isClearing &&
                    !notifier.isClearing,
                onTest: () => _handleTestConnection(context),
                onSave: () => _handleSaveSettings(context),
              ),
              if (!isClearing) ...[
                const SizedBox(height: 8),
                EmailSettingsClearButton(
                  isClearing: notifier.isClearing,
                  isEnabled: !notifier.isSaving &&
                      !notifier.isTesting &&
                      !notifier.isClearing,
                  onClear: () => _handleClearSettings(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleTestConnection(BuildContext context) async {
    final success = await notifier.testConnection();
    if (!context.mounted) return;
    final msg = success
        ? EmailDeliveryDictionary.testConnectionSuccess
        : (notifier.testResultMessage ?? EmailDeliveryDictionary.serverError);
    if (success) {
      TacticalFeedback.showSuccess(context, msg);
    } else {
      TacticalFeedback.showError(context, msg);
    }
  }

  Future<void> _handleSaveSettings(BuildContext context) async {
    final success = await notifier.saveSettings();
    if (!context.mounted) return;
    if (success) {
      TacticalFeedback.showSuccess(
        context,
        EmailDeliveryDictionary.saveSettingsSuccess,
      );
    } else {
      TacticalFeedback.showError(
        context,
        notifier.saveErrorMessage ?? EmailDeliveryDictionary.serverError,
      );
    }
  }

  Future<void> _handleClearSettings(BuildContext context) async {
    final confirmed = await showEmailClearConfirmationDialog(context);
    if (confirmed != true || !context.mounted) return;

    final success = await notifier.clearSettings();
    if (!context.mounted) return;
    _showClearResult(context, success);
  }

  Future<void> _handleRetryClear(BuildContext context) async {
    final success = await notifier.clearSettings();
    if (!context.mounted) return;
    _showClearResult(context, success);
  }

  void _showClearResult(BuildContext context, bool success) {
    if (success) {
      TacticalFeedback.showSuccess(
        context,
        EmailDeliveryDictionary.clearSettingsSuccess,
      );
    } else {
      TacticalFeedback.showError(
        context,
        notifier.clearErrorMessage ??
            EmailDeliveryDictionary.clearSettingsError,
      );
    }
  }
}
