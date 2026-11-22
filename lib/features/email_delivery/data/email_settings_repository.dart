import 'package:sqflite/sqflite.dart';

import 'email_sender_service.dart';
import 'email_settings_model.dart';
import 'secure_credential_store.dart';

/// Repository coordinating non-sensitive profile settings in SQLite and credentials in secure storage.
class EmailSettingsRepository {
  final Database _db;
  final ISecureCredentialStore _secureStore;

  EmailSettingsRepository({
    required Database db,
    required ISecureCredentialStore secureStore,
  })  : _db = db,
        _secureStore = secureStore;

  /// Loads current email settings, executing deterministic startup recovery if needed.
  Future<EmailSettings> loadSettings() async {
    try {
      await recoverCredentialsState();
    } catch (_) {
      // Preserve recovery state in SQLite if KeyStore failed during clearing
    }

    final rows = await _db.query(
      'technician_profile',
      limit: 1,
    );

    final password = await _secureStore.getPassword().catchError((_) => null);
    final hasPassword = password != null && password.isNotEmpty;

    if (rows.isEmpty) {
      return EmailSettings(hasPassword: hasPassword);
    }

    return EmailSettings.fromMap(rows.first, hasPassword: hasPassword);
  }

  /// Returns persisted settings directly from SQLite without running KeyStore recovery.
  Future<EmailSettings> getPersistedSettings() async {
    final rows = await _db.query('technician_profile', limit: 1);
    final password = await _secureStore.getPassword().catchError((_) => null);
    final hasPassword = password != null && password.isNotEmpty;
    if (rows.isEmpty) return EmailSettings(hasPassword: hasPassword);
    return EmailSettings.fromMap(rows.first, hasPassword: hasPassword);
  }

  /// Loads the statutory technician profile email address from SQLite.
  Future<String> getProfileEmail() async {
    final rows = await _db.query(
      'technician_profile',
      columns: ['email'],
      limit: 1,
    );
    if (rows.isEmpty) return '';
    return (rows.first['email'] as String?)?.trim() ?? '';
  }

  /// Evaluates whether settings and sender address are locally complete for sending.
  Future<bool> _isLocallyComplete(EmailSettings settings) async {
    final profileEmail = await getProfileEmail();
    final validSender = EmailSenderService.resolveSenderEmail(
      settings: settings,
      profileEmail: profileEmail,
    );
    return validSender != null &&
        settings.username.trim().isNotEmpty &&
        settings.port > 0 &&
        (settings.provider == SmtpProviderType.gmail ||
            settings.host.trim().isNotEmpty);
  }

  /// Saves settings and credentials using a staged credential protocol.
  Future<void> saveSettings({
    required EmailSettings settings,
    String? newPassword,
  }) async {
    final bool hasNewPassword =
        newPassword != null && newPassword.trim().isNotEmpty;

    final isLocallyComplete = await _isLocallyComplete(settings);

    if (hasNewPassword) {
      // Step 1: Stage new secret in KeyStore (preserve exact password text)
      await _secureStore.setStagedPassword(newPassword);

      // Step 2: Mark SQLite in 'staging' state
      final stagingMap = settings.copyWith(smtpState: 'staging').toMap();
      await _upsertProfile(stagingMap);

      // Step 3: Promote staged secret in KeyStore
      await _secureStore.promoteStagedPassword();

      // Step 4: Finalize SQLite in 'configured' state if locally complete
      final finalState = isLocallyComplete ? 'configured' : 'unconfigured';
      final configuredMap = settings.copyWith(smtpState: finalState).toMap();
      await _upsertProfile(configuredMap);
    } else {
      // Non-password update
      final activePassword = await _secureStore.getPassword();
      final hasActive =
          activePassword != null && activePassword.trim().isNotEmpty;
      final targetState =
          hasActive && isLocallyComplete ? 'configured' : settings.smtpState;

      final updateMap = settings.copyWith(smtpState: targetState).toMap();
      await _upsertProfile(updateMap);
    }
  }

  /// Clears SMTP settings and securely deletes stored credentials with crash safety.
  Future<void> clearSettings() async {
    // Step 1: Persist 'clearing' state and reset SMTP fields in SQLite.
    // Preserves statutory company email and technician-copy preference.
    final clearingMap = <String, dynamic>{
      'smtp_provider': 'gmail',
      'smtp_host': '',
      'smtp_port': 465,
      'smtp_username': '',
      'smtp_use_ssl': 1,
      'email_auto_send': 0,
      'smtp_state': 'clearing',
    };
    await _upsertProfile(clearingMap);

    // Step 2: Idempotently delete active and staged passwords in secure storage.
    await _secureStore.deletePassword();

    // Step 3: Finalize SQLite state as 'unconfigured'.
    final finalizedMap = <String, dynamic>{
      'smtp_state': 'unconfigured',
    };
    await _upsertProfile(finalizedMap);
  }

  /// Deterministically recovers credential state if an interruption occurred mid-save or mid-clear.
  Future<void> recoverCredentialsState() async {
    final rows = await _db.query(
      'technician_profile',
      limit: 1,
    );
    if (rows.isEmpty) {
      final orphanedStaged = await _secureStore.getStagedPassword();
      if (orphanedStaged != null) {
        await _secureStore.discardStagedPassword();
      }
      return;
    }

    final currentState = rows.first['smtp_state'] as String? ?? 'unconfigured';
    final rowId = rows.first['id'];

    if (currentState == 'clearing') {
      await _secureStore.deletePassword();
      await _db.update(
        'technician_profile',
        {'smtp_state': 'unconfigured'},
        where: 'id = ?',
        whereArgs: [rowId],
      );
    } else if (currentState == 'staging') {
      final staged = await _secureStore.getStagedPassword();
      if (staged != null && staged.trim().isNotEmpty) {
        await _secureStore.promoteStagedPassword();
        final persisted = EmailSettings.fromMap(rows.first, hasPassword: true);
        final isLocallyComplete = await _isLocallyComplete(persisted);
        final activePassword = await _secureStore.getPassword();
        final hasActive =
            activePassword != null && activePassword.trim().isNotEmpty;
        final targetState =
            hasActive && isLocallyComplete ? 'configured' : 'unconfigured';
        await _db.update(
          'technician_profile',
          {'smtp_state': targetState},
          where: 'id = ?',
          whereArgs: [rowId],
        );
      } else {
        // Missing staged password: never treat old active password as match for new settings.
        await _db.update(
          'technician_profile',
          {'smtp_state': 'needs_attention'},
          where: 'id = ?',
          whereArgs: [rowId],
        );
      }
    } else if (currentState == 'configured') {
      final activePassword = await _secureStore.getPassword();
      if (activePassword == null || activePassword.trim().isEmpty) {
        await _db.update(
          'technician_profile',
          {'smtp_state': 'needs_attention'},
          where: 'id = ?',
          whereArgs: [rowId],
        );
      }
    }

    // Discard orphaned staged key without changing active password or existing settings
    if (currentState != 'staging') {
      final orphanedStaged = await _secureStore.getStagedPassword();
      if (orphanedStaged != null) {
        await _secureStore.discardStagedPassword();
      }
    }
  }

  /// Retrieves the active password from secure storage.
  Future<String?> getPassword() async => _secureStore.getPassword();

  /// Updates technician smtp_state (e.g. 'needs_attention' on auth failure).
  Future<void> updateSmtpState(String state) async {
    await _db.update(
      'technician_profile',
      {'smtp_state': state, 'updated_at': DateTime.now().toIso8601String()},
    );
  }

  Future<void> _upsertProfile(Map<String, dynamic> smtpFields) async {
    final rows =
        await _db.query('technician_profile', columns: ['id'], limit: 1);
    if (rows.isEmpty) {
      final now = DateTime.now().toIso8601String();
      await _db.insert('technician_profile', {
        'company_name': '',
        'kbo_number': '',
        'created_at': now,
        'updated_at': now,
        ...smtpFields,
      });
    } else {
      await _db.update(
        'technician_profile',
        {...smtpFields, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [rows.first['id'] as int],
      );
    }
  }
}
