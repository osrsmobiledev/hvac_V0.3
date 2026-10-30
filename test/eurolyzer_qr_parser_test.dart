import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/data/eurolyzer_qr_parser.dart';

void main() {
  group('EurolyzerQrParser Unit Tests', () {
    test('Parses standard semicolon-delimited Eurolyzer payload', () {
      const payload =
          'EUROLYZER_STX;O2=4.8;CO2=9.2;CO=24.5;TG=54.2;TA=19.8;HI=98.4;HS=88.6;PA=12.0';
      final draft = EurolyzerQrParser.parse(payload, slot: 'proef1');

      expect(draft.slot, 'proef1');
      expect(draft.o2Percent, 4.8);
      expect(draft.co2Percent, 9.2);
      expect(draft.coMgKwh, 24.5);
      expect(draft.flueTempTg, 54.2);
      expect(draft.ambientTempTa, 19.8);
      expect(draft.netTemp, 34.4); // 54.2 - 19.8
      expect(draft.efficiencyHi, 98.4);
      expect(draft.efficiencyHs, 88.6);
      expect(draft.fluePressurePa, 12.0);
    });

    test('Parses colon-separated multiline telemetry dump', () {
      const payload = '''
O2: 5.1 %
CO2: 8.9 %
CO: 30 mg/kWh
Tg: 62.0 °C
Ta: 20.0 °C
Hi: 97.8 %
''';
      final draft = EurolyzerQrParser.parse(payload, slot: 'proef2_laaglast');

      expect(draft.slot, 'proef2_laaglast');
      expect(draft.o2Percent, 5.1);
      expect(draft.co2Percent, 8.9);
      expect(draft.coMgKwh, 30.0);
      expect(draft.flueTempTg, 62.0);
      expect(draft.ambientTempTa, 20.0);
      expect(draft.netTemp, 42.0);
      expect(draft.efficiencyHi, 97.8);
    });

    test('Parses JSON-formatted Eurolyzer telemetry payload', () {
      const payload = '''
{
  "o2": 4.5,
  "co2": 9.5,
  "co_mg_kwh": 18.0,
  "flue_temp": 49.5,
  "ambient_temp": 19.5,
  "efficiency_hi": 99.1,
  "efficiency_hs": 89.2
}
''';
      final draft = EurolyzerQrParser.parse(payload, slot: 'proef2_hooglast');

      expect(draft.slot, 'proef2_hooglast');
      expect(draft.o2Percent, 4.5);
      expect(draft.co2Percent, 9.5);
      expect(draft.coMgKwh, 18.0);
      expect(draft.flueTempTg, 49.5);
      expect(draft.ambientTempTa, 19.5);
      expect(draft.netTemp, 30.0);
      expect(draft.efficiencyHi, 99.1);
    });

    test('Generates reproducible sample telemetry payload', () {
      final sample = EurolyzerQrParser.sampleEurolyzerPayload();
      expect(sample.contains('EUROLYZER_STX'), isTrue);
      expect(sample.contains('O2=4.8'), isTrue);

      final parsed = EurolyzerQrParser.parse(sample);
      expect(parsed.o2Percent, 4.8);
      expect(parsed.efficiencyHi, 98.4);
    });
  });
}
