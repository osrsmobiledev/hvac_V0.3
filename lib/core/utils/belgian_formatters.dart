import 'package:flutter/services.dart';

/// Formatter for Belgian phone numbers: auto-strips leading zero,
/// limits to 9 digits, and formats as '4XX XX XX XX' or 'XX XX XX XX'.
class BelgianPhoneInputFormatter extends TextInputFormatter {
  const BelgianPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // If pasted with international 32, strip it (since +32 is the prefix)
    if (digits.startsWith('32') && digits.length > 9) {
      digits = digits.substring(2);
    }

    // Automatically strip leading zero so users cannot enter a double prefix (+32 0...)
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    // Belgian numbers have maximum 9 digits after +32 (mobile is 9 digits, landlines are 8-9)
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    final buffer = StringBuffer();
    if (digits.startsWith('4')) {
      for (int i = 0; i < digits.length; i++) {
        if (i == 3 || i == 5 || i == 7) buffer.write(' ');
        buffer.write(digits[i]);
      }
    } else {
      for (int i = 0; i < digits.length; i++) {
        if (i > 0 && (i == 2 || i == 4 || i == 6)) buffer.write(' ');
        buffer.write(digits[i]);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Belgian KBO / Enterprise numbers:
/// limits to 10 digits and automatically formats as '0XXX.XXX.XXX'.
class BelgianKboInputFormatter extends TextInputFormatter {
  const BelgianKboInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7) buffer.write('.');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Centralized fail-safe formatting and normalization for Belgian phone and KBO numbers.
/// Complies with Belgian statutory standards and official Flutter SDK guidelines.
abstract final class BelgianFormatters {
  /// Standard international telephone prefix for Belgium.
  static const String phonePrefix = '+32 ';

  /// Statutory enterprise and VAT prefix for Belgian companies (KBO / BTW).
  static const String kboPrefix = 'BE ';

  /// Input formatters for Belgian phone fields: auto-formats 9 digits with spaces.
  static List<TextInputFormatter> get phoneFormatters =>
      const [BelgianPhoneInputFormatter()];

  /// Input formatters for Belgian KBO numbers: auto-formats 10 digits as '0XXX.XXX.XXX'.
  static List<TextInputFormatter> get kboFormatters =>
      const [BelgianKboInputFormatter()];

  /// Formats a phone number for persistence, prepending '+32 ' if not already present.
  static String normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('+32 ')) return trimmed;
    if (trimmed.startsWith('+32')) {
      return '+32 ${trimmed.substring(3).trim()}';
    }
    if (trimmed.startsWith('0032 ')) {
      return '+32 ${trimmed.substring(5).trim()}';
    }
    if (trimmed.startsWith('0032')) {
      return '+32 ${trimmed.substring(4).trim()}';
    }
    return '$phonePrefix$trimmed';
  }

  /// Strips the international '+32' or '0032' prefix for clean UI display.
  static String stripPhonePrefix(String stored) {
    var result = stored.trim();
    if (result.startsWith('+32 ')) {
      result = result.substring(4).trim();
    } else if (result.startsWith('+32')) {
      result = result.substring(3).trim();
    } else if (result.startsWith('0032 ')) {
      result = result.substring(5).trim();
    } else if (result.startsWith('0032')) {
      result = result.substring(4).trim();
    }
    if (result.startsWith('0') && result.length > 1) {
      result = result.substring(1).trim();
    }
    return result;
  }

  /// Formats an enterprise number for persistence, prepending 'BE ' if not already present.
  static String normalizeKbo(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.toUpperCase().startsWith('BE ')) {
      return 'BE ${trimmed.substring(3).trim()}';
    }
    if (trimmed.toUpperCase().startsWith('BE')) {
      return 'BE ${trimmed.substring(2).trim()}';
    }
    return '$kboPrefix$trimmed';
  }

  /// Strips the 'BE' prefix for clean UI display.
  static String stripKboPrefix(String stored) {
    var result = stored.trim();
    if (result.toUpperCase().startsWith('BE ')) {
      result = result.substring(3).trim();
    } else if (result.toUpperCase().startsWith('BE')) {
      result = result.substring(2).trim();
    }
    return result;
  }

  /// Official validator for Belgian telephone numbers (mobile or landline).
  ///
  /// Distinguishes mobile numbers (starts with 4, exactly 9 digits) from
  /// landline numbers (starts with 1, 2, 3, 5, 6, 7, 8, 9, exactly 8 digits).
  /// Returns null if valid, or a Dutch error message if invalid.
  static String? validatePhone(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? 'Telefoonnummer is verplicht' : null;
    }

    var cleaned = text;
    if (cleaned.startsWith('+32')) {
      cleaned = cleaned.substring(3).trim();
    } else if (cleaned.startsWith('0032')) {
      cleaned = cleaned.substring(4).trim();
    }

    var digitsOnly = cleaned.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('32') && digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(2).trim();
    }
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    }

    if (digitsOnly.isEmpty) {
      return required ? 'Telefoonnummer is verplicht' : null;
    }

    // Belgian mobile: starts with 4 -> exactly 9 digits (e.g. 470 12 34 56)
    if (digitsOnly.startsWith('4')) {
      if (digitsOnly.length != 9) {
        return 'Ongeldig telefoonnummer (bv. 470 12 34 56)';
      }
      return null;
    }

    // Belgian landline: starts with 1, 2, 3, 5, 6, 7, 8, 9 -> exactly 8 digits
    if (digitsOnly.length != 8) {
      return 'Ongeldig telefoonnummer (bv. 470 12 34 56)';
    }

    return null;
  }

  /// Official validator for Belgian KBO numbers using statutory Modulo 97 checksum.
  ///
  /// Requires exactly 10 digits where check digits = 97 - (first 8 digits % 97).
  /// Returns null if valid, or a Dutch error message if invalid.
  static String? validateKbo(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? 'Ondernemingsnummer is verplicht' : null;
    }
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return 'Ondernemingsnummer moet 10 cijfers bevatten';
    }
    final body = int.tryParse(digitsOnly.substring(0, 8));
    final checksum = int.tryParse(digitsOnly.substring(8, 10));
    if (body == null || checksum == null) {
      return 'Ongeldig ondernemingsnummer';
    }
    final expectedChecksum = 97 - (body % 97);
    if (checksum != expectedChecksum) {
      return 'Ongeldig controlegetal (Modulo 97)';
    }
    return null;
  }

  /// Validator for Belgian postal codes: exactly 4 digits between 1000 and 9999.
  static String? validatePostalCode(String? value, {bool required = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Postcode is verplicht' : null;
    final code = int.tryParse(text);
    if (text.length != 4 || code == null || code < 1000 || code > 9999) {
      return 'Postcode moet 4 cijfers zijn (1000-9999)';
    }
    return null;
  }

  /// Validator for email addresses — optional by default, required when [required] is true.
  ///
  /// Uses a minimal RFC-compliant regex: requires at least one non-whitespace
  /// char before '@', a domain part, and a TLD separated by '.'.
  /// Returns null if valid, or a Dutch error message if invalid.
  static String? validateEmail(String? value, {bool required = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'E-mailadres is verplicht' : null;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Vul een geldig e-mailadres in (bv. info@firma.be)';
    }
    return null;
  }
}
