/// Supported outbound SMTP provider presets.
enum SmtpProviderType {
  gmail('gmail'),
  custom('custom');

  final String value;
  const SmtpProviderType(this.value);

  static SmtpProviderType fromString(String? raw) {
    if (raw == 'custom') return SmtpProviderType.custom;
    return SmtpProviderType.gmail;
  }
}

/// Strongly typed outcomes of an SMTP connection preflight test.
enum SmtpConnectionResult {
  success,
  authenticationFailed,
  networkTimeout,
  socketError,
  tlsHandshakeError,
  configurationError,
  serverError,
}

/// Domain model representing outbound SMTP configuration stored in `technician_profile`.
class EmailSettings {
  final SmtpProviderType provider;
  final String host;
  final int port;
  final String username;
  final bool useSsl;
  final bool autoSend;
  final bool copyTechnician;
  final String smtpState;
  final bool hasPassword;

  static const defaults = EmailSettings();

  const EmailSettings({
    this.provider = SmtpProviderType.gmail,
    this.host = 'smtp.gmail.com',
    this.port = 465,
    this.username = '',
    this.useSsl = true,
    this.autoSend = true,
    this.copyTechnician = true,
    this.smtpState = 'unconfigured',
    this.hasPassword = false,
  });

  bool get isConfigured => smtpState == 'configured';
  bool get needsAttention => smtpState == 'needs_attention';

  EmailSettings copyWith({
    SmtpProviderType? provider,
    String? host,
    int? port,
    String? username,
    bool? useSsl,
    bool? autoSend,
    bool? copyTechnician,
    String? smtpState,
    bool? hasPassword,
  }) {
    return EmailSettings(
      provider: provider ?? this.provider,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      useSsl: useSsl ?? this.useSsl,
      autoSend: autoSend ?? this.autoSend,
      copyTechnician: copyTechnician ?? this.copyTechnician,
      smtpState: smtpState ?? this.smtpState,
      hasPassword: hasPassword ?? this.hasPassword,
    );
  }

  factory EmailSettings.fromMap(
    Map<String, dynamic> map, {
    bool hasPassword = false,
  }) {
    final provider =
        SmtpProviderType.fromString(map['smtp_provider'] as String?);
    final defaultHost =
        provider == SmtpProviderType.gmail ? 'smtp.gmail.com' : '';
    final defaultPort = provider == SmtpProviderType.gmail ? 465 : 587;

    return EmailSettings(
      provider: provider,
      host: (map['smtp_host'] as String?)?.trim().isNotEmpty == true
          ? (map['smtp_host'] as String).trim()
          : defaultHost,
      port: (map['smtp_port'] as int?) ?? defaultPort,
      username: (map['smtp_username'] as String?) ?? '',
      useSsl: (map['smtp_use_ssl'] as int? ?? 1) == 1,
      autoSend: (map['email_auto_send'] as int? ?? 1) == 1,
      copyTechnician: (map['email_copy_technician'] as int? ?? 1) == 1,
      smtpState: (map['smtp_state'] as String?) ?? 'unconfigured',
      hasPassword: hasPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'smtp_provider': provider.value,
      'smtp_host': host,
      'smtp_port': port,
      'smtp_username': username,
      'smtp_use_ssl': useSsl ? 1 : 0,
      'email_auto_send': autoSend ? 1 : 0,
      'email_copy_technician': copyTechnician ? 1 : 0,
      'smtp_state': smtpState,
    };
  }
}
