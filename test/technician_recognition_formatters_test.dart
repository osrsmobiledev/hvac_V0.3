// File: test/technician_recognition_formatters_test.dart
// Purpose: Unit tests for Flemish technician GV/TV recognition number formatting, normalization, and statutory validation.

import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/core/utils/technician_recognition_formatters.dart';

void main() {
  group('TechnicianRecognitionFormatters Tests', () {
    test('Prefix stripping extracts only 5 numeric digits', () {
      expect(TechnicianRecognitionFormatters.stripGvPrefix(''), '');
      expect(TechnicianRecognitionFormatters.stripGvPrefix('   '), '');
      expect(TechnicianRecognitionFormatters.stripGvPrefix('GV12345'), '12345');
      expect(
          TechnicianRecognitionFormatters.stripGvPrefix('gv 12345'), '12345');
      expect(
          TechnicianRecognitionFormatters.stripGvPrefix('GV-01234'), '01234');
      expect(TechnicianRecognitionFormatters.stripGvPrefix('01234'), '01234');
      expect(TechnicianRecognitionFormatters.stripTvPrefix('TV67890'), '67890');
      expect(
          TechnicianRecognitionFormatters.stripTvPrefix('tv 67890'), '67890');
      expect(TechnicianRecognitionFormatters.stripTvPrefix('67890'), '67890');
      expect(
          TechnicianRecognitionFormatters.stripGvPrefix('GV12345678'), '12345');
    });

    test('Normalization creates statutory GV/TV stored format', () {
      expect(TechnicianRecognitionFormatters.normalizeGv(''), '');
      expect(TechnicianRecognitionFormatters.normalizeGv('   '), '');
      expect(TechnicianRecognitionFormatters.normalizeGv('12345'), 'GV12345');
      expect(TechnicianRecognitionFormatters.normalizeGv('GV12345'), 'GV12345');
      expect(TechnicianRecognitionFormatters.normalizeTv('67890'), 'TV67890');
      expect(TechnicianRecognitionFormatters.normalizeTv('TV67890'), 'TV67890');
    });

    test('GV validator rejects incomplete digits and validates required fuels',
        () {
      // 5 digits is valid
      expect(TechnicianRecognitionFormatters.validateGv('01234'), isNull);
      expect(TechnicianRecognitionFormatters.validateGv('12345'), isNull);

      // Incomplete digits rejected
      expect(
        TechnicianRecognitionFormatters.validateGv('0000'),
        'GV-nummer moet 5 cijfers zijn',
      );
      expect(
        TechnicianRecognitionFormatters.validateGv('123'),
        'GV-nummer moet 5 cijfers zijn',
      );

      // Gas fuel requires GV
      expect(
        TechnicianRecognitionFormatters.validateGv('', fuelType: 'gas'),
        'GV-nummer is verplicht voor aardgas',
      );

      // Liquid fuel allows empty GV even if TV is still empty
      expect(
        TechnicianRecognitionFormatters.validateGv('',
            fuelType: 'vloeibaar', isTvEmpty: false),
        isNull,
      );
      expect(
        TechnicianRecognitionFormatters.validateGv('',
            fuelType: 'vloeibaar', isTvEmpty: true),
        isNull,
      );

      // If both empty and fuel unknown -> GV-nummer vereist
      expect(
        TechnicianRecognitionFormatters.validateGv('', isTvEmpty: true),
        'GV-nummer vereist',
      );
      expect(
        TechnicianRecognitionFormatters.validateGv('', isTvEmpty: false),
        isNull,
      );
    });

    test('TV validator rejects incomplete digits and validates required fuels',
        () {
      // 5 digits is valid
      expect(TechnicianRecognitionFormatters.validateTv('01234'), isNull);
      expect(TechnicianRecognitionFormatters.validateTv('67890'), isNull);

      // Incomplete digits rejected
      expect(
        TechnicianRecognitionFormatters.validateTv('0000'),
        'TV-nummer moet 5 cijfers zijn',
      );
      expect(
        TechnicianRecognitionFormatters.validateTv('678'),
        'TV-nummer moet 5 cijfers zijn',
      );

      // Liquid fuel requires TV
      expect(
        TechnicianRecognitionFormatters.validateTv('', fuelType: 'vloeibaar'),
        'TV-nummer is verplicht voor stookolie',
      );

      // Gas fuel allows empty TV even if GV is still empty
      expect(
        TechnicianRecognitionFormatters.validateTv('',
            fuelType: 'gas', isGvEmpty: false),
        isNull,
      );
      expect(
        TechnicianRecognitionFormatters.validateTv('',
            fuelType: 'gas', isGvEmpty: true),
        isNull,
      );

      // If both empty and fuel unknown -> TV-nummer vereist
      expect(
        TechnicianRecognitionFormatters.validateTv('', isGvEmpty: true),
        'TV-nummer vereist',
      );
      expect(
        TechnicianRecognitionFormatters.validateTv('', isGvEmpty: false),
        isNull,
      );
    });
  });
}
