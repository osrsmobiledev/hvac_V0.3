import 'package:flutter/services.dart';

/// Formatter that automatically capitalizes the first letter of each word
/// (after spaces, hyphens, and apostrophes) in real time.
///
/// Ensures auto-capitalization works consistently across all keyboards,
/// including PC/hardware keyboards on emulators where soft-keyboard
/// [TextCapitalization] signals may be bypassed.
class CapitalizeWordsInputFormatter extends TextInputFormatter {
  const CapitalizeWordsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final text = newValue.text;
    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (capitalizeNext && RegExp(r'[a-zA-Z\u00C0-\u017F]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        if (char == ' ' || char == '-' || char == "'") {
          capitalizeNext = true;
        }
      }
    }

    final formatted = buffer.toString();
    return newValue.copyWith(text: formatted);
  }
}
