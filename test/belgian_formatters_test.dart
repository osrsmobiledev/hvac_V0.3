import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hvac_app/app/theme/app_colors.dart';
import 'package:hvac_app/core/utils/belgian_formatters.dart';
import 'package:hvac_app/features/certificate_draft/ui/tabs/firma_technicus/firma_field.dart';

void main() {
  group('BelgianFormatters Unit Tests', () {
    test('Phone normalization ensures standard +32 prefix', () {
      expect(BelgianFormatters.normalizePhone(''), '');
      expect(BelgianFormatters.normalizePhone('   '), '');
      expect(
        BelgianFormatters.normalizePhone('470 12 34 56'),
        '+32 470 12 34 56',
      );
      expect(
        BelgianFormatters.normalizePhone('+32 470 12 34 56'),
        '+32 470 12 34 56',
      );
      expect(
        BelgianFormatters.normalizePhone('+32470123456'),
        '+32 470123456',
      );
      expect(
        BelgianFormatters.normalizePhone('0032 470 12 34 56'),
        '+32 470 12 34 56',
      );
    });

    test('Phone prefix stripping removes international codes cleanly', () {
      expect(BelgianFormatters.stripPhonePrefix(''), '');
      expect(
        BelgianFormatters.stripPhonePrefix('+32 470 12 34 56'),
        '470 12 34 56',
      );
      expect(
        BelgianFormatters.stripPhonePrefix('+32470123456'),
        '470123456',
      );
      expect(
        BelgianFormatters.stripPhonePrefix('0032 470 12 34 56'),
        '470 12 34 56',
      );
      expect(
        BelgianFormatters.stripPhonePrefix('0470 12 34 56'),
        '470 12 34 56',
      );
    });

    test('KBO normalization ensures standard BE prefix', () {
      expect(BelgianFormatters.normalizeKbo(''), '');
      expect(BelgianFormatters.normalizeKbo('   '), '');
      expect(
        BelgianFormatters.normalizeKbo('0123.456.789'),
        'BE 0123.456.789',
      );
      expect(
        BelgianFormatters.normalizeKbo('BE 0123.456.789'),
        'BE 0123.456.789',
      );
      expect(
        BelgianFormatters.normalizeKbo('be 0123.456.789'),
        'BE 0123.456.789',
      );
      expect(
        BelgianFormatters.normalizeKbo('BE0123.456.789'),
        'BE 0123.456.789',
      );
    });

    test('KBO prefix stripping removes BE code cleanly', () {
      expect(BelgianFormatters.stripKboPrefix(''), '');
      expect(
        BelgianFormatters.stripKboPrefix('BE 0123.456.789'),
        '0123.456.789',
      );
      expect(
        BelgianFormatters.stripKboPrefix('BE0123.456.789'),
        '0123.456.789',
      );
      expect(
        BelgianFormatters.stripKboPrefix('0123.456.789'),
        '0123.456.789',
      );
    });

    test(
        'Phone formatter strips leading zero, auto-spaces, and limits to 9 digits',
        () {
      const formatter = BelgianPhoneInputFormatter();
      const oldValue = TextEditingValue.empty;

      // Typing letters produces empty
      expect(
        formatter
            .formatEditUpdate(oldValue, const TextEditingValue(text: 'abc'))
            .text,
        '',
      );

      // Typing a leading zero is automatically stripped
      expect(
        formatter
            .formatEditUpdate(oldValue, const TextEditingValue(text: '0'))
            .text,
        '',
      );

      // Typing 0470 converts smoothly to 470
      expect(
        formatter
            .formatEditUpdate(oldValue, const TextEditingValue(text: '0470'))
            .text,
        '470',
      );

      // Mobile number is segmented into 3-2-2-2
      expect(
        formatter
            .formatEditUpdate(
                oldValue, const TextEditingValue(text: '470123456'))
            .text,
        '470 12 34 56',
      );

      // Typing 14 nines ('99999999999999') is strictly limited to 9 digits
      expect(
        formatter
            .formatEditUpdate(
                oldValue, const TextEditingValue(text: '99999999999999'))
            .text,
        '99 99 99 999',
      );

      // Pasting full number with +32 cleanly formats
      expect(
        formatter
            .formatEditUpdate(
                oldValue, const TextEditingValue(text: '+32 470 12 34 56'))
            .text,
        '470 12 34 56',
      );
    });

    test('KBO formatter auto-inserts dots and limits to 10 digits', () {
      const formatter = BelgianKboInputFormatter();
      const oldValue = TextEditingValue.empty;

      // Letters rejected
      expect(
        formatter
            .formatEditUpdate(oldValue, const TextEditingValue(text: 'xyz'))
            .text,
        '',
      );

      // Digits auto-insert dots at 4 and 7 positions
      expect(
        formatter
            .formatEditUpdate(
                oldValue, const TextEditingValue(text: '0400378485'))
            .text,
        '0400.378.485',
      );

      // More than 10 digits blocked
      expect(
        formatter
            .formatEditUpdate(
                oldValue, const TextEditingValue(text: '0400378485999'))
            .text,
        '0400.378.485',
      );
    });

    test('validatePhone validates Belgian phone numbers correctly', () {
      expect(BelgianFormatters.validatePhone(''), isNull);
      expect(BelgianFormatters.validatePhone('   '), isNull);
      expect(
        BelgianFormatters.validatePhone('', required: true),
        'Telefoonnummer is verplicht',
      );
      // Valid mobile numbers
      expect(BelgianFormatters.validatePhone('0470 12 34 56'), isNull);
      expect(BelgianFormatters.validatePhone('470 12 34 56'), isNull);
      expect(BelgianFormatters.validatePhone('0470123456'), isNull);
      expect(BelgianFormatters.validatePhone('+32 470 12 34 56'), isNull);
      expect(BelgianFormatters.validatePhone('+32470123456'), isNull);
      expect(BelgianFormatters.validatePhone('0032 470 12 34 56'), isNull);
      // Valid landline numbers
      expect(BelgianFormatters.validatePhone('09 123 45 67'), isNull);
      expect(BelgianFormatters.validatePhone('02 456 78 90'), isNull);
      // Invalid numbers
      expect(
        BelgianFormatters.validatePhone('123'),
        'Ongeldig telefoonnummer (bv. 470 12 34 56)',
      );
      expect(
        BelgianFormatters.validatePhone('123456789012345'),
        'Ongeldig telefoonnummer (bv. 470 12 34 56)',
      );
      // Incomplete mobile numbers (deleted one digit -> 8 digits starting with 4)
      expect(
        BelgianFormatters.validatePhone('470 12 34 5'),
        'Ongeldig telefoonnummer (bv. 470 12 34 56)',
      );
      expect(
        BelgianFormatters.validatePhone('+32 470 12 34 5'),
        'Ongeldig telefoonnummer (bv. 470 12 34 56)',
      );
      // Incomplete landline
      expect(
        BelgianFormatters.validatePhone('09 123 45 6'),
        'Ongeldig telefoonnummer (bv. 470 12 34 56)',
      );
    });

    test('validateKbo validates statutory Modulo 97 checksum correctly', () {
      expect(BelgianFormatters.validateKbo(''), isNull);
      expect(BelgianFormatters.validateKbo('   '), isNull);
      expect(
        BelgianFormatters.validateKbo('', required: true),
        'Ondernemingsnummer is verplicht',
      );
      // Valid KBO numbers (Colruyt: 0400.378.485, Proximus: 0202.239.951, Test: 0473.495.107)
      expect(BelgianFormatters.validateKbo('0400.378.485'), isNull);
      expect(BelgianFormatters.validateKbo('0202.239.951'), isNull);
      expect(BelgianFormatters.validateKbo('0473.495.107'), isNull);
      expect(BelgianFormatters.validateKbo('0473495107'), isNull);
      // Invalid length
      expect(
        BelgianFormatters.validateKbo('012345'),
        'Ondernemingsnummer moet 10 cijfers bevatten',
      );
      // Invalid Modulo 97 checksum
      expect(
        BelgianFormatters.validateKbo('0400.378.486'),
        'Ongeldig controlegetal (Modulo 97)',
      );
    });

    test('validateEmail validates email addresses correctly', () {
      expect(BelgianFormatters.validateEmail(''), isNull);
      expect(BelgianFormatters.validateEmail('   '), isNull);
      expect(
        BelgianFormatters.validateEmail('', required: true),
        'E-mailadres is verplicht',
      );
      // Valid emails
      expect(BelgianFormatters.validateEmail('info@firma.be'), isNull);
      expect(
          BelgianFormatters.validateEmail('john.doe@sub.domain.com'), isNull);
      expect(
          BelgianFormatters.validateEmail('tech+test@hvac-service.vlaanderen'),
          isNull);
      // Invalid emails
      expect(
        BelgianFormatters.validateEmail('notanemail'),
        'Vul een geldig e-mailadres in (bv. info@firma.be)',
      );
      expect(
        BelgianFormatters.validateEmail('user@'),
        'Vul een geldig e-mailadres in (bv. info@firma.be)',
      );
      expect(
        BelgianFormatters.validateEmail('@domain.be'),
        'Vul een geldig e-mailadres in (bv. info@firma.be)',
      );
      expect(
        BelgianFormatters.validateEmail('user@domain'),
        'Vul een geldig e-mailadres in (bv. info@firma.be)',
      );
    });

    testWidgets(
        'FirmaField renders permanent prefix before focus and validates in real time',
        (tester) async {
      final phoneController = TextEditingController();
      addTearDown(phoneController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirmaField(
              label: 'Tel:',
              controller: phoneController,
              prefixText: BelgianFormatters.phonePrefix,
              inputFormatters: BelgianFormatters.phoneFormatters,
              validator: BelgianFormatters.validatePhone,
              onChanged: () {},
            ),
          ),
        ),
      );

      // Verify prefix is permanently visible BEFORE any tap or focus
      expect(find.text('+32 '), findsOneWidget);

      // Enter invalid phone
      await tester.enterText(find.byType(TextField), '123');
      await tester.pumpAndSettle();

      // Real-time red border is displayed, zero error text
      final invalidField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (invalidField.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        AppColors.errorRed,
      );
      expect(
        find.text('Ongeldig telefoonnummer (bv. 470 12 34 56)'),
        findsNothing,
      );

      // Enter phone with leading 0; formatter automatically strips 0 and segments
      await tester.enterText(find.byType(TextField), '0470123456');
      await tester.pumpAndSettle();

      expect(phoneController.text, '470 12 34 56');

      // Red border is gone
      final validField = tester.widget<TextField>(find.byType(TextField));
      expect(
        (validField.decoration!.enabledBorder as OutlineInputBorder)
            .borderSide
            .color,
        isNot(AppColors.errorRed),
      );
    });
  });
}
