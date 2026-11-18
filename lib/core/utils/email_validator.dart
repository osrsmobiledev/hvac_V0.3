/// Pure Dart utility for standard email address syntax validation.
///
/// Shared across data services and UI formatters to prevent duplicate rules
/// and avoid leaking Flutter UI dependencies into the data layer.
abstract final class EmailAddressValidator {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns true if [email] conforms to the standard email address syntax format.
  static bool isValid(String? email) {
    if (email == null) return false;
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;
    return _emailRegex.hasMatch(trimmed);
  }
}
