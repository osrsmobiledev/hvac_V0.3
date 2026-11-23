import 'package:flutter/material.dart';
import '../../../app/localization/email_delivery_dictionary.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import 'customer_recipient_card.dart';
import 'email_custom_note_input.dart';
import 'technician_recipient_card.dart';

/// Pure layout widget presenting customer and technician recipient options.
/// Customer email is read directly from the Tab 4 snapshot.
class RecipientDialogContent extends StatelessWidget {
  final String customerName;
  final String customerEmail;
  final bool hasInitialCustomerEmail;
  final bool sendCustomer;
  final ValueChanged<bool?>? onSendCustomerChanged;
  final bool hasTechnicianEmail;
  final String technicianEmail;
  final bool copyTechnician;
  final ValueChanged<bool?>? onCopyTechnicianChanged;
  final TextEditingController noteController;

  const RecipientDialogContent({
    super.key,
    required this.customerName,
    required this.customerEmail,
    required this.hasInitialCustomerEmail,
    required this.sendCustomer,
    required this.onSendCustomerChanged,
    required this.hasTechnicianEmail,
    required this.technicianEmail,
    required this.copyTechnician,
    required this.onCopyTechnicianChanged,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            EmailDeliveryDictionary.recipientDialogIntro,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          CustomerRecipientCard(
            name: customerName,
            email: customerEmail,
            hasEmail: hasInitialCustomerEmail,
            sendCustomer: sendCustomer,
            onChanged: onSendCustomerChanged,
          ),
          if (hasTechnicianEmail) ...[
            const SizedBox(height: 12),
            TechnicianRecipientCard(
              email: technicianEmail,
              copyTechnician: copyTechnician,
              onChanged: onCopyTechnicianChanged,
            ),
          ],
          if (customerEmail.trim().isNotEmpty && sendCustomer) ...[
            const SizedBox(height: 12),
            EmailCustomNoteInput(controller: noteController),
          ],
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  EmailDeliveryDictionary.finalizeLaterHint,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
