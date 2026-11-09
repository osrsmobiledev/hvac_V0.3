import 'package:flutter/material.dart';

/// Helper utilities for parsing, validating, and calculating visit working hours (Arbeidsduur).
class TimeValidationHelper {
  TimeValidationHelper._();

  /// Parses a 24-hour time string ('HH:mm') into a [TimeOfDay].
  static TimeOfDay? parse(String? text) {
    if (text == null || text.trim().isEmpty || !text.contains(':')) return null;
    final parts = text.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }

  /// Calculates the suggested end time (1 hour after [startTimeStr]).
  /// Falls back to [TimeOfDay.now()] if [startTimeStr] is empty or invalid.
  static TimeOfDay suggestedEndTime(String? startTimeStr) {
    final start = parse(startTimeStr);
    if (start != null) {
      return TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
    }
    return TimeOfDay.now();
  }

  /// Validates that [value] is a non-empty start time.
  static String? validateStartTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Starttijd is verplicht';
    }
    return null;
  }

  /// Validates that [endValue] is non-empty and strictly later than [startValue].
  static String? validateEndTime(String? endValue, String? startValue) {
    if (endValue == null || endValue.trim().isEmpty) {
      return 'Eindtijd is verplicht';
    }
    final start = parse(startValue);
    final end = parse(endValue);
    if (start != null && end != null) {
      final startMin = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;
      if (endMin <= startMin) {
        return 'Moet na starttijd liggen';
      }
    }
    return null;
  }

  /// Tactical dark date picker dialog for visit maintenance date.
  static Future<void> pickDate(
    BuildContext context,
    TextEditingController controller,
    VoidCallback onSelected,
  ) async {
    FocusScope.of(context).unfocus();
    final cur = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: cur,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE5A93C),
            onPrimary: Colors.black,
            surface: Color(0xFF141414),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$y-$m-$d';
      onSelected();
    }
  }
}
