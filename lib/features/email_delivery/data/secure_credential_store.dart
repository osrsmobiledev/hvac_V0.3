import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for secure credential storage (Android KeyStore / iOS Keychain).
abstract interface class ISecureCredentialStore {
  /// Retrieves the active SMTP password.
  Future<String?> getPassword();

  /// Writes a new password to a temporary staged key without touching active credentials.
  Future<void> setStagedPassword(String password);

  /// Retrieves the currently staged password, if any.
  Future<String?> getStagedPassword();

  /// Promotes the staged password to active and deletes the stage key.
  Future<void> promoteStagedPassword();

  /// Discards the staged password without modifying the active password.
  Future<void> discardStagedPassword();

  /// Deletes all stored SMTP credentials.
  Future<void> deletePassword();
}

/// Secure credential store wrapping [FlutterSecureStorage].
class SecureCredentialStore implements ISecureCredentialStore {
  static const String _activePasswordKey = 'smtp_password';
  static const String _stagedPasswordKey = 'smtp_password_staged';

  final FlutterSecureStorage _storage;

  const SecureCredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> getPassword() async {
    return _storage.read(key: _activePasswordKey);
  }

  @override
  Future<void> setStagedPassword(String password) async {
    await _storage.write(key: _stagedPasswordKey, value: password);
  }

  @override
  Future<String?> getStagedPassword() async {
    return _storage.read(key: _stagedPasswordKey);
  }

  @override
  Future<void> promoteStagedPassword() async {
    final staged = await _storage.read(key: _stagedPasswordKey);
    if (staged == null || staged.isEmpty) {
      throw StateError(
          'Cannot promote staged password: staged key is missing or empty.');
    }
    await _storage.write(key: _activePasswordKey, value: staged);
    await _storage.delete(key: _stagedPasswordKey);
  }

  @override
  Future<void> discardStagedPassword() async {
    await _storage.delete(key: _stagedPasswordKey);
  }

  @override
  Future<void> deletePassword() async {
    await _storage.delete(key: _activePasswordKey);
    await _storage.delete(key: _stagedPasswordKey);
  }
}

/// In-memory credential store for fast, deterministic unit and widget testing.
class MemorySecureCredentialStore implements ISecureCredentialStore {
  String? _activePassword;
  String? _stagedPassword;

  MemorySecureCredentialStore({String? initialPassword})
      : _activePassword = initialPassword;

  @override
  Future<String?> getPassword() async => _activePassword;

  @override
  Future<void> setStagedPassword(String password) async {
    _stagedPassword = password;
  }

  @override
  Future<String?> getStagedPassword() async => _stagedPassword;

  @override
  Future<void> promoteStagedPassword() async {
    if (_stagedPassword == null || _stagedPassword!.isEmpty) {
      throw StateError(
          'Cannot promote staged password: staged key is missing or empty.');
    }
    _activePassword = _stagedPassword;
    _stagedPassword = null;
  }

  @override
  Future<void> discardStagedPassword() async {
    _stagedPassword = null;
  }

  @override
  Future<void> deletePassword() async {
    _activePassword = null;
    _stagedPassword = null;
  }
}
