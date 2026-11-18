import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/tactical_select_button.dart';
import '../../certificate_draft/ui/widgets/dark_text_form_field.dart';
import '../data/email_settings_model.dart';
import 'email_settings_notifier.dart';

/// Selection toggle row for choosing between Gmail preset and Custom SMTP.
class EmailProviderToggle extends StatelessWidget {
  final SmtpProviderType current;
  final ValueChanged<SmtpProviderType> onSelected;

  const EmailProviderToggle({
    super.key,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TacticalSelectButton(
            title: EmailDeliveryDictionary.providerGmail,
            isSelected: current == SmtpProviderType.gmail,
            onTap: () => onSelected(SmtpProviderType.gmail),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TacticalSelectButton(
            title: EmailDeliveryDictionary.providerCustom,
            isSelected: current == SmtpProviderType.custom,
            onTap: () => onSelected(SmtpProviderType.custom),
          ),
        ),
      ],
    );
  }
}

/// Custom SMTP host and port input row.
class EmailCustomHostPortRow extends StatelessWidget {
  final TextEditingController hostController;
  final TextEditingController portController;

  const EmailCustomHostPortRow({
    super.key,
    required this.hostController,
    required this.portController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DarkTextFormField(
            label: EmailDeliveryDictionary.hostLabel,
            hint: EmailDeliveryDictionary.hostHint,
            controller: hostController,
            keyboardType: TextInputType.url,
            onChanged: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: DarkTextFormField(
            label: EmailDeliveryDictionary.portLabel,
            hint: '465',
            controller: portController,
            keyboardType: TextInputType.number,
            onChanged: () {},
          ),
        ),
      ],
    );
  }
}

/// Selection toggle row for choosing between SSL/TLS (465) and STARTTLS (587).
class EmailEncryptionToggle extends StatelessWidget {
  final bool useSsl;
  final ValueChanged<bool> onSelected;

  const EmailEncryptionToggle({
    super.key,
    required this.useSsl,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TacticalSelectButton(
            title: EmailDeliveryDictionary.sslTlsOption,
            isSelected: useSsl,
            onTap: () => onSelected(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TacticalSelectButton(
            title: EmailDeliveryDictionary.startTlsOption,
            isSelected: !useSsl,
            onTap: () => onSelected(false),
          ),
        ),
      ],
    );
  }
}

/// Password input field with visibility toggle.
class EmailPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasSavedPassword;
  final bool isPasswordVisible;
  final bool readOnly;
  final VoidCallback onToggleVisibility;

  const EmailPasswordField({
    super.key,
    required this.controller,
    required this.hasSavedPassword,
    required this.isPasswordVisible,
    required this.readOnly,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final hint = hasSavedPassword
        ? EmailDeliveryDictionary.passwordSavedPlaceholder
        : EmailDeliveryDictionary.passwordHint;

    return DarkTextFormField(
      label: EmailDeliveryDictionary.passwordLabel,
      hint: hint,
      controller: controller,
      obscureText: !isPasswordVisible,
      readOnly: readOnly,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: readOnly ? null : onToggleVisibility,
      ),
      onChanged: () {},
    );
  }
}

/// Helper note for Gmail app password guidance.
class EmailGmailHelpText extends StatelessWidget {
  const EmailGmailHelpText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        EmailDeliveryDictionary.gmailHelpText,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Container with auto-send and copy-technician switches.
class EmailSwitchTiles extends StatelessWidget {
  final EmailSettings settings;
  final EmailSettingsNotifier notifier;
  final bool isEnabled;

  const EmailSwitchTiles({
    super.key,
    required this.settings,
    required this.notifier,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        isEnabled && settings.smtpState != 'clearing' && !notifier.isClearing;

    return Material(
      color: const Color(0xFF101010),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF222222)),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text(
              EmailDeliveryDictionary.autoSendLabel,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: const Text(
              EmailDeliveryDictionary.autoSendSubtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            value: settings.autoSend,
            onChanged: active ? notifier.setAutoSend : null,
          ),
          const Divider(height: 1, color: Color(0xFF222222)),
          SwitchListTile.adaptive(
            title: const Text(
              EmailDeliveryDictionary.copyTechnicianLabel,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: const Text(
              EmailDeliveryDictionary.copyTechnicianSubtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            value: settings.copyTechnician,
            onChanged: active ? notifier.setCopyTechnician : null,
          ),
        ],
      ),
    );
  }
}
