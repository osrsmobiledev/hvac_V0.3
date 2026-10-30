import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/measurement_slot_draft.dart';

/// Robust decoder for Eurolyzer flue-gas analyzer QR code payloads.
///
/// Supports semicolon/comma-delimited key-value strings, JSON structures,
/// and line-by-line instrument telemetry dumps.
abstract final class EurolyzerQrParser {
  /// Parses a raw QR payload into a [MeasurementSlotDraft].
  static MeasurementSlotDraft parse(String raw, {String slot = 'proef1'}) {
    final clean = raw.trim();
    if (clean.isEmpty) return MeasurementSlotDraft.empty(slot);

    // Try parsing as JSON first
    if (clean.startsWith('{') && clean.endsWith('}')) {
      try {
        final Map<String, dynamic> json = jsonDecode(clean);
        return _parseJson(json, slot, clean);
      } catch (e) {
        debugPrint('[EurolyzerQrParser] json parse error: $e');
      }
    }

    // Parse delimited key-value tokens (lines or ; or ,)
    final entries = _extractKeyValuePairs(clean);
    return _buildDraftFromMap(entries, slot, clean);
  }

  /// Extracts key-value mappings from arbitrary delimited text.
  static Map<String, double> _extractKeyValuePairs(String text) {
    final Map<String, double> map = {};
    // Split by newlines, semicolons, or commas
    final tokens = text.split(RegExp(r'[\r\n;,]+'));

    for (final token in tokens) {
      final trimmed = token.trim();
      if (trimmed.isEmpty) continue;

      // Match patterns like "O2=4.8" or "O2: 4.8" or "O2 4.8"
      final match = RegExp(
        r'^([a-zA-Z0-9_\.\s]+)[:=\s]+([0-9]+[.,]?[0-9]*)',
      ).firstMatch(trimmed);

      if (match != null) {
        final key = match.group(1)!.trim().toLowerCase().replaceAll(' ', '');
        final val = double.tryParse(match.group(2)!.replaceAll(',', '.'));
        if (val != null) {
          map[key] = val;
        }
      }
    }
    return map;
  }

  static MeasurementSlotDraft _buildDraftFromMap(
    Map<String, double> map,
    String slot,
    String rawPayload,
  ) {
    double? find(List<String> aliases) {
      for (final alias in aliases) {
        if (map.containsKey(alias)) return map[alias];
      }
      return null;
    }

    final o2 = find(['o2', 'zuurstof', 'o2vol']);
    final co2 = find(['co2', 'koolstofdioxide', 'co2vol']);
    final co = find(['comgkwh', 'co', 'coref', 'coppm']);
    final tg = find(['tg', 'tgas', 'temperatuur1', 't1', 'fluetemp']);
    final ta = find(['ta', 'tlucht', 'tair', 'temperatuur2', 't2']);
    final hi = find(['hi', 'rendementhi', 'effhi', 'eta']);
    final hs = find(['hs', 'rendemenths', 'effhs']);
    final pa = find(['pa', 'druk', 'trek', 'pressure']);

    final net = (tg != null && ta != null)
        ? double.parse((tg - ta).toStringAsFixed(1))
        : null;

    return MeasurementSlotDraft(
      slot: slot,
      rawQrPayload: rawPayload,
      o2Percent: o2,
      co2Percent: co2,
      coMgKwh: co,
      flueTempTg: tg,
      ambientTempTa: ta,
      netTemp: net,
      efficiencyHi: hi,
      efficiencyHs: hs,
      fluePressurePa: pa,
    );
  }

  static MeasurementSlotDraft _parseJson(
    Map<String, dynamic> json,
    String slot,
    String rawPayload,
  ) {
    double? parseVal(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    final o2 = parseVal(json['o2'] ?? json['o2_percent']);
    final co2 = parseVal(json['co2'] ?? json['co2_percent']);
    final co = parseVal(json['co_mg_kwh'] ?? json['co'] ?? json['co_ppm']);
    final tg = parseVal(json['tg'] ?? json['flue_temp']);
    final ta = parseVal(json['ta'] ?? json['ambient_temp']);
    final hi = parseVal(json['hi'] ?? json['efficiency_hi']);
    final hs = parseVal(json['hs'] ?? json['efficiency_hs']);
    final pa = parseVal(json['pa'] ?? json['flue_pressure_pa']);

    final net = (tg != null && ta != null)
        ? double.parse((tg - ta).toStringAsFixed(1))
        : null;

    return MeasurementSlotDraft(
      slot: slot,
      rawQrPayload: rawPayload,
      o2Percent: o2,
      co2Percent: co2,
      coMgKwh: co,
      flueTempTg: tg,
      ambientTempTa: ta,
      netTemp: net,
      efficiencyHi: hi,
      efficiencyHs: hs,
      fluePressurePa: pa,
    );
  }

  /// Generates a realistic Eurolyzer STx flue-gas telemetry test payload.
  static String sampleEurolyzerPayload({
    double o2 = 4.8,
    double co2 = 9.2,
    double coMgKwh = 24.5,
    double tg = 54.2,
    double ta = 19.8,
    double hi = 98.4,
    double hs = 88.6,
    double pa = 12.0,
  }) {
    return 'EUROLYZER_STX;O2=$o2;CO2=$co2;CO=$coMgKwh;TG=$tg;TA=$ta;HI=$hi;HS=$hs;PA=$pa';
  }
}
