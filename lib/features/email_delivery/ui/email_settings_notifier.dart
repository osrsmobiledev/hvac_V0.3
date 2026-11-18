import 'package:flutter/material.dart';

import '../../../app/localization/email_delivery_dictionary.dart';
import '../data/email_sender_service.dart';
import '../data/email_settings_model.dart';
import '../data/email_settings_repository.dart';

/// ViewModel for Outbound SMTP settings.
/// Guards prevent overlapping async operations (clear vs test vs save).
class EmailSettingsNotifier extends ChangeNotifier {
  final EmailSettingsRepository _repository;
  final EmailSenderService _senderService;

  EmailSettings _settings = EmailSettings.defaults;
  bool _isLoading = true;
  bool _isTesting = false;
  bool _isSaving = false;
  bool _isClearing = false;
  bool _isPasswordVisible = false;

  SmtpConnectionResult? _lastTestResult;
  String? _saveSuccessMessage;
  String? _saveErrorMessage;
  String? _clearErrorMessage;

  final hostController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  EmailSettingsNotifier({
    required EmailSettingsRepository repository,
    required EmailSenderService senderService,
  })  : _repository = repository,
        _senderService = senderService;

  EmailSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isTesting => _isTesting;
  bool get isSaving => _isSaving;
  bool get isClearing => _isClearing;
  bool get isPasswordVisible => _isPasswordVisible;

  SmtpConnectionResult? get lastTestResult => _lastTestResult;
  bool get isTestSuccess => _lastTestResult == SmtpConnectionResult.success;
  String? get testResultMessage => _lastTestResult != null
      ? EmailDeliveryDictionary.messageForConnectionResult(_lastTestResult!)
      : null;

  String? get saveSuccessMessage => _saveSuccessMessage;
  String? get saveErrorMessage => _saveErrorMessage;
  String? get clearErrorMessage => _clearErrorMessage;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _repository.loadSettings();
      _syncControllers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncControllers() {
    hostController.text = _settings.host;
    portController.text = _settings.port.toString();
    usernameController.text = _settings.username;
    passwordController.clear();
  }

  void setProvider(SmtpProviderType provider) {
    if (_settings.provider == provider) return;
    final isGmail = provider == SmtpProviderType.gmail;
    _settings = _settings.copyWith(
      provider: provider,
      host: isGmail ? 'smtp.gmail.com' : '',
      port: isGmail ? 465 : 587,
      useSsl: isGmail,
    );
    hostController.text = _settings.host;
    portController.text = _settings.port.toString();
    notifyListeners();
  }

  void setUseSsl(bool useSsl) {
    _settings = _settings.copyWith(
      useSsl: useSsl,
      port: useSsl ? 465 : 587,
    );
    portController.text = useSsl ? '465' : '587';
    notifyListeners();
  }

  void setAutoSend(bool value) {
    _settings = _settings.copyWith(autoSend: value);
    notifyListeners();
  }

  void setCopyTechnician(bool value) {
    _settings = _settings.copyWith(copyTechnician: value);
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Tests the current SMTP connection. Blocked while a clear is running.
  Future<bool> testConnection() async {
    if (_isClearing) return false;
    _isTesting = true;
    _lastTestResult = null;
    notifyListeners();

    try {
      final currentSettings = _buildCurrentSettings();
      final enteredPassword = passwordController.text;
      final passwordToUse = enteredPassword.trim().isNotEmpty
          ? enteredPassword
          : (await _repository.getPassword() ?? '');
      if (currentSettings.username.isEmpty || passwordToUse.trim().isEmpty) {
        _lastTestResult = SmtpConnectionResult.configurationError;
        _isTesting = false;
        notifyListeners();
        return false;
      }

      final result = await _senderService.testConnection(
        settings: currentSettings,
        password: passwordToUse,
      );
      _lastTestResult = result;
      return result == SmtpConnectionResult.success;
    } catch (_) {
      _lastTestResult = SmtpConnectionResult.serverError;
      return false;
    } finally {
      _isTesting = false;
      notifyListeners();
    }
  }

  /// Saves current SMTP settings. Blocked while a clear is running.
  Future<bool> saveSettings() async {
    if (_isClearing) return false;
    _isSaving = true;
    _saveSuccessMessage = null;
    _saveErrorMessage = null;
    notifyListeners();

    try {
      final currentSettings = _buildCurrentSettings();
      final enteredPassword = passwordController.text;
      final hasEnteredPassword = enteredPassword.trim().isNotEmpty;

      if (currentSettings.provider == SmtpProviderType.custom &&
          currentSettings.host.isEmpty) {
        _saveErrorMessage = EmailDeliveryDictionary.validationMissingHost;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      final profileEmail = await _repository.getProfileEmail();
      final validSender = EmailSenderService.resolveSenderEmail(
        settings: currentSettings,
        profileEmail: profileEmail,
      );
      if (currentSettings.username.trim().isNotEmpty && validSender == null) {
        _saveErrorMessage = EmailDeliveryDictionary.invalidSenderError;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      await _repository.saveSettings(
        settings: currentSettings,
        newPassword: hasEnteredPassword ? enteredPassword : null,
      );

      _settings = await _repository.loadSettings();
      _saveSuccessMessage = EmailDeliveryDictionary.saveSettingsSuccess;
      passwordController.clear();
      return true;
    } catch (_) {
      _saveErrorMessage = EmailDeliveryDictionary.saveSettingsError;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Clears SMTP settings with crash safety.
  /// Overlapping calls (clear/test/save) are refused with an early return.
  Future<bool> clearSettings() async {
    if (_isClearing || _isTesting || _isSaving) return false;
    _isClearing = true;
    _clearErrorMessage = null;
    notifyListeners();

    try {
      await _repository.clearSettings();
      _settings = await _repository.loadSettings();
      _syncControllers();
      return true;
    } catch (_) {
      _clearErrorMessage = EmailDeliveryDictionary.clearSettingsError;
      try {
        _settings = await _repository.getPersistedSettings();
      } catch (_) {
        _settings = _settings.copyWith(
          smtpState: 'clearing',
          username: '',
          autoSend: false,
        );
      }
      _syncControllers();
      return false;
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }

  EmailSettings _buildCurrentSettings() {
    final host = _settings.provider == SmtpProviderType.gmail
        ? 'smtp.gmail.com'
        : hostController.text.trim();
    final port = int.tryParse(portController.text.trim()) ??
        (_settings.provider == SmtpProviderType.gmail ? 465 : 587);
    return _settings.copyWith(
      host: host,
      port: port,
      username: usernameController.text.trim(),
    );
  }

  @override
  void dispose() {
    hostController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
