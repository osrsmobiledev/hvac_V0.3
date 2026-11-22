import '../../../app/localization/email_delivery_dictionary.dart';

/// Recipient category used in `email_delivery_jobs.recipient_type`.
enum RecipientType {
  customer('customer'),
  technician('technician');

  final String value;
  const RecipientType(this.value);
}

/// Result of creating queued email delivery jobs.
enum EmailQueueResult {
  /// One or more email jobs were newly inserted into the queue.
  queued,

  /// Jobs were already in the queue (skipped as idempotent duplicates).
  alreadyQueued,

  /// No recipients were selected or available; no jobs created.
  skipped,
}

/// Data needed to create a queued email delivery job.
class EmailJobSpec {
  final int visitId;
  final RecipientType recipientType;
  final String recipientName;
  final String recipientEmail;
  final String subject;
  final String bodyText;
  final String pdfPath;

  const EmailJobSpec({
    required this.visitId,
    required this.recipientType,
    required this.recipientName,
    required this.recipientEmail,
    required this.subject,
    required this.bodyText,
    required this.pdfPath,
  });

  /// Factory helper building recipient job specifications for visit finalization.
  static List<EmailJobSpec> buildJobs({
    required int visitId,
    required String pdfPath,
    required bool sendToCustomer,
    required String customerName,
    required String customerEmail,
    required bool sendToTechnician,
    required String technicianEmail,
    required String attestNumber,
  }) =>
      [
        if (sendToCustomer && customerEmail.isNotEmpty)
          EmailJobSpec(
            visitId: visitId,
            recipientType: RecipientType.customer,
            recipientName: customerName,
            recipientEmail: customerEmail,
            subject: EmailDeliveryDictionary.emailSubject(attestNumber),
            bodyText: EmailDeliveryDictionary.emailBodyCustomer(attestNumber),
            pdfPath: pdfPath,
          ),
        if (sendToTechnician && technicianEmail.isNotEmpty)
          EmailJobSpec(
            visitId: visitId,
            recipientType: RecipientType.technician,
            recipientName: 'Technicus',
            recipientEmail: technicianEmail,
            subject: EmailDeliveryDictionary.emailSubject(attestNumber,
                isCopy: true),
            bodyText: EmailDeliveryDictionary.emailBodyTechnician,
            pdfPath: pdfPath,
          ),
      ];
}
