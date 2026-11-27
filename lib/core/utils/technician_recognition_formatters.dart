// File: lib/core/utils/technician_recognition_formatters.dart
// Purpose: Formatting, normalization, and statutory validation for Flemish GV/TV certification numbers.

/// Statutory recognition number utilities for Flemish heating technicians.
///
/// In Flanders (VEKA / VLAREM II):
/// - Gas technician certification: 'GV' followed by exactly 5 digits (e.g. GV01234).
/// - Liquid fuel technician certification: 'TV' followed by exactly 5 digits (e.g. TV01234).
///
/// Technicians enter only the 5 numeric digits in the UI; the prefix is rendered visually.
abstract final class TechnicianRecognitionFormatters {
  /// Visual prefix for Gas certification field.
  static const String gvPrefix = 'GV ';

  /// Visual prefix for Liquid fuel (stookolie) certification field.
  static const String tvPrefix = 'TV ';

  /// Strips any prefix or non-digits, returning only digits (up to 5).
  static String stripPrefix(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) return '';
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    return digits.length > 5 ? digits.substring(0, 5) : digits;
  }

  /// Strips 'GV' prefix and non-digits from stored string.
  static String stripGvPrefix(String stored) => stripPrefix(stored);

  /// Strips 'TV' prefix and non-digits from stored string.
  static String stripTvPrefix(String stored) => stripPrefix(stored);

  /// Normalizes raw input to statutory format 'GV12345' for storage.
  static String normalizeGv(String raw) {
    final digits = stripPrefix(raw);
    return digits.isEmpty ? '' : 'GV$digits';
  }

  /// Normalizes raw input to statutory format 'TV12345' for storage.
  static String normalizeTv(String raw) {
    final digits = stripPrefix(raw);
    return digits.isEmpty ? '' : 'TV$digits';
  }

  /// Validates a GV certification number according to statutory length and active fuel type.
  ///
  /// When [requireRecognition] is false (e.g. standalone Schoorsteenveger in
  /// Reinigingsattest), an empty value is permitted; non-empty values must still
  /// contain 5 digits.
  static String? validateGv(
    String? value, {
    String? fuelType,
    bool isTvEmpty = true,
    bool requireRecognition = true,
  }) {
    final digits = stripPrefix(value ?? '');
    if (!requireRecognition && digits.isEmpty) {
      return null;
    }
    final isGas = fuelType == 'gas';

    if (isGas && digits.isEmpty) {
      return 'GV-nummer is verplicht voor aardgas';
    }

    if (digits.isEmpty) {
      if (fuelType == 'vloeibaar') return null;
      return isTvEmpty ? 'GV-nummer vereist' : null;
    }

    if (digits.length != 5) {
      return 'GV-nummer moet 5 cijfers zijn';
    }

    return null;
  }

  /// Validates a TV certification number according to statutory length and active fuel type.
  ///
  /// When [requireRecognition] is false (e.g. standalone Schoorsteenveger in
  /// Reinigingsattest), an empty value is permitted; non-empty values must still
  /// contain 5 digits.
  static String? validateTv(
    String? value, {
    String? fuelType,
    bool isGvEmpty = true,
    bool requireRecognition = true,
  }) {
    final digits = stripPrefix(value ?? '');
    if (!requireRecognition && digits.isEmpty) {
      return null;
    }
    final isOil = fuelType == 'vloeibaar';

    if (isOil && digits.isEmpty) {
      return 'TV-nummer is verplicht voor stookolie';
    }

    if (digits.isEmpty) {
      if (fuelType == 'gas') return null;
      return isGvEmpty ? 'TV-nummer vereist' : null;
    }

    if (digits.length != 5) {
      return 'TV-nummer moet 5 cijfers zijn';
    }

    return null;
  }
}
