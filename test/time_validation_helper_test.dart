import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus/time_validation_helper.dart';

void main() {
  group('TimeValidationHelper Unit Tests', () {
    test('parse handles valid and invalid 24-hour time strings', () {
      expect(TimeValidationHelper.parse('08:30'),
          const TimeOfDay(hour: 8, minute: 30));
      expect(TimeValidationHelper.parse('00:00'),
          const TimeOfDay(hour: 0, minute: 0));
      expect(TimeValidationHelper.parse('23:59'),
          const TimeOfDay(hour: 23, minute: 59));

      expect(TimeValidationHelper.parse(''), isNull);
      expect(TimeValidationHelper.parse(null), isNull);
      expect(TimeValidationHelper.parse('not_a_time'), isNull);
      expect(TimeValidationHelper.parse('24:00'), isNull);
      expect(TimeValidationHelper.parse('08:60'), isNull);
      expect(TimeValidationHelper.parse('-1:30'), isNull);
    });

    test('suggestedEndTime adds 1 hour to start time with modulo 24 wrap', () {
      final suggested1 = TimeValidationHelper.suggestedEndTime('08:30');
      expect(suggested1.hour, 9);
      expect(suggested1.minute, 30);

      final suggested2 = TimeValidationHelper.suggestedEndTime('23:15');
      expect(suggested2.hour, 0);
      expect(suggested2.minute, 15);

      final suggestedEmpty = TimeValidationHelper.suggestedEndTime('');
      expect(suggestedEmpty, isNotNull);
    });

    test('validateStartTime requires non-empty value', () {
      expect(TimeValidationHelper.validateStartTime(null),
          'Starttijd is verplicht');
      expect(
          TimeValidationHelper.validateStartTime(''), 'Starttijd is verplicht');
      expect(TimeValidationHelper.validateStartTime('   '),
          'Starttijd is verplicht');
      expect(TimeValidationHelper.validateStartTime('08:30'), isNull);
    });

    test('validateEndTime enforces non-empty and end > start', () {
      expect(TimeValidationHelper.validateEndTime(null, '08:00'),
          'Eindtijd is verplicht');
      expect(TimeValidationHelper.validateEndTime('', '08:00'),
          'Eindtijd is verplicht');

      // Equal times -> invalid
      expect(TimeValidationHelper.validateEndTime('08:00', '08:00'),
          'Moet na starttijd liggen');

      // Earlier end time -> invalid
      expect(TimeValidationHelper.validateEndTime('07:59', '08:00'),
          'Moet na starttijd liggen');
      expect(TimeValidationHelper.validateEndTime('06:00', '14:00'),
          'Moet na starttijd liggen');

      // Valid strictly later times
      expect(TimeValidationHelper.validateEndTime('08:01', '08:00'), isNull);
      expect(TimeValidationHelper.validateEndTime('10:00', '08:00'), isNull);

      // Start time empty -> only validates that end time is non-empty
      expect(TimeValidationHelper.validateEndTime('10:00', ''), isNull);
      expect(TimeValidationHelper.validateEndTime('10:00', null), isNull);
    });
  });
}
