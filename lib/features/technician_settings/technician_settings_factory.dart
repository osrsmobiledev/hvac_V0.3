import '../../core/database/app_database.dart';
import '../email_delivery/data/email_sender_service.dart';
import '../email_delivery/data/email_settings_repository.dart';
import '../email_delivery/data/secure_credential_store.dart';
import '../email_delivery/ui/email_settings_notifier.dart';

/// Applet composition point: wires database, secure storage, and services into [EmailSettingsNotifier].
Future<EmailSettingsNotifier> createTechnicianSettingsNotifier() async {
  final db = await AppDatabase.instance.database;
  final repo = EmailSettingsRepository(
    db: db,
    secureStore: const SecureCredentialStore(),
  );
  final sender = EmailSenderService();
  return EmailSettingsNotifier(
    repository: repo,
    senderService: sender,
  );
}
