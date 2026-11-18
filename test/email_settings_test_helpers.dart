import 'dart:async';
import 'package:hvac_app/features/email_delivery/data/email_settings_repository.dart';
import 'package:hvac_app/features/email_delivery/data/email_settings_model.dart';
import 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart';

// Re-export so the test file only needs one import for helpers + store.
export 'package:hvac_app/features/email_delivery/data/secure_credential_store.dart'
    show MemorySecureCredentialStore;

class FakeClearRepository extends EmailSettingsRepository {
  bool clearCalled = false;
  EmailSettings currentSettings = const EmailSettings(
    smtpState: 'configured',
    username: 'clearme@gmail.com',
    autoSend: true,
  );

  FakeClearRepository({required super.db, required super.secureStore});

  @override
  Future<void> clearSettings() async {
    clearCalled = true;
    currentSettings = const EmailSettings(
      smtpState: 'unconfigured',
      autoSend: false,
    );
  }

  @override
  Future<EmailSettings> loadSettings() async => currentSettings;
}

class FailingDeleteStore extends MemorySecureCredentialStore {
  FailingDeleteStore({super.initialPassword});

  @override
  Future<void> deletePassword() async =>
      throw StateError('Simulated KeyStore failure during delete');
}

class FailingClearRepository extends EmailSettingsRepository {
  final FailingDeleteStore failingStore;
  EmailSettings currentSettings = const EmailSettings(
    smtpState: 'configured',
    username: 'stale.user@gmail.com',
    autoSend: true,
  );

  FailingClearRepository({required super.db, required this.failingStore})
      : super(secureStore: failingStore);

  @override
  Future<void> clearSettings() async {
    currentSettings = const EmailSettings(
      smtpState: 'clearing',
      username: '',
      autoSend: false,
    );
    await failingStore.deletePassword();
  }

  @override
  Future<EmailSettings> loadSettings() async => currentSettings;

  @override
  Future<EmailSettings> getPersistedSettings() async => currentSettings;
}

class DelayedClearRepository extends EmailSettingsRepository {
  final Completer<void> completer = Completer<void>();
  EmailSettings currentSettings = const EmailSettings(
    smtpState: 'configured',
    username: 'delayed.user@gmail.com',
    autoSend: true,
  );

  DelayedClearRepository({required super.db, required super.secureStore});

  @override
  Future<void> clearSettings() async {
    await completer.future;
    currentSettings = const EmailSettings(
      smtpState: 'unconfigured',
      autoSend: false,
    );
  }

  @override
  Future<EmailSettings> loadSettings() async => currentSettings;
}

/// Repository that fails on its first [clearSettings] call, then on subsequent
/// calls waits for [completer] before succeeding. Use this to exercise the
/// retry-in-progress guard: fail once to surface the Retry button, then hold
/// the retry future with [completer] to verify overlapping operations are blocked.
class FailThenDelayRepository extends EmailSettingsRepository {
  bool _firstCallDone = false;
  final Completer<void> completer = Completer<void>();
  EmailSettings currentSettings = const EmailSettings(
    smtpState: 'configured',
    username: 'retry.user@gmail.com',
    autoSend: true,
  );

  FailThenDelayRepository({required super.db, required super.secureStore});

  @override
  Future<void> clearSettings() async {
    if (!_firstCallDone) {
      // Simulate SQLite setting 'clearing' state before the credential error.
      currentSettings = const EmailSettings(
        smtpState: 'clearing',
        username: '',
        autoSend: false,
      );
      _firstCallDone = true;
      throw StateError('Simulated first-clear failure');
    }
    // Second call: wait until the completer is signalled.
    await completer.future;
    currentSettings = const EmailSettings(
      smtpState: 'unconfigured',
      autoSend: false,
    );
  }

  @override
  Future<EmailSettings> loadSettings() async => currentSettings;

  @override
  Future<EmailSettings> getPersistedSettings() async => currentSettings;
}
