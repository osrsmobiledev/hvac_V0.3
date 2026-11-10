/// Static calculations for statutory inspection intervals & remediation deadlines
/// per Flemish regulations (Art. 6 Vlaams Stooktoestellenbesluit).
abstract final class EindbeoordelingDateCalculator {
  /// Formats a DateTime to standard Flemish DD/MM/YYYY.
  static String formatDateDmy(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return '$day/$month/$year';
  }

  /// Parses standard ISO YYYY-MM-DD or DD/MM/YYYY into DateTime.
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final p = raw.trim().split(RegExp(r'[-/]'));
    if (p.length != 3) return null;
    final y = p[0].length == 4 ? int.tryParse(p[0]) : int.tryParse(p[2]);
    final m = int.tryParse(p[1]) ?? 1;
    final d = p[0].length == 4 ? int.tryParse(p[2]) : int.tryParse(p[0]);
    return DateTime(y ?? DateTime.now().year, m, d ?? 1);
  }

  /// Calculates statutory next inspection date per Flemish regulations:
  /// - Gas: +2 years from inspection date
  /// - Liquid (Stookolie) & Solid: +1 year from inspection date
  /// Returns null if fuelType is empty (zero fake defaults).
  static String? calculateStatutoryNextDate({
    required String fuelType,
    DateTime? fromDate,
  }) {
    final trimmed = fuelType.trim();
    if (trimmed.isEmpty) return null;
    final base = fromDate ?? DateTime.now();
    final years = trimmed.toLowerCase().contains('gas') ? 2 : 1;
    return formatDateDmy(DateTime(base.year + years, base.month, base.day));
  }

  /// Calculates the statutory 3-month remediation deadline date
  /// (Art. 6 Vlaams Stooktoestellenbesluit for non-compliant boilers).
  static String calculateRemediationNextDate({DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final nextDate = DateTime(base.year, base.month + 3, base.day);
    return formatDateDmy(nextDate);
  }

  /// Resolves the next inspection date based on current compliance, fuel type, and prior state.
  static String resolveNextDate({
    required bool willFail,
    required bool wasFailing,
    required bool isCompliant,
    required bool hasFuel,
    required String fuelType,
    required String? currentDate,
    DateTime? visitDate,
  }) {
    if (!hasFuel) return '';
    if (willFail) {
      if (!wasFailing || currentDate == null || currentDate.isEmpty) {
        return calculateRemediationNextDate(fromDate: visitDate);
      }
      return currentDate;
    }
    if (wasFailing) {
      return isCompliant
          ? (calculateStatutoryNextDate(
                  fuelType: fuelType, fromDate: visitDate) ??
              '')
          : '';
    }
    if (isCompliant && (currentDate == null || currentDate.isEmpty)) {
      return calculateStatutoryNextDate(
              fuelType: fuelType, fromDate: visitDate) ??
          '';
    }
    if (!isCompliant) return '';
    return currentDate ?? '';
  }
}
